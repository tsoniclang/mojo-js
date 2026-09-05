#include <quickjs.h>

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TSONIC_MAX_STRING_UNITS 16777216u
#define TSONIC_QUICKJS_MEMORY_LIMIT 67108864u
#define TSONIC_QUICKJS_STACK_LIMIT 1048576u

typedef struct {
    JSRuntime *runtime;
    JSContext *context;
    JSValue value;
    uint64_t interrupts;
} TsonicRegExp;

typedef struct {
    TsonicRegExp *value;
    char *error;
    size_t error_length;
} TsonicCreateResult;

typedef struct {
    char *json;
    size_t json_length;
    char *error;
    size_t error_length;
} TsonicCommandResult;

typedef struct {
    char *data;
    size_t length;
    size_t capacity;
} TsonicBuffer;

enum {
    TSONIC_REGEXP_EXEC = 1,
    TSONIC_REGEXP_TEST = 2,
    TSONIC_REGEXP_MATCH = 3,
    TSONIC_REGEXP_MATCH_ALL = 4,
    TSONIC_REGEXP_SEARCH = 5,
    TSONIC_REGEXP_SPLIT = 6,
    TSONIC_REGEXP_REPLACE = 7,
    TSONIC_REGEXP_REPLACE_ALL = 8,
    TSONIC_REGEXP_DESCRIBE = 9,
    TSONIC_REGEXP_ESCAPE = 10,
    TSONIC_REGEXP_CALLBACK_REPLACE = 11,
    TSONIC_REGEXP_CALLBACK_REPLACE_ALL = 12,
    TSONIC_STRING_CALLBACK_REPLACE = 13,
    TSONIC_STRING_CALLBACK_REPLACE_ALL = 14
};

static const char *TSONIC_HELPERS =
    "globalThis.__tsonicObject = function(value) {"
    "if (value === undefined) return null;"
    "const result = {};"
    "for (const key of Object.keys(value)) result[key] = value[key] === undefined ? null : value[key];"
    "return result;"
    "};"
    "globalThis.__tsonicIndices = function(value) {"
    "if (value === undefined) return null;"
    "return {values:Array.from(value, item => item === undefined ? null : item),groups:__tsonicObject(value.groups)};"
    "};"
    "globalThis.__tsonicMatch = function(value) {"
    "if (value === null) return null;"
    "return {values:Array.from(value, item => item === undefined ? null : item),"
    "index:typeof value.index === 'number' ? value.index : null,"
    "input:typeof value.input === 'string' ? value.input : null,"
    "groups:__tsonicObject(value.groups),indices:__tsonicIndices(value.indices)};"
    "};"
    "globalThis.__tsonicCallbackArgument = function(value) {"
    "if (value === undefined) return {kind:'undefined'};"
    "if (value === null) return {kind:'null'};"
    "if (typeof value === 'boolean') return {kind:'boolean',value};"
    "if (typeof value === 'number') return {kind:'number',value};"
    "if (typeof value === 'string') return {kind:'string',value};"
    "if (typeof value === 'object') return {kind:'object',entries:Object.keys(value).map(key=>[key,__tsonicCallbackArgument(value[key])])};"
    "throw new TypeError('Unsupported RegExp callback argument');"
    "};"
    "globalThis.__tsonicCallbackRecords = function(input, search, replaceAll) {"
    "const records=[];"
    "const callback=(...args)=>{"
    "const hasGroups=args.length>0&&args[args.length-1]!==null&&typeof args[args.length-1]==='object';"
    "const inputIndex=args.length-(hasGroups?2:1);"
    "const start=args[inputIndex-1];"
    "const matched=args[0];"
    "if(typeof start!=='number'||typeof matched!=='string')throw new TypeError('Invalid RegExp callback record');"
    "records.push({start,end:start+matched.length,arguments:args.map(__tsonicCallbackArgument)});"
    "return '';"
    "};"
    "if(replaceAll)input.replaceAll(search,callback);else input.replace(search,callback);"
    "return records;"
    "};";

