from std.testing import assert_equal, assert_true
from tsonic_js import (
    JsString,
    JsValue,
    json_parse,
    string_to_locale_lower_case,
    string_to_locale_upper_case,
    string_locale_compare,
    js_string_to_locale_lower_case,
)


def data(source: String) raises -> JsValue:
    return json_parse(JsString(source))


def main() raises:
    assert_equal(string_to_locale_lower_case("I", data('"tr"')), "ı")
    assert_equal(string_to_locale_upper_case("i", data('["tr", "en"]')), "İ")
    assert_equal(string_to_locale_lower_case("I", data('["zz", "tr"]')), "i")
    assert_equal(string_to_locale_upper_case("straße", data('"de"')), "STRASSE")
    assert_equal(string_to_locale_lower_case("ΟΣ", data('"el"')), "ος")
    assert_true(
        string_locale_compare(
            "file2", "file10", data('"en"'), data('{"numeric":true}')
        )
        < 0
    )
    assert_true(
        string_locale_compare(
            "file2", "file10", data('"en-u-kn"'), data('{"numeric":false}')
        )
        > 0
    )
    assert_equal(
        string_locale_compare(
            "ä", "a", data('"de"'), data('{"sensitivity":"base"}')
        ),
        0.0,
    )
    assert_true(
        string_locale_compare(
            "ä", "a", data('"sv"'), data('{"sensitivity":"base"}')
        )
        > 0
    )
    assert_equal(
        string_locale_compare(
            "a-b", "ab", data('"en"'), data('{"ignorePunctuation":true}')
        ),
        0.0,
    )
    var lone = json_parse(JsString('"\\ud800I\\udfff"')).string_value()
    var converted = js_string_to_locale_lower_case(lone, data('"tr"'))
    assert_equal(converted.code_unit_at(0).value(), UInt16(0xD800))
    assert_equal(converted.code_unit_at(1).value(), UInt16(0x131))
    assert_equal(converted.code_unit_at(2).value(), UInt16(0xDFFF))
    var default_lower = lone.to_lower_case()
    assert_equal(default_lower.code_unit_at(1).value(), UInt16(105))
    var rejected = False
    try:
        _ = string_to_locale_lower_case("I", data('["en", "bad_tag"]'))
    except:
        rejected = True
    assert_true(rejected)
    for invalid in [
        '{"numeric":true,"caseFirst":""}',
        '{"sensitivity":"invalid"}',
        '{"usage":""}',
        '{"localeMatcher":"other"}',
        '{"collation":""}',
        "null",
    ]:
        rejected = False
        try:
            _ = string_locale_compare("a", "b", data('"en"'), data(invalid))
        except:
            rejected = True
        assert_true(rejected)
