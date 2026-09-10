#ifndef TSONIC_JS_INTL_DATE_MODEL_H
#define TSONIC_JS_INTL_DATE_MODEL_H

#include "model.h"
#include <unicode/udatpg.h>

typedef struct {
    UDateFormat *format;
    char locale[TSONIC_INTL_MAX_LOCALE + 1];
    char calendar[TSONIC_INTL_MAX_LOCALE + 1];
    char numbering[TSONIC_INTL_MAX_LOCALE + 1];
    char zone[512];
} TsonicDateTimeFormat;

UDateFormat *tsonic_intl_open_date_format(const char *locale, const UChar *zone,
    int32_t zone_length, const char *components, int date_style, int time_style,
    int hour12, const char *hour_cycle, int basic, UErrorCode *status);
int tsonic_intl_proleptic_calendar(UDateFormat *format, UErrorCode *status);
TsonicIntlResult *tsonic_intl_format_date(UDateFormat *format, double timestamp, int parts);
int tsonic_intl_date_metadata(TsonicDateTimeFormat *owner, const char *selected,
    const char *resolved, const char *requested_zone, int hour12, const char *hour_cycle, UErrorCode *status);
int tsonic_intl_date_parts(TsonicIntlResult *result, UFieldPositionIterator *positions);
int tsonic_intl_date_locale(const char *locale, const char *calendar,
    const char *numbering, char *result, int32_t capacity, UErrorCode *status);
int32_t tsonic_intl_date_zone(const char *zone, UChar *result,
    int32_t capacity, UErrorCode *status);
UChar tsonic_intl_hour_symbol(const char *locale, int hour12,
    const char *cycle, UErrorCode *status);
int tsonic_intl_date_pattern_score(const UChar *requested, int32_t requested_length,
    const UChar *candidate, int32_t candidate_length, UErrorCode *status);
int32_t tsonic_intl_basic_date_pattern(UDateTimePatternGenerator *generator,
    const UChar *requested, int32_t requested_length, UChar hour,
    UChar *pattern, int32_t capacity, UErrorCode *status);

#endif