static int tsonic_interrupt(JSRuntime *runtime, void *opaque) {
    (void)runtime;
    TsonicRegExp *regexp = (TsonicRegExp *)opaque;
    regexp->interrupts += 1;
    return regexp->interrupts > 1000000u;
}

static int buffer_reserve(TsonicBuffer *buffer, size_t additional) {
    if (additional > SIZE_MAX - buffer->length - 1u) return 0;
    size_t required = buffer->length + additional + 1u;
    if (required <= buffer->capacity) return 1;
    size_t capacity = buffer->capacity == 0u ? 256u : buffer->capacity;
    while (capacity < required) {
        if (capacity > SIZE_MAX / 2u) {
            capacity = required;
            break;
        }
        capacity *= 2u;
    }
    char *next = (char *)realloc(buffer->data, capacity);
    if (next == NULL) return 0;
    buffer->data = next;
    buffer->capacity = capacity;
    return 1;
}

static int buffer_append(TsonicBuffer *buffer, const char *value) {
    size_t length = strlen(value);
    if (!buffer_reserve(buffer, length)) return 0;
    memcpy(buffer->data + buffer->length, value, length);
    buffer->length += length;
    buffer->data[buffer->length] = '\0';
    return 1;
}

static int buffer_append_unit_literal(TsonicBuffer *buffer, uint16_t value) {
    static const char digits[] = "0123456789abcdef";
    if (!buffer_reserve(buffer, 6u)) return 0;
    buffer->data[buffer->length++] = '\\';
    buffer->data[buffer->length++] = 'u';
    buffer->data[buffer->length++] = digits[(value >> 12u) & 0x0fu];
    buffer->data[buffer->length++] = digits[(value >> 8u) & 0x0fu];
    buffer->data[buffer->length++] = digits[(value >> 4u) & 0x0fu];
    buffer->data[buffer->length++] = digits[value & 0x0fu];
    buffer->data[buffer->length] = '\0';
    return 1;
}

static int buffer_append_string_literal(
    TsonicBuffer *buffer,
    const uint16_t *units,
    size_t length
) {
    if (length > TSONIC_MAX_STRING_UNITS || (length != 0u && units == NULL)) return 0;
    if (!buffer_append(buffer, "\"")) return 0;
    for (size_t index = 0; index < length; index += 1u) {
        if (!buffer_append_unit_literal(buffer, units[index])) return 0;
    }
    return buffer_append(buffer, "\"");
}

static char *copy_text(const char *text, size_t length) {
    char *copy = (char *)malloc(length + 1u);
    if (copy == NULL) return NULL;
    memcpy(copy, text, length);
    copy[length] = '\0';
    return copy;
}

static char *exception_text(JSContext *context, size_t *length) {
    JSValue exception = JS_GetException(context);
    const char *text = JS_ToCStringLen(context, length, exception);
    static const char fallback[] = "JavaScript RegExp operation failed";
    if (text == NULL) *length = strlen(fallback);
    char *copy = text == NULL ? copy_text(fallback, *length) : copy_text(text, *length);
    if (text != NULL) JS_FreeCString(context, text);
    JS_FreeValue(context, exception);
    if (copy == NULL) {
        *length = 0u;
        return NULL;
    }
    return copy;
}

static TsonicCreateResult *create_failure(JSContext *context, const char *message) {
    TsonicCreateResult *result = (TsonicCreateResult *)calloc(1u, sizeof(*result));
    if (result == NULL) return NULL;
    if (context == NULL) {
        result->error_length = strlen(message);
        result->error = copy_text(message, result->error_length);
    } else {
        result->error = exception_text(context, &result->error_length);
    }
    return result;
}

static TsonicCommandResult *command_failure(JSContext *context, const char *message) {
    TsonicCommandResult *result = (TsonicCommandResult *)calloc(1u, sizeof(*result));
    if (result == NULL) return NULL;
    if (context == NULL) {
        result->error_length = strlen(message);
        result->error = copy_text(message, result->error_length);
    } else {
        result->error = exception_text(context, &result->error_length);
    }
    return result;
}

