#include "number_model.h"
#include <stdlib.h>
#include <string.h>
#include <unicode/uloc.h>
#include <unicode/unum.h>
#include <unicode/unumsys.h>

static int bounded_ascii(const char *value, size_t limit) {
    if (value == NULL) return 0;
    for (size_t index = 0; index <= limit; ++index) {
        if (value[index] == '\0') return 1;
        if ((unsigned char)value[index] > 127) return 0;
    }
    return 0;
}

static void close_number(void *resource) {
    TsonicNumberFormat *owner = resource;
    unumf_close(owner->format);
    free(owner);
}

TsonicIntlResult *tsonic_js_intl_number_formatter_open(const char *locale,
    const char *numbering, const char *skeleton) {
    if (!bounded_ascii(locale, TSONIC_INTL_MAX_LOCALE) || !bounded_ascii(numbering, 128) ||
        !bounded_ascii(skeleton, 1024)) return tsonic_intl_failure("Invalid localized number contract");
    UErrorCode status = U_ZERO_ERROR;
    char selected[TSONIC_INTL_MAX_LOCALE + 1], resolved[TSONIC_INTL_MAX_LOCALE + 1];
    if (!tsonic_intl_match_locale(locale, unum_countAvailable(), unum_getAvailable,
        selected, sizeof(selected), &status)) return tsonic_intl_icu_failure(status);
    char extension[TSONIC_INTL_MAX_LOCALE + 1];
    int32_t extension_length = uloc_getKeywordValue(locale, "numbers", extension, sizeof(extension), &status);
    if (U_SUCCESS(status) && extension_length != 0) uloc_setKeywordValue("numbers", extension, selected, sizeof(selected), &status);
    tsonic_intl_numbering(selected, sizeof(selected), "", &status);
    if (U_FAILURE(status)) return tsonic_intl_icu_failure(status);
    memcpy(resolved, selected, strlen(selected) + 1);
    tsonic_intl_numbering(selected, sizeof(selected), numbering, &status);
    if (U_FAILURE(status)) return tsonic_intl_icu_failure(status);
    UChar pattern[1025];
    int32_t length = (int32_t)strlen(skeleton);
    for (int32_t index = 0; index < length; ++index) pattern[index] = skeleton[index];
    UNumberFormatter *formatter = unumf_openForSkeletonAndLocale(pattern, length, selected, &status);
    UNumberingSystem *system = U_SUCCESS(status) ? unumsys_open(selected, &status) : NULL;
    if (U_FAILURE(status) || formatter == NULL || system == NULL) {
        unumf_close(formatter);
        unumsys_close(system);
        return tsonic_intl_icu_failure(U_FAILURE(status) ? status : U_MEMORY_ALLOCATION_ERROR);
    }
    TsonicIntlResult *result = calloc(1, sizeof(*result));
    TsonicNumberFormat *owner = calloc(1, sizeof(*owner));
    if (result == NULL || owner == NULL) {
        free(result);
        free(owner);
        unumf_close(formatter);
        unumsys_close(system);
        return NULL;
    }
    owner->format = formatter;
    result->resource = owner;
    result->free_resource = close_number;
    const char *name = unumsys_getName(system);
    if (name == NULL || strlen(name) >= sizeof(owner->numbering)) status = U_INTERNAL_PROGRAM_ERROR;
    else memcpy(owner->numbering, name, strlen(name) + 1);
    unumsys_close(system);
    tsonic_intl_resolved_keyword(resolved, sizeof(resolved), "numbers", owner->numbering, &status);
    if (U_SUCCESS(status)) uloc_toLanguageTag(resolved, owner->locale, sizeof(owner->locale), 1, &status);
    if (U_FAILURE(status)) {
        tsonic_js_intl_free(result);
        return tsonic_intl_icu_failure(status);
    }
    return result;
}

TsonicIntlResult *tsonic_js_intl_number_formatter_format(const TsonicIntlResult *result,
    double value, const char *decimal, int parts) {
    if (result == NULL || result->failed || result->resource == NULL || result->free_resource != close_number ||
        (parts != 0 && parts != 1)) return tsonic_intl_failure("Invalid retained number formatting operation");
    return tsonic_intl_format_number(((TsonicNumberFormat *)result->resource)->format, value, decimal, parts);
}

const char *tsonic_js_intl_number_formatter_text(const TsonicIntlResult *result, int field) {
    if (result == NULL || result->failed || result->resource == NULL || result->free_resource != close_number) return NULL;
    const TsonicNumberFormat *owner = result->resource;
    switch (field) {
        case 0: return owner->locale;
        case 1: return owner->numbering;
        default: return NULL;
    }
}

TsonicIntlResult *tsonic_js_intl_number(double value, const char *decimal,
    const char *locale, const char *numbering, const char *skeleton) {
    TsonicIntlResult *owner = tsonic_js_intl_number_formatter_open(locale, numbering, skeleton);
    if (owner == NULL || owner->failed) return owner;
    TsonicIntlResult *result = tsonic_js_intl_number_formatter_format(owner, value, decimal, 0);
    tsonic_js_intl_free(owner);
    return result;
}
