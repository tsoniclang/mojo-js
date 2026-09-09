#include "model.h"
#include <stdlib.h>
#include <string.h>
#include <unicode/ucol.h>
#include <unicode/uenum.h>
#include <unicode/uloc.h>

typedef struct {
    UCollator *collator;
    char locale[TSONIC_INTL_MAX_LOCALE + 1];
    char collation[TSONIC_INTL_MAX_LOCALE + 1];
    int options[5];
} TsonicCollator;

static void close_collator(void *resource) {
    TsonicCollator *owner = resource;
    ucol_close(owner->collator);
    free(owner);
}

static int supported_collation(const char *locale, const char *collation, UErrorCode *status) {
    UEnumeration *values = ucol_getKeywordValuesForLocale("collation", locale, 0, status);
    if (U_FAILURE(*status) || values == NULL) {
        uenum_close(values);
        return 0;
    }
    int found = 0;
    const char *value;
    while ((value = uenum_next(values, NULL, status)) != NULL) {
        if (strcmp(value, collation) == 0) {
            found = 1;
            break;
        }
    }
    uenum_close(values);
    return found;
}

static void selected_locale(const char *locale, char *selected, UErrorCode *status) {
    uloc_getBaseName(locale, selected, TSONIC_INTL_MAX_LOCALE + 1, status);
    if (U_FAILURE(*status)) return;
    for (;;) {
        int found = 0;
        for (int32_t index = 0; index < ucol_countAvailable(); ++index) {
            if (strcmp(selected, ucol_getAvailable(index)) == 0) {
                found = 1;
                break;
            }
        }
        if (found) break;
        char *separator = strrchr(selected, '_');
        if (separator == NULL) {
            *status = U_MISSING_RESOURCE_ERROR;
            return;
        }
        *separator = '\0';
    }
    const char *keys[] = { "collation", "colnumeric", "colcasefirst" };
    for (size_t index = 0; index < sizeof(keys) / sizeof(keys[0]); ++index) {
        char value[TSONIC_INTL_MAX_LOCALE + 1];
        int32_t length = uloc_getKeywordValue(locale, keys[index], value, sizeof(value), status);
        if (U_FAILURE(*status)) return;
        if (length == 0) continue;
        int allowed = index == 0
            ? strcmp(value, "standard") != 0 && strcmp(value, "search") != 0 &&
                supported_collation(locale, value, status)
            : index == 1
                ? strcmp(value, "yes") == 0 || strcmp(value, "no") == 0
                : strcmp(value, "upper") == 0 || strcmp(value, "lower") == 0 ||
                    strcmp(value, "no") == 0;
        if (allowed) uloc_setKeywordValue(keys[index], value, selected,
            TSONIC_INTL_MAX_LOCALE + 1, status);
        if (U_FAILURE(*status)) return;
    }
}

static void remove_overridden_keyword(char *locale, const char *key,
    const char *requested, UErrorCode *status) {
    if (requested == NULL || U_FAILURE(*status)) return;
    char existing[TSONIC_INTL_MAX_LOCALE + 1];
    int32_t length = uloc_getKeywordValue(locale, key, existing, sizeof(existing), status);
    if (U_SUCCESS(*status) && length != 0 && strcmp(existing, requested) != 0) {
        uloc_setKeywordValue(key, NULL, locale, TSONIC_INTL_MAX_LOCALE + 1, status);
    }
}

