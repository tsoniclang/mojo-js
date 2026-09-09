#include "../../mojo/tsonic_js.native/intl/api.h"
#include "../../mojo/tsonic_js.native/intl/date_model.h"
#include <assert.h>
#include <math.h>
#include <string.h>

static void expect_locale(const char *tag, int valid) {
    TsonicIntlResult *result = tsonic_js_intl_locale(tag, strlen(tag));
    assert(result != NULL);
    assert(tsonic_js_intl_failed(result) == !valid);
    if (valid) assert(tsonic_js_intl_text(result) != NULL);
    tsonic_js_intl_free(result);
}

static void expect_case(const uint16_t *input, size_t input_length,
    const char *locale, int upper, const uint16_t *expected, size_t expected_length) {
    TsonicIntlResult *result = tsonic_js_intl_case(input, input_length, locale, upper);
    assert(!tsonic_js_intl_failed(result));
    assert(tsonic_js_intl_length(result) == expected_length);
    assert(expected_length == 0 || memcmp(tsonic_js_intl_units(result),
        expected, expected_length * sizeof(*expected)) == 0);
    tsonic_js_intl_free(result);
}

static void expect_date_score(const char *requested, const char *candidate, int expected) {
    UChar wanted[128], available[128];
    size_t wanted_length = strlen(requested), available_length = strlen(candidate);
    assert(wanted_length < 128 && available_length < 128);
    for (size_t index = 0; index < wanted_length; ++index) wanted[index] = requested[index];
    for (size_t index = 0; index < available_length; ++index) available[index] = candidate[index];
    UErrorCode status = U_ZERO_ERROR;
    assert(tsonic_intl_date_pattern_score(wanted, (int32_t)wanted_length, available,
        (int32_t)available_length, &status) == expected);
    assert(U_SUCCESS(status));
}

static void collator_contracts(void) {
    TsonicIntlResult *owner = tsonic_js_intl_collator_open("en@colnumeric=yes", "", 0, 1, 1, 0, 1);
    assert(!tsonic_js_intl_failed(owner));
    assert(tsonic_js_intl_collator_option(owner, 0) == 0);
    assert(tsonic_js_intl_collator_option(owner, 1) == 0);
    assert(tsonic_js_intl_collator_option(owner, 2) == 1);
    assert(tsonic_js_intl_collator_option(owner, 3) == 1);
    assert(tsonic_js_intl_collator_option(owner, 4) == 1);
    assert(strstr(tsonic_js_intl_collator_text(owner, 0), "kn") != NULL);
    assert(strcmp(tsonic_js_intl_collator_text(owner, 1), "default") == 0);
    const uint16_t first[] = { 'f', 'i', 'l', 'e', '2' };
    const uint16_t second[] = { 'f', 'i', 'l', 'e', '1', '0' };
    for (int index = 0; index < 64; ++index) {
        TsonicIntlResult *comparison = tsonic_js_intl_collator_compare(owner, first, 5, second, 6);
        assert(!tsonic_js_intl_failed(comparison));
        assert(tsonic_js_intl_order(comparison) < 0);
        tsonic_js_intl_free(comparison);
    }
    assert(tsonic_js_intl_collator_text(owner, 2) == NULL);
    assert(tsonic_js_intl_collator_option(owner, 5) == -1);
    TsonicIntlResult *invalid = tsonic_js_intl_collator_compare(owner, NULL, 1, second, 6);
    assert(tsonic_js_intl_failed(invalid));
    tsonic_js_intl_free(invalid);
    tsonic_js_intl_free(owner);
    owner = tsonic_js_intl_collator_open("en@colnumeric=yes", "", 0, 0, -1, -1, -1);
    assert(!tsonic_js_intl_failed(owner));
    assert(strstr(tsonic_js_intl_collator_text(owner, 0), "kn") == NULL);
    tsonic_js_intl_free(owner);
    invalid = tsonic_js_intl_collator_open("en", "", 0, 2, -1, -1, -1);
    assert(tsonic_js_intl_failed(invalid));
    assert(tsonic_js_intl_collator_text(invalid, 0) == NULL);
    tsonic_js_intl_free(invalid);
}

