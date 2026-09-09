#include "../../mojo/tsonic_js.native/intl/api.h"
#include <assert.h>
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

int main(void) {
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
