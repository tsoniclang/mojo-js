from std.testing import assert_equal, assert_true
from tsonic_js import (
    JsString,
    JsValue,
    json_parse,
    date_new,
    date_to_locale_string,
    date_to_locale_date_string,
    date_to_locale_time_string,
)
from tsonic_js.date.arithmetic import invalid_time
from tsonic_js.intl.date_options import DateOptions


def value(text: String) raises -> JsValue:
    return json_parse(JsString(text))


def main() raises:
    var epoch = date_new(0.0)
    var locale = value('"en-US"')
    var utc = value('{"timeZone":"UTC"}')
    assert_equal(date_to_locale_date_string(epoch, locale, utc), "1/1/1970")
    assert_equal(
        date_to_locale_date_string(
            epoch, locale, value('{"timeZone":"UTC","formatMatcher":"basic"}')
        ),
        "1/1/1970",
    )
    assert_equal(
        date_to_locale_time_string(
            epoch, locale, value('{"timeZone":"UTC","hour12":false}')
        ),
        "00:00:00",
    )
    assert_equal(
        date_to_locale_date_string(epoch, value('"de-DE"'), utc), "1.1.1970"
    )
    assert_equal(
        date_to_locale_date_string(
            epoch, locale, value('{"timeZone":"-01:00"}')
        ),
        "12/31/1969",
    )
    assert_equal(
        date_to_locale_date_string(
            epoch,
            locale,
            value(
                '{"timeZone":"utc","year":"numeric","month":"long","day":"numeric"}'
            ),
        ),
        "January 1, 1970",
    )
    assert_equal(
        date_to_locale_date_string(
            epoch, locale, value('{"timeZone":"UTC","dateStyle":"long"}')
        ),
        "January 1, 1970",
    )
    assert_true(date_to_locale_string(epoch).byte_length() > 0)
    assert_true(
        date_to_locale_time_string(
            epoch,
            value('"ja-JP"'),
            value('{"timeZone":"UTC","hour12":true}'),
        ).byte_length()
        > 0
    )
    var invalid = date_new(invalid_time())
    assert_equal(
        date_to_locale_string(invalid, value('"not_a_tag"'), value("null")),
        "Invalid Date",
    )
    assert_equal(
        date_to_locale_date_string(invalid, value("null"), value("null")),
        "Invalid Date",
    )
    assert_equal(
        date_to_locale_time_string(invalid, value("null"), value("null")),
        "Invalid Date",
    )
    var defaults = DateOptions(value('{"timeZone":"UTC"}'), "all", "all")
    assert_equal(defaults.skeleton, "yMdjms")
    var dates = DateOptions(value('{"hour":"numeric"}'), "date", "date")
    assert_equal(dates.skeleton, "yMdj")
    var times = DateOptions(value('{"year":"numeric"}'), "time", "time")
    assert_equal(times.skeleton, "yjms")
    var invalid_options = String(
        """null
{"hour12":true,"hourCycle":"invalid"}
{"timeZone":""}
{"timeZone":"Not/AZone"}
{"timeZone":"Etc/Unknown"}
{"timeZone":"+24:00"}
{"timeZone":"+01:60"}
{"timeZone":"+01:30:00"}
{"timeZone":"UTC\\u0000tail"}
{"year":""}
{"calendar":"a"}
{"numberingSystem":""}
{"dateStyle":""}
{"dateStyle":"short","year":"numeric"}
{"fractionalSecondDigits":0}
{"fractionalSecondDigits":4}
{"timeStyle":"short"}"""
    )
    for selected in invalid_options.splitlines():
        var rejected = False
        try:
            _ = date_to_locale_date_string(
                epoch, locale, value(String(selected))
            )
        except:
            rejected = True
        assert_true(rejected, String(selected))
