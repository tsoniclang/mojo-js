#include "date_model.h"
#include <string.h>
#include <unicode/uloc.h>
#include <unicode/unumsys.h>
#include <unicode/ustring.h>

static int text_copy(char *destination, size_t capacity, const char *source, UErrorCode *status) {
    if (U_FAILURE(*status)) return 0;
    if (source == NULL || strlen(source) >= capacity) {
        *status = U_BUFFER_OVERFLOW_ERROR;
        return 0;
    }
    memcpy(destination, source, strlen(source) + 1);
    return 1;
}

static int resolved_zone(TsonicDateTimeFormat *owner, const char *requested, UErrorCode *status) {
    UChar zone[512], canonical[512];
    if (requested != NULL && (requested[0] == '+' || requested[0] == '-')) {
        int32_t length = tsonic_intl_date_zone(requested, zone, 512, status);
        if (U_FAILURE(*status) || length != 9) return 0;
        int32_t written = 0;
        u_strToUTF8(owner->zone, sizeof(owner->zone), &written, zone + 3, 6, status);
        if (U_SUCCESS(*status) && strcmp(owner->zone, "-00:00") == 0) owner->zone[0] = '+';
        return U_SUCCESS(*status);
    }
    int32_t length = ucal_getTimeZoneID(udat_getCalendar(owner->format), zone, 512, status);
    if (U_FAILURE(*status)) return 0;
    UBool system = 0;
    int32_t canonical_length = ucal_getCanonicalTimeZoneID(zone, length, canonical, 512, &system, status);
    int32_t written = 0;
    if (U_SUCCESS(*status)) u_strToUTF8(owner->zone, sizeof(owner->zone), &written, canonical, canonical_length, status);
    if (U_FAILURE(*status)) return 0;
    if (strcmp(owner->zone, "Etc/UTC") == 0 || strcmp(owner->zone, "Etc/GMT") == 0 || strcmp(owner->zone, "GMT") == 0) {
        memcpy(owner->zone, "UTC", 4);
    } else if (!system && strncmp(owner->zone, "GMT", 3) == 0 && strlen(owner->zone) == 9 &&
        (owner->zone[3] == '+' || owner->zone[3] == '-')) {
        memmove(owner->zone, owner->zone + 3, 7);
    } else if (!system) {
        *status = U_ILLEGAL_ARGUMENT_ERROR;
    }
    return U_SUCCESS(*status);
}

int tsonic_intl_date_metadata(TsonicDateTimeFormat *owner, const char *selected,
    const char *resolved, const char *requested_zone, int hour12, const char *hour_cycle, UErrorCode *status) {
    const char *calendar = ucal_getType(udat_getCalendar(owner->format), status);
    if (U_FAILURE(*status) || calendar == NULL) return 0;
    if (!text_copy(owner->calendar, sizeof(owner->calendar), uloc_toUnicodeLocaleType("ca", calendar), status)) return 0;
    UNumberingSystem *system = unumsys_open(selected, status);
    if (U_FAILURE(*status) || system == NULL) {
        unumsys_close(system);
        return 0;
    }
    int copied = text_copy(owner->numbering, sizeof(owner->numbering), unumsys_getName(system), status);
    unumsys_close(system);
    if (!copied || !resolved_zone(owner, requested_zone, status)) return 0;
    char tag[TSONIC_INTL_MAX_LOCALE + 1];
    if (!text_copy(tag, sizeof(tag), resolved, status)) return 0;
    tsonic_intl_resolved_keyword(tag, sizeof(tag), "calendar", calendar, status);
    tsonic_intl_resolved_keyword(tag, sizeof(tag), "numbers", owner->numbering, status);
    UChar hour = tsonic_intl_hour_symbol(selected, hour12, hour_cycle, status);
    const char *cycle = hour == 'K' ? "h11" : hour == 'h' ? "h12" : hour == 'H' ? "h23" : hour == 'k' ? "h24" : NULL;
    tsonic_intl_resolved_keyword(tag, sizeof(tag), "hours", hour12 == -1 ? cycle : NULL, status);
    if (U_SUCCESS(*status)) uloc_toLanguageTag(tag, owner->locale, sizeof(owner->locale), 1, status);
    return U_SUCCESS(*status);
}
