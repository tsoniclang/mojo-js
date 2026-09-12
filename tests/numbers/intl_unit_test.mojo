from std.testing import assert_equal, assert_false, assert_true
from tsonic_js import (
    IntlNumberFormat,
    JsString,
    JsValue,
    json_parse,
    number_to_locale_string,
)


def data(text: String) raises -> JsValue:
    return json_parse(JsString(text))


def main() raises:
    var options = data('{"style":"unit","unit":"meter","unitDisplay":"long"}')
    var formatter = IntlNumberFormat(data('"en-US"'), options)
    assert_equal(formatter.format(1), "1 meter")
    assert_equal(formatter.format(3), "3 meters")
    assert_equal(
        number_to_locale_string(3, data('"en-US"'), options), "3 meters"
    )
    assert_equal(
        formatter.format(UInt64(9007199254740993)),
        "9,007,199,254,740,993 meters",
    )
    var unit_part = String()
    var joined = String()
    for part in formatter.format_to_parts(3).iter_values():
        joined += part.get_value()
        if part.get_type() == "unit":
            unit_part += part.get_value()
    assert_equal(joined, formatter.format(3))
    assert_equal(unit_part, "meters")
    var resolved = formatter.resolved_options()
    assert_equal(resolved.get_unit().value(), "meter")
    assert_equal(resolved.get_unit_display().value(), "long")
    resolved.set_unit("liter")
    assert_equal(formatter.resolved_options().get_unit().value(), "meter")
    var decimal = IntlNumberFormat(
        data('"en-US"'), data('{"unit":"meter","unitDisplay":"long"}')
    )
    assert_false(Bool(decimal.resolved_options().get_unit()))
    assert_false(Bool(decimal.resolved_options().get_unit_display()))
    assert_equal(decimal.format(3), "3")
    var compound = IntlNumberFormat(
        data('"en-US"'), data('{"style":"unit","unit":"kilometer-per-hour"}')
    )
    assert_equal(compound.format(3), "3 km/h")
    var percent = IntlNumberFormat(
        data('"en-US"'), data('{"style":"unit","unit":"percent"}')
    )
    assert_equal(percent.format(3), "3%")
    for invalid in [
        '{"style":"unit"}',
        '{"style":"unit","unit":"meter|mile"}',
        '{"style":"unit","unit":"meter-per-second-per-hour"}',
        '{"unit":"bogus"}',
        '{"unitDisplay":"wide"}',
    ]:
        var rejected = False
        try:
            _ = IntlNumberFormat(data('"en-US"'), data(invalid))
        except:
            rejected = True
        assert_true(rejected)