static JSValue eval_buffer(JSContext *context, const TsonicBuffer *source) {
    return JS_Eval(
        context,
        source->data,
        source->length,
        "<tsonic-regexp>",
        JS_EVAL_TYPE_GLOBAL
    );
}

TsonicCreateResult *tsonic_js_regexp_create(
    const uint16_t *pattern,
    size_t pattern_length,
    int has_pattern,
    const uint16_t *flags,
    size_t flags_length,
    int has_flags
) {
    if (pattern_length > TSONIC_MAX_STRING_UNITS || flags_length > 32u ||
        (has_pattern && pattern_length != 0u && pattern == NULL) ||
        (has_flags && flags_length != 0u && flags == NULL)) {
        return create_failure(NULL, "JavaScript RegExp input exceeds its runtime contract");
    }
    TsonicRegExp *regexp = (TsonicRegExp *)calloc(1u, sizeof(*regexp));
    if (regexp == NULL) return create_failure(NULL, "Unable to allocate JavaScript RegExp state");
    regexp->runtime = JS_NewRuntime();
    if (regexp->runtime == NULL) {
        free(regexp);
        return create_failure(NULL, "Unable to create JavaScript RegExp runtime");
    }
    JS_SetMemoryLimit(regexp->runtime, TSONIC_QUICKJS_MEMORY_LIMIT);
    JS_SetMaxStackSize(regexp->runtime, TSONIC_QUICKJS_STACK_LIMIT);
    JS_SetInterruptHandler(regexp->runtime, tsonic_interrupt, regexp);
    regexp->context = JS_NewContext(regexp->runtime);
    if (regexp->context == NULL) {
        JS_FreeRuntime(regexp->runtime);
        free(regexp);
        return create_failure(NULL, "Unable to create JavaScript RegExp context");
    }
    regexp->value = JS_UNDEFINED;
    JSValue initialized = JS_Eval(
        regexp->context,
        TSONIC_HELPERS,
        strlen(TSONIC_HELPERS),
        "<tsonic-regexp-runtime>",
        JS_EVAL_TYPE_GLOBAL
    );
    if (JS_IsException(initialized)) {
        TsonicCreateResult *failure = create_failure(regexp->context, NULL);
        JS_FreeContext(regexp->context);
        JS_FreeRuntime(regexp->runtime);
        free(regexp);
        return failure;
    }
    JS_FreeValue(regexp->context, initialized);
    TsonicBuffer source = {0};
    int valid = buffer_append(&source, "globalThis.__tsonicRegExp = new RegExp(");
    if (valid && has_pattern) valid = buffer_append_string_literal(&source, pattern, pattern_length);
    if (valid && !has_pattern) valid = buffer_append(&source, "undefined");
    if (valid && has_flags) {
        valid = buffer_append(&source, ",") &&
            buffer_append_string_literal(&source, flags, flags_length);
    }
    if (valid) valid = buffer_append(&source, "); globalThis.__tsonicRegExp;");
    if (!valid) {
        free(source.data);
        JS_FreeContext(regexp->context);
        JS_FreeRuntime(regexp->runtime);
        free(regexp);
        return create_failure(NULL, "Unable to allocate JavaScript RegExp source");
    }
    regexp->value = eval_buffer(regexp->context, &source);
    free(source.data);
    if (JS_IsException(regexp->value)) {
        TsonicCreateResult *failure = create_failure(regexp->context, NULL);
        JS_FreeContext(regexp->context);
        JS_FreeRuntime(regexp->runtime);
        free(regexp);
        return failure;
    }
    TsonicCreateResult *result = (TsonicCreateResult *)calloc(1u, sizeof(*result));
    if (result == NULL) {
        JS_FreeValue(regexp->context, regexp->value);
        JS_FreeContext(regexp->context);
        JS_FreeRuntime(regexp->runtime);
        free(regexp);
        return NULL;
    }
    result->value = regexp;
    return result;
}

