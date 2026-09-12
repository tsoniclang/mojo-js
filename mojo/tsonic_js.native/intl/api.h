#ifndef TSONIC_JS_INTL_API_H
#define TSONIC_JS_INTL_API_H

#include <stddef.h>
#include <stdint.h>

typedef struct TsonicIntlResult TsonicIntlResult;

TsonicIntlResult *tsonic_js_intl_locale(const char *tag, size_t length);
TsonicIntlResult *tsonic_js_intl_default_locale(void);
int tsonic_js_intl_collation_available(const char *locale);
int tsonic_js_intl_date_available(const char *locale);
int tsonic_js_intl_number_available(const char *locale);
int tsonic_js_intl_currency_digits(const char *currency);
TsonicIntlResult *tsonic_js_intl_number(double value, const char *decimal,
    const char *locale, const char *numbering, const char *skeleton);
TsonicIntlResult *tsonic_js_intl_number_formatter_open(const char *locale,
    const char *numbering, const char *skeleton, int unit_style);
TsonicIntlResult *tsonic_js_intl_number_formatter_format(const TsonicIntlResult *owner,
    double value, const char *decimal, int parts);
const char *tsonic_js_intl_number_formatter_text(const TsonicIntlResult *owner, int field);
TsonicIntlResult *tsonic_js_intl_date(double timestamp, const char *locale,
    const char *zone, int has_zone, const char *calendar, const char *numbering,
    const char *skeleton, int date_style, int time_style, int hour12, const char *hour_cycle, int basic);
TsonicIntlResult *tsonic_js_intl_datetime_open(const char *locale,
    const char *zone, int has_zone, const char *calendar, const char *numbering,
    const char *skeleton, int date_style, int time_style, int hour12, const char *hour_cycle, int basic);
TsonicIntlResult *tsonic_js_intl_datetime_format(const TsonicIntlResult *owner, double timestamp, int parts);
const char *tsonic_js_intl_datetime_text(const TsonicIntlResult *owner, int field);
TsonicIntlResult *tsonic_js_intl_case(
    const uint16_t *source, size_t length, const char *locale, int upper);
TsonicIntlResult *tsonic_js_intl_compare(
    const uint16_t *left, size_t left_length,
    const uint16_t *right, size_t right_length,
    const char *locale, const char *collation, int search,
    int numeric, int case_first, int sensitivity, int punctuation);
TsonicIntlResult *tsonic_js_intl_collator_open(const char *locale,
    const char *collation, int search, int numeric, int case_first,
    int sensitivity, int punctuation);
TsonicIntlResult *tsonic_js_intl_collator_compare(const TsonicIntlResult *owner,
    const uint16_t *left, size_t left_length, const uint16_t *right, size_t right_length);
const char *tsonic_js_intl_collator_text(const TsonicIntlResult *owner, int field);
int tsonic_js_intl_collator_option(const TsonicIntlResult *owner, int field);
int tsonic_js_intl_failed(const TsonicIntlResult *result);
const char *tsonic_js_intl_error(const TsonicIntlResult *result);
const char *tsonic_js_intl_text(const TsonicIntlResult *result);
const uint16_t *tsonic_js_intl_units(const TsonicIntlResult *result);
size_t tsonic_js_intl_length(const TsonicIntlResult *result);
int tsonic_js_intl_order(const TsonicIntlResult *result);
size_t tsonic_js_intl_part_count(const TsonicIntlResult *result);
const char *tsonic_js_intl_part_type(const TsonicIntlResult *result, size_t index);
size_t tsonic_js_intl_part_start(const TsonicIntlResult *result, size_t index);
size_t tsonic_js_intl_part_length(const TsonicIntlResult *result, size_t index);
void tsonic_js_intl_free(TsonicIntlResult *result);

#endif
