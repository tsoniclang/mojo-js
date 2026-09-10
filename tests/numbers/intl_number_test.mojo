from std.testing import assert_equal, assert_true, assert_false
from std.utils import Variant
from tsonic_runtime import WeakReferenceIdentity
from tsonic_js import (
    IntlNumberFormat,
    IntlFormatPart,
    JsArray,
    JsString,
    JsValue,
    json_parse,
)


def data(text: String) raises -> JsValue:
    return json_parse(JsString(text))


def joined(parts: JsArray[IntlFormatPart]) raises -> String:
    var result = String()
    for part in parts.iter_values():
        result += part.get_value()
    return result^


def has_type(parts: JsArray[IntlFormatPart], type: String) raises -> Bool:
    for part in parts.iter_values():
        if part.get_type() == type:
            return True
    return False


def released_owner() raises -> WeakReferenceIdentity:
    var formatter = IntlNumberFormat(data('"en"'))
    return formatter.weak_identity()


def main() raises:
    var formatter = IntlNumberFormat(data('"en-US"'))
    var retained_alias = formatter
    assert_true(retained_alias == formatter)
    assert_true(retained_alias.weak_identity().same(formatter.weak_identity()))
    assert_equal(formatter.format(1234.5), "1,234.5")
    assert_equal(
        formatter.format(Int64(-9223372036854775807) - 1),
        "-9,223,372,036,854,775,808",
    )
    assert_equal(
        formatter.format(UInt64(18446744073709551615)),
        "18,446,744,073,709,551,615",
    )
    assert_equal(
        formatter.format(UInt(9007199254740993)), "9,007,199,254,740,993"
    )
    for _ in range(32):
        assert_equal(
            retained_alias.format(Int(9007199254740993)),
            "9,007,199,254,740,993",
        )
    var parts = formatter.format_to_parts(1234.5)
    assert_equal(joined(parts), formatter.format(1234.5))
    assert_true(has_type(parts, "group"))
    assert_true(has_type(parts, "fraction"))
    var first = parts[0]
    first.set_value("changed")
    assert_equal(parts[0].get_value(), "changed")
    assert_equal(formatter.format_to_parts(1234.5)[0].get_value(), "1")
    assert_true(has_type(formatter.format_to_parts(-0.0), "minusSign"))
    assert_true(
        has_type(formatter.format_to_parts(Float64(FloatLiteral.nan)), "nan")
    )
    assert_true(
        has_type(
            formatter.format_to_parts(Float64(FloatLiteral.infinity)),
            "infinity",
        )
    )
    var scientific = IntlNumberFormat(
        data('"en-US"'), data('{"notation":"scientific"}')
    )
    assert_true(
        has_type(scientific.format_to_parts(0.001), "exponentMinusSign")
    )
    var compact = IntlNumberFormat(
        data('"en-US"'), data('{"notation":"compact"}')
    )
    assert_true(has_type(compact.format_to_parts(12000.0), "compact"))
    var currency = IntlNumberFormat(
        data('"en-US"'),
        data(
            '{"style":"currency","currency":"USD","currencySign":"accounting"}'
        ),
    )
    assert_equal(currency.format(-12.5), "($12.50)")
    assert_equal(
        joined(currency.format_to_parts(-12.5)), currency.format(-12.5)
    )
    assert_true(has_type(currency.format_to_parts(-12.5), "currency"))
    var resolved = formatter.resolved_options()
    assert_equal(resolved.get_locale(), "en-US")
    assert_equal(resolved.get_numbering_system(), "latn")
    assert_equal(resolved.get_minimum_fraction_digits().value(), 0.0)
    assert_equal(resolved.get_maximum_fraction_digits().value(), 3.0)
    assert_equal(resolved.get_use_grouping()[String], "auto")
    var saved = resolved
    saved.set_minimum_fraction_digits(None)
    saved.set_use_grouping(Variant[Bool, String](True))
    assert_false(Bool(resolved.get_minimum_fraction_digits()))
    assert_equal(resolved.get_use_grouping()[Bool], True)
    assert_equal(
        formatter.resolved_options().get_minimum_fraction_digits().value(), 0.0
    )
    var significant = IntlNumberFormat(
        data('"en-US"'), data('{"maximumSignificantDigits":3}')
    )
    var digits = significant.resolved_options()
    assert_false(Bool(digits.get_minimum_fraction_digits()))
    assert_false(Bool(digits.get_maximum_fraction_digits()))
    assert_equal(digits.get_minimum_significant_digits().value(), 1.0)
    assert_equal(digits.get_maximum_significant_digits().value(), 3.0)
    var compact_options = compact.resolved_options()
    assert_equal(compact_options.get_minimum_fraction_digits().value(), 0.0)
    assert_equal(compact_options.get_maximum_fraction_digits().value(), 0.0)
    assert_equal(compact_options.get_minimum_significant_digits().value(), 1.0)
    assert_equal(compact_options.get_maximum_significant_digits().value(), 2.0)
    assert_equal(compact_options.get_rounding_priority(), "morePrecision")
    var extension = IntlNumberFormat(data('"en-u-nu-arab"'))
    assert_equal(extension.resolved_options().get_numbering_system(), "arab")
    assert_true("nu-arab" in extension.resolved_options().get_locale())
    var override = IntlNumberFormat(
        data('"en-u-nu-arab"'), data('{"numberingSystem":"latn"}')
    )
    assert_equal(override.resolved_options().get_locale(), "en")
    assert_equal(override.resolved_options().get_numbering_system(), "latn")
    assert_false(released_owner().is_alive())