static int append_command(
    TsonicBuffer *source,
    int operation,
    const uint16_t *input,
    size_t input_length,
    const uint16_t *argument,
    size_t argument_length,
    double number,
    int has_number
) {
    if (!buffer_append(source, "JSON.stringify((()=>{const r=globalThis.__tsonicRegExp;const s=")) return 0;
    if (!buffer_append_string_literal(source, input, input_length)) return 0;
    switch (operation) {
        case TSONIC_REGEXP_EXEC:
            return buffer_append(source, ";const v=r.exec(s);return {lastIndex:r.lastIndex,value:__tsonicMatch(v)};})())");
        case TSONIC_REGEXP_TEST:
            return buffer_append(source, ";const v=r.test(s);return {lastIndex:r.lastIndex,value:v};})())");
        case TSONIC_REGEXP_MATCH:
            return buffer_append(source, ";const v=s.match(r);return {lastIndex:r.lastIndex,value:v===null?null:(r.global?{values:Array.from(v),index:null,input:null,groups:null,indices:null}:__tsonicMatch(v))};})())");
        case TSONIC_REGEXP_MATCH_ALL:
            return buffer_append(source, ";const v=Array.from(s.matchAll(r),__tsonicMatch);return {lastIndex:r.lastIndex,value:v};})())");
        case TSONIC_REGEXP_SEARCH:
            return buffer_append(source, ";const v=s.search(r);return {lastIndex:r.lastIndex,value:v};})())");
        case TSONIC_REGEXP_ESCAPE:
            return buffer_append(source,
                ";const v=RegExp.escape(s);return {lastIndex:r.lastIndex,value:v};})())");
        case TSONIC_REGEXP_SPLIT: {
            if (!buffer_append(source, ";const v=s.split(r")) return 0;
            if (has_number) {
                char limit[64];
                int count = snprintf(limit, sizeof(limit), ",%.17g", number);
                if (count <= 0 || (size_t)count >= sizeof(limit) ||
                    !buffer_append(source, limit)) return 0;
            }
            return buffer_append(source,
                ");return {lastIndex:r.lastIndex,value:Array.from(v,item=>item===undefined?null:item)};})())");
        }
        case TSONIC_REGEXP_REPLACE:
        case TSONIC_REGEXP_REPLACE_ALL:
            if (!buffer_append(source, ";const a=")) return 0;
            if (!buffer_append_string_literal(source, argument, argument_length)) return 0;
            return buffer_append(source,
                operation == TSONIC_REGEXP_REPLACE
                    ? ";const v=s.replace(r,a);return {lastIndex:r.lastIndex,value:v};})())"
                    : ";const v=s.replaceAll(r,a);return {lastIndex:r.lastIndex,value:v};})())");
        case TSONIC_REGEXP_CALLBACK_REPLACE:
        case TSONIC_REGEXP_CALLBACK_REPLACE_ALL:
            return buffer_append(source,
                operation == TSONIC_REGEXP_CALLBACK_REPLACE
                    ? ";const v=__tsonicCallbackRecords(s,r,false);return {lastIndex:r.lastIndex,value:v};})())"
                    : ";const v=__tsonicCallbackRecords(s,r,true);return {lastIndex:r.lastIndex,value:v};})())");
        case TSONIC_STRING_CALLBACK_REPLACE:
        case TSONIC_STRING_CALLBACK_REPLACE_ALL:
            if (!buffer_append(source, ";const a=")) return 0;
            if (!buffer_append_string_literal(source, argument, argument_length)) return 0;
            return buffer_append(source,
                operation == TSONIC_STRING_CALLBACK_REPLACE
                    ? ";const v=__tsonicCallbackRecords(s,a,false);return {lastIndex:r.lastIndex,value:v};})())"
                    : ";const v=__tsonicCallbackRecords(s,a,true);return {lastIndex:r.lastIndex,value:v};})())");
        default:
            return 0;
    }
}

