#include "date_model.h"
#include <stdlib.h>
#include <string.h>
#include <unicode/ucal.h>
#include <unicode/uloc.h>
#include <unicode/ustring.h>

static int32_t adapt_hours(UChar *skeleton, int32_t length, UChar hour) {
    int32_t output = 0;
    for (int32_t index = 0; index < length; ++index) {
        UChar field = skeleton[index];
        if (field == 'h' || field == 'H' || field == 'K' || field == 'k' || field == 'j') field = hour;
        if ((hour == 'H' || hour == 'k') && (field == 'a' || field == 'b' || field == 'B')) continue;
        skeleton[output++] = field;
    }
    return output;
}

static UChar pattern_hour(const UChar *pattern, int32_t length) {
    int quoted = 0;
    for (int32_t index = 0; index < length; ++index) {
        UChar symbol = pattern[index];
        if (symbol == '\'') {
            if (index + 1 < length && pattern[index + 1] == '\'') ++index;
            else quoted = !quoted;
        } else if (!quoted && (symbol == 'h' || symbol == 'H' || symbol == 'K' || symbol == 'k')) {
            return symbol;
        }
    }
    return 0;
}

UDateFormat *tsonic_intl_open_date_format(const char *locale, const UChar *zone,
    int32_t zone_length, const char *components, int date_style, int time_style,
    int hour12, const char *hour_cycle, int basic, UErrorCode *status) {
    UChar hour = tsonic_intl_hour_symbol(locale, hour12, hour_cycle, status);
    if (U_FAILURE(*status)) return NULL;
    char generator_locale[TSONIC_INTL_MAX_LOCALE + 1];
    uloc_canonicalize(locale, generator_locale, sizeof(generator_locale), status);
    const char *cycle = hour == 'K' ? "h11" : hour == 'h' ? "h12" : hour == 'H' ? "h23" : "h24";
    uloc_setKeywordValue("hours", cycle, generator_locale, sizeof(generator_locale), status);
    UDateTimePatternGenerator *generator = udatpg_open(generator_locale, status);
    if (U_FAILURE(*status) || generator == NULL) return NULL;
    UDateFormat *format = NULL;
    UChar skeleton[256];
    int32_t skeleton_length = 0;
    if (date_style != UDAT_NONE || time_style != UDAT_NONE) {
        format = udat_open((UDateFormatStyle)time_style, (UDateFormatStyle)date_style,
            locale, zone, zone_length, NULL, 0, status);
        char locale_cycle[16];
        int32_t locale_cycle_length = uloc_getKeywordValue(locale, "hours", locale_cycle, sizeof(locale_cycle), status);
        if (U_FAILURE(*status) || format == NULL || (hour12 == -1 && hour_cycle[0] == '\0' && locale_cycle_length == 0)) {
            udatpg_close(generator);
            return format;
        }
        UChar original[2048];
        int32_t length = udat_toPattern(format, 0, original, 2048, status);
        if (U_SUCCESS(*status)) {
            UChar current_hour = pattern_hour(original, length);
            if (current_hour == 0 || current_hour == hour) {
                udatpg_close(generator);
                return format;
            }
        }
        if (U_SUCCESS(*status)) skeleton_length = udatpg_getSkeleton(generator, original, length, skeleton, 256, status);
        udat_close(format);
        format = NULL;
    } else {
        u_strFromUTF8(skeleton, 256, &skeleton_length, components, -1, status);
    }
    if (U_FAILURE(*status)) {
        udatpg_close(generator);
        return NULL;
    }
    skeleton_length = adapt_hours(skeleton, skeleton_length, hour);
    UChar pattern[2048];
    int32_t length = basic && date_style == UDAT_NONE && time_style == UDAT_NONE
        ? tsonic_intl_basic_date_pattern(generator, skeleton, skeleton_length, hour, pattern, 2048, status)
        : udatpg_getBestPatternWithOptions(generator, skeleton, skeleton_length,
            UDATPG_MATCH_HOUR_FIELD_LENGTH, pattern, 2048, status);
    udatpg_close(generator);
    if (U_FAILURE(*status)) return NULL;
    return udat_open(UDAT_PATTERN, UDAT_PATTERN, locale, zone, zone_length, pattern, length, status);
}

int tsonic_intl_proleptic_calendar(UDateFormat *format, UErrorCode *status) {
    UCalendar *calendar = ucal_clone(udat_getCalendar(format), status);
    if (U_FAILURE(*status) || calendar == NULL) return 0;
    const char *type = ucal_getType(calendar, status);
    if (U_SUCCESS(*status) && type != NULL && strcmp(type, "gregorian") == 0) {
        ucal_setGregorianChange(calendar, -8640000000000000.0, status);
        if (U_SUCCESS(*status)) udat_setCalendar(format, calendar);
    }
    ucal_close(calendar);
    return U_SUCCESS(*status);
}

TsonicIntlResult *tsonic_intl_format_date(UDateFormat *format, double timestamp, int parts) {
    UErrorCode status = U_ZERO_ERROR;
    int32_t length = udat_format(format, timestamp, NULL, 0, NULL, &status);
    if (status != U_BUFFER_OVERFLOW_ERROR && U_FAILURE(status)) return tsonic_intl_icu_failure(status);
    if (length < 0 || length > TSONIC_INTL_MAX_UNITS) return tsonic_intl_failure("Date output exceeds its finite limit");
    TsonicIntlResult *result = calloc(1, sizeof(*result));
    if (result == NULL) return NULL;
    result->units = malloc(((size_t)length + 1) * sizeof(*result->units));
    if (result->units == NULL) {
        tsonic_js_intl_free(result);
        return tsonic_intl_failure("Unable to allocate localized date");
    }
    status = U_ZERO_ERROR;
    UFieldPositionIterator *positions = parts ? ufieldpositer_open(&status) : NULL;
    if (U_FAILURE(status) || (parts && positions == NULL)) {
        ufieldpositer_close(positions);
        tsonic_js_intl_free(result);
        return tsonic_intl_icu_failure(U_FAILURE(status) ? status : U_MEMORY_ALLOCATION_ERROR);
    }
    int32_t actual = parts
        ? udat_formatForFields(format, timestamp, (UChar *)result->units, length + 1, positions, &status)
        : udat_format(format, timestamp, (UChar *)result->units, length + 1, NULL, &status);
    if (U_FAILURE(status) || actual != length) {
        ufieldpositer_close(positions);
        tsonic_js_intl_free(result);
        return tsonic_intl_failure("Unable to format a consistent localized date");
    }
    result->length = (size_t)length;
    if (parts) tsonic_intl_date_parts(result, positions);
    ufieldpositer_close(positions);
    return result;
}
