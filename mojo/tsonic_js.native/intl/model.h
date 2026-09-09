#ifndef TSONIC_JS_INTL_MODEL_H
#define TSONIC_JS_INTL_MODEL_H

#include "api.h"
#include <unicode/utypes.h>

#define TSONIC_INTL_MAX_UNITS 16777216
#define TSONIC_INTL_MAX_LOCALE 4096

struct TsonicIntlResult {
    uint16_t *units;
    char *text;
    size_t length;
    int order;
    int failed;
    char error[192];
};

TsonicIntlResult *tsonic_intl_failure(const char *message);
TsonicIntlResult *tsonic_intl_icu_failure(UErrorCode status);
int tsonic_intl_valid_units(const uint16_t *source, size_t length);
int tsonic_intl_valid_tag(const char *tag, size_t length);
int tsonic_intl_locale_available(const char *locale, int32_t count,
    const char *(*available)(int32_t));
void tsonic_intl_numbering(char *locale, int32_t capacity,
    const char *numbering, UErrorCode *status);

#endif