TsonicIntlResult *tsonic_js_intl_collator_open(
    const char *locale, const char *collation, int search,
    int numeric, int case_first, int sensitivity, int punctuation) {
    if (locale == NULL || collation == NULL ||
        strlen(locale) > TSONIC_INTL_MAX_LOCALE || strlen(collation) > TSONIC_INTL_MAX_LOCALE ||
        search < 0 || search > 1 || numeric < -1 || numeric > 1 ||
        case_first < -1 || case_first > 2 || sensitivity < -1 || sensitivity > 3 ||
        punctuation < -1 || punctuation > 1) {
        return tsonic_intl_failure("Invalid locale comparison contract");
    }
    char selected[TSONIC_INTL_MAX_LOCALE + 1];
    UErrorCode status = U_ZERO_ERROR;
    selected_locale(locale, selected, &status);
    char resolved[TSONIC_INTL_MAX_LOCALE + 1];
    if (U_FAILURE(status)) return tsonic_intl_icu_failure(status);
    memcpy(resolved, selected, strlen(selected) + 1);
    const char *requested = search ? "search" : uloc_toLegacyType("co", collation);
    if (search || (*collation != '\0' && requested != NULL &&
        strcmp(requested, "standard") != 0 && strcmp(requested, "search") != 0 &&
        supported_collation(locale, requested, &status))) {
        uloc_setKeywordValue("collation", requested, selected, sizeof(selected), &status);
        remove_overridden_keyword(resolved, "collation", requested, &status);
    }
    if (search) uloc_setKeywordValue("collation", NULL, resolved, sizeof(resolved), &status);
    remove_overridden_keyword(resolved, "colnumeric", numeric == -1 ? NULL : numeric ? "yes" : "no", &status);
    remove_overridden_keyword(resolved, "colcasefirst", case_first == -1 ? NULL :
        case_first == 1 ? "upper" : case_first == 2 ? "lower" : "no", &status);
    if (U_FAILURE(status)) return tsonic_intl_icu_failure(status);
    UCollator *collator = ucol_open(selected, &status);
    if (U_FAILURE(status) || collator == NULL) {
        ucol_close(collator);
        return tsonic_intl_icu_failure(U_FAILURE(status) ? status : U_MEMORY_ALLOCATION_ERROR);
    }
    ucol_setAttribute(collator, UCOL_NORMALIZATION_MODE, UCOL_ON, &status);
    if (numeric != -1) {
        ucol_setAttribute(collator, UCOL_NUMERIC_COLLATION, numeric ? UCOL_ON : UCOL_OFF, &status);
    }
    if (case_first != -1) {
        UColAttributeValue order = case_first == 1 ? UCOL_UPPER_FIRST :
            case_first == 2 ? UCOL_LOWER_FIRST : UCOL_OFF;
        ucol_setAttribute(collator, UCOL_CASE_FIRST, order, &status);
    }
    if (sensitivity == -1 && !search) sensitivity = 3;
    if (sensitivity != -1) {
        UColAttributeValue strength = sensitivity == 1 ? UCOL_SECONDARY :
            sensitivity == 3 ? UCOL_TERTIARY : UCOL_PRIMARY;
        ucol_setAttribute(collator, UCOL_STRENGTH, strength, &status);
        ucol_setAttribute(collator, UCOL_CASE_LEVEL, sensitivity == 2 ? UCOL_ON : UCOL_OFF, &status);
    }
    if (punctuation != -1) {
        ucol_setAttribute(collator, UCOL_ALTERNATE_HANDLING,
            punctuation ? UCOL_SHIFTED : UCOL_NON_IGNORABLE, &status);
    }
    ucol_setMaxVariable(collator, UCOL_REORDER_CODE_PUNCTUATION, &status);
    if (U_FAILURE(status)) {
        ucol_close(collator);
        return tsonic_intl_icu_failure(status);
    }
    TsonicIntlResult *result = calloc(1, sizeof(*result));
    TsonicCollator *owner = calloc(1, sizeof(*owner));
    if (result == NULL || owner == NULL) {
        ucol_close(collator);
        free(result);
        free(owner);
        return NULL;
    }
    owner->collator = collator;
    result->resource = owner;
    result->free_resource = close_collator;
    uloc_toLanguageTag(resolved, owner->locale, sizeof(owner->locale), 1, &status);
    char native_collation[TSONIC_INTL_MAX_LOCALE + 1];
    int32_t collation_length = uloc_getKeywordValue(selected, "collation", native_collation, sizeof(native_collation), &status);
    const char *resolved_collation = !search && collation_length != 0
        ? uloc_toUnicodeLocaleType("co", native_collation) : "default";
    if (resolved_collation == NULL || strlen(resolved_collation) > TSONIC_INTL_MAX_LOCALE) {
        status = U_INTERNAL_PROGRAM_ERROR;
    } else {
        memcpy(owner->collation, resolved_collation, strlen(resolved_collation) + 1);
    }
    UColAttributeValue strength = ucol_getAttribute(collator, UCOL_STRENGTH, &status);
    UColAttributeValue case_level = ucol_getAttribute(collator, UCOL_CASE_LEVEL, &status);
    UColAttributeValue order = ucol_getAttribute(collator, UCOL_CASE_FIRST, &status);
    owner->options[0] = search;
    owner->options[1] = strength == UCOL_PRIMARY ? case_level == UCOL_ON ? 2 : 0 : strength == UCOL_SECONDARY ? 1 : 3;
    owner->options[2] = ucol_getAttribute(collator, UCOL_ALTERNATE_HANDLING, &status) == UCOL_SHIFTED;
    owner->options[3] = ucol_getAttribute(collator, UCOL_NUMERIC_COLLATION, &status) == UCOL_ON;
    owner->options[4] = order == UCOL_UPPER_FIRST ? 1 : order == UCOL_LOWER_FIRST ? 2 : 0;
    if (U_FAILURE(status)) {
        tsonic_js_intl_free(result);
        return tsonic_intl_icu_failure(status);
    }
    return result;
}

static const TsonicCollator *collator_resource(const TsonicIntlResult *owner) {
    return owner != NULL && !owner->failed && owner->free_resource == close_collator
        ? owner->resource : NULL;
}

TsonicIntlResult *tsonic_js_intl_collator_compare(const TsonicIntlResult *owner,
    const uint16_t *left, size_t left_length, const uint16_t *right, size_t right_length) {
    const TsonicCollator *resource = collator_resource(owner);
    if (resource == NULL || !tsonic_intl_valid_units(left, left_length) ||
        !tsonic_intl_valid_units(right, right_length)) {
        return tsonic_intl_failure("Invalid retained collator comparison");
    }
    TsonicIntlResult *result = calloc(1, sizeof(*result));
    if (result != NULL) result->order = (int)ucol_strcoll(resource->collator,
        (const UChar *)left, (int32_t)left_length, (const UChar *)right, (int32_t)right_length);
    return result;
}

const char *tsonic_js_intl_collator_text(const TsonicIntlResult *owner, int field) {
    const TsonicCollator *resource = collator_resource(owner);
    if (resource == NULL) return NULL;
    return field == 0 ? resource->locale : field == 1 ? resource->collation : NULL;
}

int tsonic_js_intl_collator_option(const TsonicIntlResult *owner, int field) {
    const TsonicCollator *resource = collator_resource(owner);
    return resource == NULL || field < 0 || field >= 5 ? -1 : resource->options[field];
}

TsonicIntlResult *tsonic_js_intl_compare(
    const uint16_t *left, size_t left_length, const uint16_t *right, size_t right_length,
    const char *locale, const char *collation, int search,
    int numeric, int case_first, int sensitivity, int punctuation) {
    TsonicIntlResult *owner = tsonic_js_intl_collator_open(locale, collation, search,
        numeric, case_first, sensitivity, punctuation);
    if (tsonic_js_intl_failed(owner)) return owner;
    TsonicIntlResult *result = tsonic_js_intl_collator_compare(owner, left, left_length, right, right_length);
    tsonic_js_intl_free(owner);
    return result;
}
