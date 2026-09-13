#ifndef TSONIC_JS_INTL_NUMBER_MODEL_H
#define TSONIC_JS_INTL_NUMBER_MODEL_H

#include "model.h"
#include <unicode/unumberformatter.h>

typedef struct {
    UNumberFormatter *format;
    int unit_style;
    char locale[TSONIC_INTL_MAX_LOCALE + 1];
    char numbering[TSONIC_INTL_MAX_LOCALE + 1];
} TsonicNumberFormat;

TsonicIntlResult *tsonic_intl_format_number(const UNumberFormatter *formatter,
    double value, const char *decimal, int parts, int unit_style);
int tsonic_intl_number_parts(TsonicIntlResult *result,
    const UFormattedNumber *formatted, int negative, int special, int unit_style);

#endif
