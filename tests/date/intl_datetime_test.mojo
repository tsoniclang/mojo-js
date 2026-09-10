from std.testing import assert_equal, assert_true, assert_false
from std.utils import Variant
from tsonic_runtime import Undefined, WeakReferenceIdentity
from tsonic_js import (
    IntlDateTimeFormat,
    JsString,
    JsValue,
    json_parse,
    date_new,
)
from tsonic_js.intl.date_options import DateOptions
from tsonic_js.date.arithmetic import invalid_time
from tsonic_js.date.model import JsDate


def data(text: String) raises -> JsValue:
    return json_parse(JsString(text))


def released_owner() raises -> WeakReferenceIdentity:
    var formatter = IntlDateTimeFormat(data('"en"'), data('{"timeZone":"UTC"}'))
    return formatter.weak_identity()


def main() raises:
    var options = data('{"timeZone":"UTC"}')
    var formatter = IntlDateTimeFormat(data('"en-US"'), options)
    var retained_alias = formatter
    assert_equal(retained_alias, formatter)
    assert_true(retained_alias.weak_identity().same(formatter.weak_identity()))
    assert_equal(formatter.format(0.0), "1/1/1970")
    assert_equal(formatter.format(date_new(0.0)), "1/1/1970")
    assert_equal(formatter.format(Variant[JsDate, Float64](0.0)), "1/1/1970")
    assert_equal(
        formatter.format(Variant[Float64, JsDate](date_new(0.0))), "1/1/1970"
    )
    assert_true(len(formatter.format(Undefined())) > 0)
    assert_true(len(formatter.format(Optional[Float64]())) > 0)
    assert_true(len(formatter.format()) > 0)
    for _ in range(32):
        assert_equal(retained_alias.format(0.5), "1/1/1970")
    var parts = formatter.format_to_parts(0.0)
    var text = String()
    for part in parts:
        text += part.get_value()
    assert_equal(text, formatter.format(0.0))
    assert_equal(parts[0].get_type(), "month")
    var first = parts[0]
    first.set_value("changed")
    assert_equal(parts[0].get_value(), "changed")
    assert_equal(formatter.format_to_parts(0.0)[0].get_value(), "1")
    var resolved = formatter.resolved_options()
    assert_equal(resolved.get_locale(), "en-US")
    assert_equal(resolved.get_calendar(), "gregory")
    assert_equal(resolved.get_numbering_system(), "latn")
    assert_equal(resolved.get_time_zone(), "UTC")
    var saved = resolved
    saved.set_time_zone("changed")
    assert_equal(resolved.get_time_zone(), "changed")
    assert_equal(formatter.resolved_options().get_time_zone(), "UTC")
    var offset = IntlDateTimeFormat(data('"en"'), data('{"timeZone":"-0100"}'))
    assert_equal(offset.format(0.0), "12/31/1969")
    assert_equal(offset.resolved_options().get_time_zone(), "-01:00")
    var zero = IntlDateTimeFormat(data('"en"'), data('{"timeZone":"-00"}'))
    assert_equal(zero.resolved_options().get_time_zone(), "+00:00")
    var extension = IntlDateTimeFormat(
        data('"en-u-ca-buddhist-nu-arab"'), data('{"timeZone":"UTC"}')
    )
    assert_equal(extension.resolved_options().get_calendar(), "buddhist")
    assert_equal(extension.resolved_options().get_numbering_system(), "arab")
    assert_true("ca-buddhist" in extension.resolved_options().get_locale())
    var override = IntlDateTimeFormat(
        data('"en-u-ca-buddhist-nu-arab-hc-h12"'),
        data(
            '{"calendar":"gregory","numberingSystem":"latn","hour12":false,"timeZone":"UTC"}'
        ),
    )
    assert_equal(override.resolved_options().get_locale(), "en")
    var defaults = DateOptions(data('{"timeZone":"UTC"}'), "all", "date")
    assert_equal(defaults.skeleton, "yMd")
    var no_defaults = DateOptions(data('{"hour":"numeric"}'), "all", "date")
    assert_equal(no_defaults.skeleton, "j")
    var styles = IntlDateTimeFormat(
        data('"en"'), data('{"timeStyle":"short","timeZone":"UTC"}')
    )
    assert_true(len(styles.format(0.0)) > 0)
    var invalid = False
    try:
        _ = formatter.format(date_new(invalid_time()))
    except:
        invalid = True
    assert_true(invalid)
    assert_false(released_owner().is_alive())
