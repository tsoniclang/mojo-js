#include "model.h"
#include <stdlib.h>
#include <string.h>
#include <unicode/ucurr.h>
#include <unicode/uloc.h>
#include <unicode/unum.h>
#include <unicode/unumberformatter.h>

static int bounded_ascii(const char *value, size_t limit) {
    if (value == NULL) return 0;
    for (size_t index = 0; index <= limit; ++index) {
        if (value[index] == '\0') return 1;
        if ((unsigned char)value[index] > 127) return 0;
    }
    return 0;
}

int tsonic_js_intl_number_available(const char *locale) {
    return tsonic_intl_locale_available(locale, unum_countAvailable(), unum_getAvailable);
}

int tsonic_js_intl_currency_digits(const char *currency) {
    if (!bounded_ascii(currency, 3) || strlen(currency) != 3) return -1;
    UChar code[4] = { 0 };
    for (int32_t index = 0; index < 3; ++index) {
        if (currency[index] < 'A' || currency[index] > 'Z') return -1;
        code[index] = currency[index];
    }
    UErrorCode status = U_ZERO_ERROR;
    int32_t digits = ucurr_getDefaultFractionDigits(code, &status);
    return U_SUCCESS(status) && digits >= 0 && digits <= 100 ? digits : -1;
}

static TsonicIntlResult *formatted_result(const UFormattedNumber *formatted) {
    UErrorCode status = U_ZERO_ERROR;
    int32_t length = unumf_resultToString(formatted, NULL, 0, &status);
    if (status != U_BUFFER_OVERFLOW_ERROR && U_FAILURE(status)) return tsonic_intl_icu_failure(status);
    if (length < 0 || length > TSONIC_INTL_MAX_UNITS) {
        return tsonic_intl_failure("Localized number exceeds its finite output limit");
    }
    TsonicIntlResult *result = calloc(1, sizeof(*result));
    if (result == NULL) return NULL;
    result->units = malloc(((size_t)length + 1) * sizeof(*result->units));
    if (result->units == NULL) {
        free(result);
        return tsonic_intl_failure("Unable to allocate localized number output");
    }
    status = U_ZERO_ERROR;
    int32_t written = unumf_resultToString(formatted, (UChar *)result->units, length + 1, &status);
    if (U_FAILURE(status) || written != length) {
        tsonic_js_intl_free(result);
        return tsonic_intl_icu_failure(U_FAILURE(status) ? status : U_INTERNAL_PROGRAM_ERROR);
    }
    result->length = (size_t)length;
    return result;
}

TsonicIntlResult *tsonic_js_intl_number(double value, const char *decimal,
    const char *locale, const char *numbering, const char *skeleton) {
    if (!bounded_ascii(locale, TSONIC_INTL_MAX_LOCALE) || !bounded_ascii(numbering, 128) ||
        !bounded_ascii(skeleton, 1024) || (decimal != NULL && !bounded_ascii(decimal, 128))) {
        return tsonic_intl_failure("Invalid localized number contract");
    }
    if (decimal != NULL) {
        size_t length = strlen(decimal), index = decimal[0] == '-' ? 1 : 0;
        if (length == index) return tsonic_intl_failure("Exact localized integer is empty");
        for (; index < length; ++index) {
            if (decimal[index] < '0' || decimal[index] > '9') {
                return tsonic_intl_failure("Exact localized integer contains a non-digit");
            }
        }
    }
    UErrorCode status = U_ZERO_ERROR;
    char selected[TSONIC_INTL_MAX_LOCALE + 1];
    uloc_canonicalize(locale, selected, sizeof(selected), &status);
    tsonic_intl_numbering(selected, sizeof(selected), numbering, &status);
    if (U_FAILURE(status)) return tsonic_intl_icu_failure(status);
    UChar pattern[1025];
    int32_t length = (int32_t)strlen(skeleton);
    for (int32_t index = 0; index < length; ++index) pattern[index] = skeleton[index];
    UNumberFormatter *formatter = unumf_openForSkeletonAndLocale(pattern, length, selected, &status);
    UFormattedNumber *formatted = U_SUCCESS(status) ? unumf_openResult(&status) : NULL;
    if (U_FAILURE(status) || formatter == NULL || formatted == NULL) {
        unumf_closeResult(formatted);
        unumf_close(formatter);
        return tsonic_intl_icu_failure(U_FAILURE(status) ? status : U_MEMORY_ALLOCATION_ERROR);
    }
    if (decimal == NULL) unumf_formatDouble(formatter, value, formatted, &status);
    else unumf_formatDecimal(formatter, decimal, (int32_t)strlen(decimal), formatted, &status);
    TsonicIntlResult *result = U_FAILURE(status) ? tsonic_intl_icu_failure(status) : formatted_result(formatted);
    unumf_closeResult(formatted);
    unumf_close(formatter);
    return result;
}