TsonicCommandResult *tsonic_js_regexp_command(
    TsonicRegExp *regexp,
    int operation,
    const uint16_t *input,
    size_t input_length,
    const uint16_t *argument,
    size_t argument_length,
    double number,
    int has_number
) {
    if (regexp == NULL || input_length > TSONIC_MAX_STRING_UNITS ||
        argument_length > TSONIC_MAX_STRING_UNITS) {
        return command_failure(NULL, "Invalid JavaScript RegExp command input");
    }
    regexp->interrupts = 0u;
    TsonicBuffer source = {0};
    int valid;
    if (operation == TSONIC_REGEXP_DESCRIBE) {
        valid = buffer_append(&source,
            "JSON.stringify((()=>{const r=globalThis.__tsonicRegExp;return {"
            "source:r.source,flags:r.flags,global:r.global,ignoreCase:r.ignoreCase,"
            "multiline:r.multiline,dotAll:r.dotAll,hasIndices:r.hasIndices,"
            "sticky:r.sticky,unicode:r.unicode,unicodeSets:r.unicodeSets,"
            "lastIndex:r.lastIndex,text:r.toString()};})())");
    } else {
        valid = append_command(
            &source,
            operation,
            input,
            input_length,
            argument,
            argument_length,
            number,
            has_number
        );
    }
    if (!valid) {
        free(source.data);
        return command_failure(NULL, "Unable to allocate JavaScript RegExp command source");
    }
    JSValue value = eval_buffer(regexp->context, &source);
    free(source.data);
    if (JS_IsException(value)) return command_failure(regexp->context, NULL);
    size_t length = 0u;
    const char *json = JS_ToCStringLen(regexp->context, &length, value);
    if (json == NULL) {
        JS_FreeValue(regexp->context, value);
        return command_failure(regexp->context, NULL);
    }
    TsonicCommandResult *result = (TsonicCommandResult *)calloc(1u, sizeof(*result));
    if (result != NULL) {
        result->json = copy_text(json, length);
        result->json_length = result->json == NULL ? 0u : length;
    }
    JS_FreeCString(regexp->context, json);
    JS_FreeValue(regexp->context, value);
    return result;
}

int tsonic_js_regexp_set_last_index(TsonicRegExp *regexp, double value) {
    if (regexp == NULL) return 0;
    JSValue number = JS_NewFloat64(regexp->context, value);
    return JS_SetPropertyStr(regexp->context, regexp->value, "lastIndex", number) >= 0;
}

TsonicRegExp *tsonic_js_regexp_create_value(TsonicCreateResult *result) {
    return result == NULL ? NULL : result->value;
}

const char *tsonic_js_regexp_create_error(TsonicCreateResult *result) {
    return result == NULL ? NULL : result->error;
}

size_t tsonic_js_regexp_create_error_length(TsonicCreateResult *result) {
    return result == NULL ? 0u : result->error_length;
}

void tsonic_js_regexp_create_result_free(TsonicCreateResult *result) {
    if (result == NULL) return;
    free(result->error);
    free(result);
}

const char *tsonic_js_regexp_command_json(TsonicCommandResult *result) {
    return result == NULL ? NULL : result->json;
}

size_t tsonic_js_regexp_command_json_length(TsonicCommandResult *result) {
    return result == NULL ? 0u : result->json_length;
}

const char *tsonic_js_regexp_command_error(TsonicCommandResult *result) {
    return result == NULL ? NULL : result->error;
}

size_t tsonic_js_regexp_command_error_length(TsonicCommandResult *result) {
    return result == NULL ? 0u : result->error_length;
}

void tsonic_js_regexp_command_result_free(TsonicCommandResult *result) {
    if (result == NULL) return;
    free(result->json);
    free(result->error);
    free(result);
}

void tsonic_js_regexp_free(TsonicRegExp *regexp) {
    if (regexp == NULL) return;
    JS_FreeValue(regexp->context, regexp->value);
    JS_FreeContext(regexp->context);
    JS_FreeRuntime(regexp->runtime);
    free(regexp);
}
