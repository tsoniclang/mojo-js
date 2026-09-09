#include "model.h"
#include <stdlib.h>
#include <string.h>
#include <unicode/uloc.h>
#include <unicode/ucol.h>

TsonicIntlResult *tsonic_js_intl_locale(const char *tag, size_t length) {
    if (!tsonic_intl_valid_tag(tag, length) || strlen(tag) != length) {
        return tsonic_intl_failure("Invalid Unicode locale identifier");
    }
    char converted[TSONIC_INTL_MAX_LOCALE + 1];
    int32_t parsed = 0;
    UErrorCode status = U_ZERO_ERROR;
    uloc_forLanguageTag(tag, converted, sizeof(converted), &parsed, &status);
    if (U_FAILURE(status) || parsed != (int32_t)length) {
        return tsonic_intl_failure("Invalid Unicode locale identifier");
    }
    TsonicIntlResult *result = calloc(1, sizeof(*result));
    if (result == NULL) return NULL;
    result->text = malloc(TSONIC_INTL_MAX_LOCALE + 1);
    if (result->text == NULL) {
        free(result);
        return tsonic_intl_failure("Unable to allocate canonical locale identifier");
    }
    uloc_canonicalize(converted, result->text, TSONIC_INTL_MAX_LOCALE + 1, &status);
    if (U_FAILURE(status)) {
        tsonic_js_intl_free(result);
        return tsonic_intl_icu_failure(status);
    }
    return result;
}

TsonicIntlResult *tsonic_js_intl_default_locale(void) {
    const char *locale = uloc_getDefault();
    size_t length = strlen(locale);
    if (length > TSONIC_INTL_MAX_LOCALE) {
        return tsonic_intl_failure("Default locale exceeds its runtime contract");
    }
    TsonicIntlResult *result = calloc(1, sizeof(*result));
    if (result == NULL) return NULL;
    result->text = malloc(length + 1);
    if (result->text == NULL) {
        free(result);
        return tsonic_intl_failure("Unable to allocate default locale identifier");
    }
    memcpy(result->text, locale, length + 1);
    return result;
}

int tsonic_js_intl_collation_available(const char *locale) {
    if (locale == NULL || strlen(locale) > TSONIC_INTL_MAX_LOCALE) return 0;
    char base[TSONIC_INTL_MAX_LOCALE + 1];
    UErrorCode status = U_ZERO_ERROR;
    uloc_getBaseName(locale, base, sizeof(base), &status);
    if (U_FAILURE(status)) return 0;
    while (base[0] != '\0') {
        for (int32_t index = 0; index < ucol_countAvailable(); ++index) {
            if (strcmp(base, ucol_getAvailable(index)) == 0) return 1;
        }
        char *separator = strrchr(base, '_');
        if (separator == NULL) break;
        *separator = '\0';
    }
    return 0;
}
