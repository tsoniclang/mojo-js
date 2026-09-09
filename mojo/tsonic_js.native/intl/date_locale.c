#include "date_model.h"
#include <ctype.h>
#include <string.h>
#include <unicode/ucal.h>
#include <unicode/uenum.h>
#include <unicode/uloc.h>
#include <unicode/unumsys.h>
#include <unicode/ures.h>
#include <unicode/ustring.h>

int tsonic_intl_date_locale(const char *locale, const char *calendar,
    const char *numbering, char *result, int32_t capacity, UErrorCode *status) {
    uloc_canonicalize(locale, result, capacity, status);
    if (U_FAILURE(*status)) return 0;
    if (calendar[0] != '\0') {
        const char *requested = uloc_toLegacyType("calendar", calendar);
        UEnumeration *values = ucal_getKeywordValuesForLocale("calendar", result, 0, status);
        const char *value;
        while (U_SUCCESS(*status) && values != NULL &&
            (value = uenum_next(values, NULL, status)) != NULL) {
            if (requested != NULL && strcmp(value, requested) == 0) {
                uloc_setKeywordValue("calendar", requested, result, capacity, status);
                break;
            }
        }
        uenum_close(values);
    }
    if (numbering[0] != '\0' && U_SUCCESS(*status)) {
        UErrorCode supported = U_ZERO_ERROR;
        UNumberingSystem *system = unumsys_openByName(numbering, &supported);
        if (U_SUCCESS(supported) && system != NULL && !unumsys_isAlgorithmic(system)) {
            uloc_setKeywordValue("numbers", numbering, result, capacity, status);
        } else if (supported != U_UNSUPPORTED_ERROR && U_FAILURE(supported)) {
            *status = supported;
        }
        unumsys_close(system);
    }
    return U_SUCCESS(*status);
}

int tsonic_js_intl_date_available(const char *locale) {
    if (locale == NULL || strlen(locale) > TSONIC_INTL_MAX_LOCALE) return 0;
    char base[TSONIC_INTL_MAX_LOCALE + 1];
    UErrorCode status = U_ZERO_ERROR;
    uloc_getBaseName(locale, base, sizeof(base), &status);
    if (U_FAILURE(status)) return 0;
    while (base[0] != '\0') {
        for (int32_t index = 0; index < udat_countAvailable(); ++index) {
            if (strcmp(base, udat_getAvailable(index)) == 0) return 1;
        }
        char *separator = strrchr(base, '_');
        if (separator == NULL) break;
        *separator = '\0';
    }
    return 0;
}

static int32_t offset_zone(const char *zone, UChar *result, UErrorCode *status) {
    size_t length = strlen(zone);
    if (length != 3 && length != 5 && length != 6) {
        *status = U_ILLEGAL_ARGUMENT_ERROR;
        return 0;
    }
    if (!isdigit((unsigned char)zone[1]) || !isdigit((unsigned char)zone[2])) {
        *status = U_ILLEGAL_ARGUMENT_ERROR;
        return 0;
    }
    int hours = (zone[1] - '0') * 10 + zone[2] - '0';
    int minutes = 0;
    if (length > 3) {
        size_t index = length == 6 ? 4 : 3;
        if ((length == 6 && zone[3] != ':') ||
            !isdigit((unsigned char)zone[index]) || !isdigit((unsigned char)zone[index + 1])) {
            *status = U_ILLEGAL_ARGUMENT_ERROR;
            return 0;
        }
        minutes = (zone[index] - '0') * 10 + zone[index + 1] - '0';
    }
    if (hours > 23 || minutes > 59) {
        *status = U_ILLEGAL_ARGUMENT_ERROR;
        return 0;
    }
    const char prefix[] = "GMT";
    for (int32_t index = 0; index < 3; ++index) result[index] = prefix[index];
    result[3] = zone[0];
    result[4] = '0' + hours / 10;
    result[5] = '0' + hours % 10;
    result[6] = ':';
    result[7] = '0' + minutes / 10;
    result[8] = '0' + minutes % 10;
    return 9;
}