static void date_contracts(void) {
    expect_date_score("yMd", "M/d/y", 0);
    expect_date_score("yMd", "M/y", -120);
    expect_date_score("yMd", "EEE, M/d/y", -20);
    expect_date_score("yMd", "M/d/yy", -6);
    expect_date_score("yMd", "yyyy 'quoted M d' M d", 0);
    expect_date_score("z", "O", -1);
    expect_date_score("z", "OOOO", -4);
    expect_date_score("zzzz", "O", -9);
    expect_date_score("v", "vvvv", -3);
    expect_date_score("SSS", "S", -8);
    TsonicIntlResult *result = tsonic_js_intl_date(0, "en_US", "UTC", 1, "", "", "yMd", -1, -1, -1, "", 0);
    const uint16_t expected[] = { '1', '/', '1', '/', '1', '9', '7', '0' };
    assert(!tsonic_js_intl_failed(result));
    assert(tsonic_js_intl_length(result) == sizeof(expected) / sizeof(*expected));
    assert(memcmp(tsonic_js_intl_units(result), expected, sizeof(expected)) == 0);
    tsonic_js_intl_free(result);
    result = tsonic_js_intl_date(0, "en_US", "UTC", 1, "", "", "yMd", -1, -1, -1, "", 1);
    assert(!tsonic_js_intl_failed(result));
    assert(tsonic_js_intl_length(result) == sizeof(expected) / sizeof(*expected));
    assert(memcmp(tsonic_js_intl_units(result), expected, sizeof(expected)) == 0);
    tsonic_js_intl_free(result);
    const char *invalid[] = { "", "Etc/Unknown", "Not/AZone", "+24:00", "+01:60", "+01:30:00" };
    for (size_t index = 0; index < sizeof(invalid) / sizeof(*invalid); ++index) {
        result = tsonic_js_intl_date(0, "en_US", invalid[index], 1, "", "", "yMd", -1, -1, -1, "", 0);
        assert(tsonic_js_intl_failed(result));
        tsonic_js_intl_free(result);
    }
    result = tsonic_js_intl_date(NAN, "en_US", "UTC", 1, "", "", "yMd", -1, -1, -1, "", 0);
    assert(tsonic_js_intl_failed(result));
    tsonic_js_intl_free(result);
    result = tsonic_js_intl_date(0, "en_US", "UTC", 1, "", "", "yMd", 0, -1, -1, "", 0);
    assert(tsonic_js_intl_failed(result));
    tsonic_js_intl_free(result);
    result = tsonic_js_intl_date(0, "en_US", "UTC", 1, "", "", "yMd", -1, -1, 1, "h99", 0);
    assert(tsonic_js_intl_failed(result));
    tsonic_js_intl_free(result);
    assert(!tsonic_js_intl_date_available("zz"));
    assert(tsonic_js_intl_date_available("en_US"));
}

static void expect_number(double value, const char *decimal, const char *skeleton, const char *expected) {
    TsonicIntlResult *result = tsonic_js_intl_number(value, decimal, "en_US", "", skeleton);
    assert(!tsonic_js_intl_failed(result));
    assert(tsonic_js_intl_length(result) == strlen(expected));
    for (size_t index = 0; index < strlen(expected); ++index) {
        assert(tsonic_js_intl_units(result)[index] == (unsigned char)expected[index]);
    }
    tsonic_js_intl_free(result);
}

static void number_contracts(void) {
    assert(tsonic_js_intl_number_available("en_US"));
    assert(!tsonic_js_intl_number_available("zz"));
    assert(tsonic_js_intl_currency_digits("USD") == 2);
    assert(tsonic_js_intl_currency_digits("JPY") == 0);
    assert(tsonic_js_intl_currency_digits("KWD") == 3);
    assert(tsonic_js_intl_currency_digits("ZZZ") == 2);
    assert(tsonic_js_intl_currency_digits("US") == -1);
    expect_number(1234.5, NULL, ".### rounding-mode-half-up", "1,234.5");
    expect_number(-0.0, NULL, ".###", "-0");
    expect_number(-0.0, NULL, ".### sign-negative", "0");
    expect_number(NAN, NULL, ".###", "NaN");
    expect_number(0.125, NULL, "percent scale/100 . rounding-mode-half-up", "13%");
    expect_number(0, "18446744073709551615", ".###", "18,446,744,073,709,551,615");
    expect_number(0, "-9223372036854775808", ".###", "-9,223,372,036,854,775,808");
    expect_number(0, "9007199254740993", "group-off .00", "9007199254740993.00");
    const char *invalid[] = { "", "-", "12.5", "1e2", "1x", "+1" };
    for (size_t index = 0; index < sizeof(invalid) / sizeof(*invalid); ++index) {
        TsonicIntlResult *result = tsonic_js_intl_number(0, invalid[index], "en_US", "", ".###");
        assert(tsonic_js_intl_failed(result));
        tsonic_js_intl_free(result);
    }
    TsonicIntlResult *invalid_pattern = tsonic_js_intl_number(1, NULL, "en_US", "", "invalid-skeleton");
    assert(tsonic_js_intl_failed(invalid_pattern));
    tsonic_js_intl_free(invalid_pattern);
    char oversized[1026];
    memset(oversized, '0', sizeof(oversized) - 1);
    oversized[sizeof(oversized) - 1] = '\0';
    invalid_pattern = tsonic_js_intl_number(1, NULL, "en_US", "", oversized);
    assert(tsonic_js_intl_failed(invalid_pattern));
    tsonic_js_intl_free(invalid_pattern);
}

