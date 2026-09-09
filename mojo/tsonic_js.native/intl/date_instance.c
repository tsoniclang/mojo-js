#include "date_model.h"
#include <math.h>
#include <stdlib.h>
#include <string.h>

static int bounded(const char *value, size_t limit) {
    return value != NULL && strlen(value) <= limit;
}

static void close_datetime(void *resource) {
    TsonicDateTimeFormat *owner = resource;
    udat_close(owner->format);
    free(owner);
}

TsonicIntlResult *tsonic_js_intl_datetime_open(const char *locale,
    const char *zone, int has_zone, const char *calendar, const char *numbering,
    const char *skeleton, int date_style, int time_style, int hour12, const char *hour_cycle, int basic) {
    if (!bounded(locale, TSONIC_INTL_MAX_LOCALE) || !bounded(zone, 511) ||
        !bounded(calendar, TSONIC_INTL_MAX_LOCALE) || !bounded(numbering, TSONIC_INTL_MAX_LOCALE) ||
        !bounded(skeleton, 128) || !bounded(hour_cycle, 3) ||
        (has_zone != 0 && has_zone != 1) || (basic != 0 && basic != 1) || hour12 < -1 || hour12 > 1 ||
        date_style < -1 || date_style > 3 || time_style < -1 || time_style > 3 ||
        (hour_cycle[0] != '\0' && strcmp(hour_cycle, "h11") != 0 && strcmp(hour_cycle, "h12") != 0 &&
            strcmp(hour_cycle, "h23") != 0 && strcmp(hour_cycle, "h24") != 0) ||
        ((date_style != -1 || time_style != -1) && skeleton[0] != '\0') ||
        (date_style == -1 && time_style == -1 && skeleton[0] == '\0')) {
        return tsonic_intl_failure("Invalid localized date contract");
    }
    UErrorCode status = U_ZERO_ERROR;
    char selected[TSONIC_INTL_MAX_LOCALE + 1], resolved[TSONIC_INTL_MAX_LOCALE + 1];
    if (!tsonic_intl_date_locale(locale, "", "", resolved, sizeof(resolved), &status) ||
        !tsonic_intl_date_locale(locale, calendar, numbering, selected, sizeof(selected), &status)) {
        return tsonic_intl_icu_failure(status);
    }
    UChar time_zone[512];
    int32_t zone_length = tsonic_intl_date_zone(has_zone ? zone : NULL, time_zone, 512, &status);
    if (U_FAILURE(status)) return tsonic_intl_failure("Invalid time-zone identifier");
    UDateFormat *format = tsonic_intl_open_date_format(selected, has_zone ? time_zone : NULL, zone_length,
        skeleton, date_style, time_style, hour12, hour_cycle, basic, &status);
    if (U_FAILURE(status) || format == NULL || !tsonic_intl_proleptic_calendar(format, &status)) {
        udat_close(format);
        return tsonic_intl_icu_failure(U_FAILURE(status) ? status : U_MEMORY_ALLOCATION_ERROR);
    }
    TsonicIntlResult *result = calloc(1, sizeof(*result));
    TsonicDateTimeFormat *owner = calloc(1, sizeof(*owner));
    if (result == NULL || owner == NULL) {
        free(result);
        free(owner);
        udat_close(format);
        return NULL;
    }
    owner->format = format;
    result->resource = owner;
    result->free_resource = close_datetime;
    if (!tsonic_intl_date_metadata(owner, selected, resolved, has_zone ? zone : NULL, hour12, hour_cycle, &status)) {
        tsonic_js_intl_free(result);
        return tsonic_intl_icu_failure(status);
    }
    return result;
}

TsonicIntlResult *tsonic_js_intl_datetime_format(const TsonicIntlResult *owner, double timestamp, int parts) {
    if (owner == NULL || owner->failed || owner->resource == NULL || owner->free_resource != close_datetime ||
        !isfinite(timestamp) || fabs(timestamp) > 8640000000000000.0 || (parts != 0 && parts != 1)) {
        return tsonic_intl_failure("Invalid retained date formatting operation");
    }
    return tsonic_intl_format_date(((TsonicDateTimeFormat *)owner->resource)->format, trunc(timestamp), parts);
}

const char *tsonic_js_intl_datetime_text(const TsonicIntlResult *result, int field) {
    if (result == NULL || result->failed || result->resource == NULL || result->free_resource != close_datetime) return NULL;
    const TsonicDateTimeFormat *owner = result->resource;
    switch (field) {
        case 0: return owner->locale;
        case 1: return owner->calendar;
        case 2: return owner->numbering;
        case 3: return owner->zone;
        default: return NULL;
    }
}

TsonicIntlResult *tsonic_js_intl_date(double timestamp, const char *locale,
    const char *zone, int has_zone, const char *calendar, const char *numbering,
    const char *skeleton, int date_style, int time_style, int hour12, const char *hour_cycle, int basic) {
    TsonicIntlResult *owner = tsonic_js_intl_datetime_open(locale, zone, has_zone, calendar, numbering,
        skeleton, date_style, time_style, hour12, hour_cycle, basic);
    if (owner == NULL || owner->failed) return owner;
    TsonicIntlResult *result = tsonic_js_intl_datetime_format(owner, timestamp, 0);
    tsonic_js_intl_free(owner);
    return result;
}
