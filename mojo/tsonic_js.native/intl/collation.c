#include "model.h"
#include <stdlib.h>
#include <string.h>
#include <unicode/ucol.h>
#include <unicode/uenum.h>
#include <unicode/uloc.h>

static int supported_collation(const char *locale, const char *collation, UErrorCode *status) {
    UEnumeration *values = ucol_getKeywordValuesForLocale("collation", locale, 0, status);
    if (U_FAILURE(*status) || values == NULL) return 0;
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

TsonicIntlResult *tsonic_js_intl_compare(
    const uint16_t *left, size_t left_length,
    const uint16_t *right, size_t right_length,
    const char *locale, const char *collation, int search,
    int numeric, int case_first, int sensitivity, int punctuation) {
    if (!tsonic_intl_valid_units(left, left_length) ||
        !tsonic_intl_valid_units(right, right_length) || locale == NULL || collation == NULL ||
        strlen(locale) > TSONIC_INTL_MAX_LOCALE || strlen(collation) > TSONIC_INTL_MAX_LOCALE ||
        search < 0 || search > 1 || numeric < -1 || numeric > 1 ||
        case_first < -1 || case_first > 2 || sensitivity < -1 || sensitivity > 3 ||
        punctuation < -1 || punctuation > 1) {
        return tsonic_intl_failure("Invalid locale comparison contract");
    }
    char selected[TSONIC_INTL_MAX_LOCALE + 1];
    UErrorCode status = U_ZERO_ERROR;
    selected_locale(locale, selected, &status);
    const char *requested = search ? "search" : uloc_toLegacyType("co", collation);
    if (search || (*collation != '\0' && requested != NULL &&
        strcmp(requested, "standard") != 0 && strcmp(requested, "search") != 0 &&
        supported_collation(locale, requested, &status))) {
        uloc_setKeywordValue("collation", requested, selected, sizeof(selected), &status);
    }
    if (U_FAILURE(status)) return tsonic_intl_icu_failure(status);
    UCollator *collator = ucol_open(selected, &status);
    if (U_FAILURE(status) || collator == NULL) return tsonic_intl_icu_failure(status);
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
    if (result != NULL) {
        result->order = (int)ucol_strcoll(collator,
            (const UChar *)left, (int32_t)left_length,
            (const UChar *)right, (int32_t)right_length);
    }
    ucol_close(collator);
    return result;
}
