#include <unicode/ucal.h>

#include <math.h>
#include <pthread.h>
#include <stdint.h>

static pthread_mutex_t host_timezone_mutex = PTHREAD_MUTEX_INITIALIZER;

static UCalendar *open_calendar(UErrorCode *status) {
    UChar timezone[512];
    if (pthread_mutex_lock(&host_timezone_mutex) != 0) {
        *status = U_INTERNAL_PROGRAM_ERROR;
        return NULL;
    }
    int32_t length = ucal_getHostTimeZone(timezone, 512, status);
    if (pthread_mutex_unlock(&host_timezone_mutex) != 0) {
        *status = U_INTERNAL_PROGRAM_ERROR;
        return NULL;
    }
    if (U_FAILURE(*status)) return NULL;
    UCalendar *calendar = ucal_open(
        timezone, length, "en_US_POSIX", UCAL_GREGORIAN, status
    );
    if (calendar != NULL && U_SUCCESS(*status)) {
        ucal_setGregorianChange(calendar, -8640000000000000.0, status);
    }
    if (U_FAILURE(*status)) {
        if (calendar != NULL) ucal_close(calendar);
        return NULL;
    }
    return calendar;
}

int tsonic_js_date_zone_offset(
    double milliseconds,
    int local,
    int32_t *offset
) {
    if (offset == NULL || !isfinite(milliseconds)) return U_ILLEGAL_ARGUMENT_ERROR;
    UErrorCode status = U_ZERO_ERROR;
    UCalendar *calendar = open_calendar(&status);
    if (calendar == NULL) return U_FAILURE(status) ? status : U_MEMORY_ALLOCATION_ERROR;
    ucal_setMillis(calendar, milliseconds, &status);
    int32_t raw = 0;
    int32_t daylight = 0;
    if (U_SUCCESS(status)) {
        if (local) {
            ucal_getTimeZoneOffsetFromLocal(
                calendar, UCAL_TZ_LOCAL_FORMER, UCAL_TZ_LOCAL_FORMER,
                &raw, &daylight, &status
            );
        } else {
            raw = ucal_get(calendar, UCAL_ZONE_OFFSET, &status);
            daylight = ucal_get(calendar, UCAL_DST_OFFSET, &status);
        }
    }
    ucal_close(calendar);
    if (U_FAILURE(status)) return status;
    *offset = raw + daylight;
    return 0;
}

int tsonic_js_date_zone_name(
    double milliseconds,
    uint16_t *output,
    int32_t capacity,
    int32_t *length
) {
    if (!isfinite(milliseconds) || output == NULL || length == NULL || capacity <= 0) {
        return U_ILLEGAL_ARGUMENT_ERROR;
    }
    UErrorCode status = U_ZERO_ERROR;
    UCalendar *calendar = open_calendar(&status);
    if (calendar == NULL) return U_FAILURE(status) ? status : U_MEMORY_ALLOCATION_ERROR;
    ucal_setMillis(calendar, milliseconds, &status);
    int32_t daylight = ucal_get(calendar, UCAL_DST_OFFSET, &status);
    *length = ucal_getTimeZoneDisplayName(
        calendar, daylight == 0 ? UCAL_STANDARD : UCAL_DST,
        "en", (UChar *)output, capacity, &status
    );
    ucal_close(calendar);
    return U_FAILURE(status) ? status : 0;
}