int32_t tsonic_intl_date_zone(const char *zone, UChar *result,
    int32_t capacity, UErrorCode *status) {
    if (zone == NULL) return 0;
    size_t length = strlen(zone);
    if (length == 0 || length >= (size_t)capacity || capacity < 10) {
        *status = U_ILLEGAL_ARGUMENT_ERROR;
        return 0;
    }
    if (zone[0] == '+' || zone[0] == '-') return offset_zone(zone, result, status);
    for (size_t index = 0; index < length; ++index) {
        if ((unsigned char)zone[index] > 127) {
            *status = U_ILLEGAL_ARGUMENT_ERROR;
            return 0;
        }
    }
    UChar requested[512];
    int32_t requested_length = 0;
    u_strFromUTF8(requested, 512, &requested_length, zone, (int32_t)length, status);
    if (U_FAILURE(*status)) return 0;
    UEnumeration *zones = ucal_openTimeZones(status);
    const UChar *candidate;
    int32_t candidate_length = 0;
    int32_t selected_length = 0;
    while (U_SUCCESS(*status) && zones != NULL &&
        (candidate = uenum_unext(zones, &candidate_length, status)) != NULL) {
        if (u_strCaseCompare(requested, requested_length, candidate, candidate_length, 0, status) == 0) {
            if (candidate_length >= capacity) *status = U_BUFFER_OVERFLOW_ERROR;
            else {
                memcpy(result, candidate, (size_t)candidate_length * sizeof(*result));
                selected_length = candidate_length;
            }
            break;
        }
    }
    uenum_close(zones);
    if (selected_length == 0 && U_SUCCESS(*status)) *status = U_ILLEGAL_ARGUMENT_ERROR;
    if (U_SUCCESS(*status)) {
        UChar canonical[512];
        UBool system = 0;
        ucal_getCanonicalTimeZoneID(result, selected_length, canonical, 512, &system, status);
        if (U_SUCCESS(*status) && !system) *status = U_ILLEGAL_ARGUMENT_ERROR;
    }
    return selected_length;
}

static UChar regional_hour(const char *locale, int twelve, UErrorCode *status) {
    char expanded[TSONIC_INTL_MAX_LOCALE + 1];
    char region[ULOC_COUNTRY_CAPACITY];
    uloc_addLikelySubtags(locale, expanded, sizeof(expanded), status);
    uloc_getCountry(expanded, region, sizeof(region), status);
    if (U_FAILURE(*status)) return 0;
    UResourceBundle *root = ures_openDirect(NULL, "supplementalData", status);
    UResourceBundle *data = ures_getByKey(root, "timeData", NULL, status);
    UResourceBundle *territory = ures_getByKey(data, region, NULL, status);
    if (*status == U_MISSING_RESOURCE_ERROR) {
        *status = U_ZERO_ERROR;
        ures_close(territory);
        territory = ures_getByKey(data, "001", NULL, status);
    }
    UResourceBundle *allowed = ures_getByKey(territory, "allowed", NULL, status);
    UChar selected = 0;
    if (U_SUCCESS(*status)) {
        int32_t count = ures_getSize(allowed);
        for (int32_t index = 0; index < count; ++index) {
            int32_t length = 0;
            const UChar *value = ures_getStringByIndex(allowed, index, &length, status);
            if (U_FAILURE(*status)) break;
            if (length > 0 && ((twelve && (value[0] == 'h' || value[0] == 'K')) ||
                (!twelve && (value[0] == 'H' || value[0] == 'k')))) {
                selected = value[0];
                break;
            }
        }
    }
    ures_close(allowed);
    ures_close(territory);
    ures_close(data);
    ures_close(root);
    if (selected == 0 && U_SUCCESS(*status)) *status = U_MISSING_RESOURCE_ERROR;
    return selected;
}

UChar tsonic_intl_hour_symbol(const char *locale, int hour12,
    const char *cycle, UErrorCode *status) {
    if (hour12 == -1 && cycle[0] != '\0') {
        if (strcmp(cycle, "h11") == 0) return 'K';
        if (strcmp(cycle, "h12") == 0) return 'h';
        if (strcmp(cycle, "h23") == 0) return 'H';
        if (strcmp(cycle, "h24") == 0) return 'k';
        *status = U_ILLEGAL_ARGUMENT_ERROR;
        return 0;
    }
    char selected[TSONIC_INTL_MAX_LOCALE + 1];
    uloc_canonicalize(locale, selected, sizeof(selected), status);
    if (hour12 != -1) uloc_setKeywordValue("hours", NULL, selected, sizeof(selected), status);
    UDateTimePatternGenerator *generator = udatpg_open(selected, status);
    if (U_FAILURE(*status) || generator == NULL) return 0;
    UDateFormatHourCycle preferred = udatpg_getDefaultHourCycle(generator, status);
    udatpg_close(generator);
    if (U_FAILURE(*status)) return 0;
    UChar symbol = preferred == UDAT_HOUR_CYCLE_11 ? 'K' : preferred == UDAT_HOUR_CYCLE_12 ? 'h' :
        preferred == UDAT_HOUR_CYCLE_23 ? 'H' : 'k';
    if (hour12 == -1 || (hour12 == 1 && (symbol == 'K' || symbol == 'h')) ||
        (hour12 == 0 && (symbol == 'H' || symbol == 'k'))) return symbol;
    return regional_hour(selected, hour12, status);
}