int main(void) {
    collator_contracts();
    date_contracts();
    number_contracts();
    const char *valid[] = { "en", "tr-TR", "de-DE-u-co-phonebk", "en-u-kn-true-kf-upper",
        "en-x-private", "sr-Latn-RS", "sl-rozaj-biske", "en-t-en-US-h0-hybrid", "und" };
    const char *invalid[] = { "", "en_US", "i-klingon", "x-private", "abcd", "en-",
        "en--US", "de-1901-1901", "en-u-kn-u-kf", "en-u-a1-foo", "en-t-h0", "en-GB-oed" };
    for (size_t index = 0; index < sizeof(valid) / sizeof(valid[0]); ++index) expect_locale(valid[index], 1);
    for (size_t index = 0; index < sizeof(invalid) / sizeof(invalid[0]); ++index) expect_locale(invalid[index], 0);
    const char embedded[] = { 'e', 'n', '\0', '-', 't', 'r', '\0' };
    TsonicIntlResult *bad = tsonic_js_intl_locale(embedded, 6);
    assert(tsonic_js_intl_failed(bad));
    tsonic_js_intl_free(bad);
    const uint16_t capital_i[] = { 'I' }, dotless[] = { 0x131 }, lower_i[] = { 'i' };
    expect_case(capital_i, 1, "tr", 0, dotless, 1);
    expect_case(capital_i, 1, "", 0, lower_i, 1);
    const uint16_t dotted_i[] = { 0x130 }, expanded_i[] = { 'i', 0x307 };
    expect_case(dotted_i, 1, "", 0, expanded_i, 2);
    const uint16_t sharp_s[] = { 0xDF }, capitals[] = { 'S', 'S' };
    expect_case(sharp_s, 1, "de", 1, capitals, 2);
    const uint16_t lone[] = { 0xD800, 'A', 0xDC00 }, lone_lower[] = { 0xD800, 'a', 0xDC00 };
    expect_case(lone, 3, "", 0, lone_lower, 3);
    const uint16_t first[] = { 'f', 'i', 'l', 'e', '2' }, second[] = { 'f', 'i', 'l', 'e', '1', '0' };
    TsonicIntlResult *order = tsonic_js_intl_compare(first, 5, second, 6,
        "en", "", 0, 1, -1, -1, -1);
    assert(!tsonic_js_intl_failed(order));
    assert(tsonic_js_intl_order(order) < 0);
    tsonic_js_intl_free(order);
    order = tsonic_js_intl_compare(first, 5, second, 6,
        "en@colnumeric=yes", "", 0, 0, -1, -1, -1);
    assert(!tsonic_js_intl_failed(order));
    assert(tsonic_js_intl_order(order) > 0);
    tsonic_js_intl_free(order);
    bad = tsonic_js_intl_case(NULL, 1, "en", 0);
    assert(tsonic_js_intl_failed(bad));
    tsonic_js_intl_free(bad);
    bad = tsonic_js_intl_compare(first, 16777217, second, 6, "en", "", 0, -1, -1, -1, -1);
    assert(tsonic_js_intl_failed(bad));
    tsonic_js_intl_free(bad);
    assert(!tsonic_js_intl_collation_available("zz"));
    assert(tsonic_js_intl_collation_available("de_DE"));
    return 0;
}
