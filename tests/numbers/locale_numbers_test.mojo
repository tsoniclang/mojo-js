from std.testing import assert_equal, assert_true
from tsonic_js import JsString, JsValue, json_parse, number_to_locale_string


def value(text: String) raises -> JsValue:
    return json_parse(JsString(text))


def main() raises:
    var locale = value('"en-US"')
    assert_equal(number_to_locale_string(Float64(1234.5), locale), "1,234.5")
    assert_equal(
        number_to_locale_string(Float64(1234.5), value('"de-DE"')), "1.234,5"
    )
    assert_equal(number_to_locale_string(Float64(-0.0), locale), "-0")
    assert_equal(
        number_to_locale_string(Float64(FloatLiteral.nan), locale), "NaN"
    )
    assert_equal(
        number_to_locale_string(Float64(FloatLiteral.infinity), locale), "∞"
    )
    assert_equal(
        number_to_locale_string(
            Float64(0.125), locale, value('{"style":"percent"}')
        ),
        "13%",
    )
    assert_equal(
        number_to_locale_string(
            Float64(12.5),
            locale,
            value('{"style":"currency","currency":"usd"}'),
        ),
        "$12.50",
    )
    assert_equal(
        number_to_locale_string(
            Float64(-12.5),
            locale,
            value(
                '{"style":"currency","currency":"USD","currencySign":"accounting"}'
            ),
        ),
        "($12.50)",
    )
    assert_equal(
        number_to_locale_string(
            Float64(12000), locale, value('{"notation":"compact"}')
        ),
        "12K",
    )
    assert_equal(
        number_to_locale_string(
            Float64(1234.5),
            locale,
            value('{"useGrouping":false,"minimumFractionDigits":2}'),
        ),
        "1234.50",
    )
    assert_equal(
        number_to_locale_string(
            Float64(1.225),
            locale,
            value(
                '{"roundingIncrement":5,"minimumFractionDigits":2,"maximumFractionDigits":2}'
            ),
        ),
        "1.25",
    )
    assert_equal(
        number_to_locale_string(
            Float64(1.0),
            locale,
            value(
                '{"minimumFractionDigits":2,"trailingZeroDisplay":"stripIfInteger"}'
            ),
        ),
        "1",
    )
    assert_equal(
        number_to_locale_string(
            Float64(-0.0), locale, value('{"signDisplay":"negative"}')
        ),
        "0",
    )
    assert_equal(
        number_to_locale_string(Int64(-9223372036854775807) - 1, locale),
        "-9,223,372,036,854,775,808",
    )
    assert_equal(
        number_to_locale_string(UInt64(18446744073709551615), locale),
        "18,446,744,073,709,551,615",
    )
    assert_equal(
        number_to_locale_string(Int(9007199254740993), locale),
        "9,007,199,254,740,993",
    )
    assert_equal(
        number_to_locale_string(
            UInt(9007199254740993), locale, value('{"useGrouping":false}')
        ),
        "9007199254740993",
    )
    assert_equal(
        number_to_locale_string(Int32(42), value('["zz","en-US"]')), "42"
    )
    var invalid_options = String(
        """null
{"style":"unit"}
{"style":"currency"}
{"currency":"US"}
{"currency":"EU€"}
{"currency":"USD\\u0000"}
{"currencyDisplay":""}
{"currencySign":""}
{"minimumIntegerDigits":0}
{"minimumIntegerDigits":22}
{"minimumFractionDigits":101}
{"maximumFractionDigits":-1}
{"minimumFractionDigits":3,"maximumFractionDigits":2}
{"minimumSignificantDigits":0}
{"maximumSignificantDigits":22}
{"minimumSignificantDigits":3,"maximumSignificantDigits":2}
{"roundingIncrement":3}
{"roundingIncrement":5,"minimumFractionDigits":1,"maximumFractionDigits":2}
{"roundingIncrement":5,"maximumSignificantDigits":2}
{"roundingPriority":""}
{"roundingMode":""}
{"signDisplay":""}
{"trailingZeroDisplay":""}
{"notation":""}
{"compactDisplay":""}
{"useGrouping":"bogus"}
{"numberingSystem":"a"}
{"localeMatcher":""}"""
    )
    for selected in invalid_options.splitlines():
        var rejected = False
        try:
            _ = number_to_locale_string(
                Float64(12.5), locale, value(String(selected))
            )
        except:
            rejected = True
        assert_true(rejected, String(selected))
