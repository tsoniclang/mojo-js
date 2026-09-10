#include "model.h"
#include <stdlib.h>
#include <string.h>
#include <unicode/ustring.h>

TsonicIntlResult *tsonic_js_intl_case(
    const uint16_t *source, size_t length, const char *locale, int upper) {
    if (!tsonic_intl_valid_units(source, length) || locale == NULL ||
        strlen(locale) > TSONIC_INTL_MAX_LOCALE || (upper != 0 && upper != 1)) {
        return tsonic_intl_failure("Invalid locale-sensitive case conversion input");
    }
    UErrorCode status = U_ZERO_ERROR;
    int32_t required = upper
        ? u_strToUpper(NULL, 0, (const UChar *)source, (int32_t)length, locale, &status)
        : u_strToLower(NULL, 0, (const UChar *)source, (int32_t)length, locale, &status);
    if (status != U_BUFFER_OVERFLOW_ERROR && U_FAILURE(status)) {
        return tsonic_intl_icu_failure(status);
    }
    if (required < 0 || required > TSONIC_INTL_MAX_UNITS) {
        return tsonic_intl_failure("Locale-sensitive case conversion exceeds the string limit");
    }
    TsonicIntlResult *result = calloc(1, sizeof(*result));
    if (result == NULL) return NULL;
    if (required == 0) return result;
    result->units = malloc((size_t)required * sizeof(*result->units));
    if (result->units == NULL) {
        free(result);
        return tsonic_intl_failure("Unable to allocate locale-sensitive string");
    }
    status = U_ZERO_ERROR;
    int32_t written = upper
        ? u_strToUpper((UChar *)result->units, required, (const UChar *)source,
            (int32_t)length, locale, &status)
        : u_strToLower((UChar *)result->units, required, (const UChar *)source,
            (int32_t)length, locale, &status);
    if (U_FAILURE(status) || written != required) {
        tsonic_js_intl_free(result);
        return tsonic_intl_icu_failure(U_FAILURE(status) ? status : U_INTERNAL_PROGRAM_ERROR);
    }
    result->length = (size_t)written;
    return result;
}
