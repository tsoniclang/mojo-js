#include "model.h"
#include <stdio.h>
#include <stdlib.h>

TsonicIntlResult *tsonic_intl_failure(const char *message) {
    TsonicIntlResult *result = calloc(1, sizeof(*result));
    if (result != NULL) {
        result->failed = 1;
        snprintf(result->error, sizeof(result->error), "%s", message);
    }
    return result;
}

TsonicIntlResult *tsonic_intl_icu_failure(UErrorCode status) {
    return tsonic_intl_failure(u_errorName(status));
}

int tsonic_intl_valid_units(const uint16_t *source, size_t length) {
    return length <= TSONIC_INTL_MAX_UNITS &&
        (length == 0 || source != NULL);
}

int tsonic_js_intl_failed(const TsonicIntlResult *result) {
    return result == NULL || result->failed;
}

const char *tsonic_js_intl_error(const TsonicIntlResult *result) {
    return result == NULL ? "Unable to allocate internationalization result" : result->error;
}

const char *tsonic_js_intl_text(const TsonicIntlResult *result) {
    return result == NULL ? NULL : result->text;
}

const uint16_t *tsonic_js_intl_units(const TsonicIntlResult *result) {
    return result == NULL ? NULL : result->units;
}

size_t tsonic_js_intl_length(const TsonicIntlResult *result) {
    return result == NULL ? 0 : result->length;
}

int tsonic_js_intl_order(const TsonicIntlResult *result) {
    return result == NULL ? 0 : result->order;
}

void tsonic_js_intl_free(TsonicIntlResult *result) {
    if (result == NULL) return;
    free(result->text);
    free(result->units);
    free(result);
}
