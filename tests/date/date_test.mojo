from std import math
from std.testing import assert_equal, assert_true
from tsonic_runtime import Null
from tsonic_js import JsDate, date_new, date_now, date_parse_native, date_utc


def main() raises:
    var invalid = date_new(Float64(FloatLiteral.nan))
    assert_true(math.isnan(invalid.get_utc_full_year()))
    assert_true(math.isnan(invalid.get_utc_month()))
    assert_true(math.isnan(invalid.get_utc_date()))
    assert_true(math.isnan(invalid.get_utc_day()))
    assert_true(math.isnan(invalid.get_utc_hours()))
    assert_true(math.isnan(invalid.get_utc_minutes()))
    assert_true(math.isnan(invalid.get_utc_seconds()))
    assert_true(math.isnan(invalid.get_utc_milliseconds()))
    assert_true(math.isnan(invalid.get_full_year()))
    assert_true(math.isnan(invalid.get_timezone_offset()))
    assert_true(invalid.to_json().isa[Null]())
    assert_equal(invalid.to_string().to_native_strict(), "Invalid Date")
    assert_true(math.isnan(invalid.set_utc_month(0)))
    assert_equal(invalid.set_utc_full_year(2000), 946684800000.0)

    var omitted = date_new(1234.0)
    assert_equal(omitted.set_utc_seconds(2), 2234)
    assert_true(math.isnan(omitted.set_utc_seconds(2, Float64(FloatLiteral.nan))))
    _ = omitted.set_time(1234)
    assert_true(math.isnan(omitted.set_utc_seconds(2, None)))
    _ = omitted.set_time(1234)
    assert_true(math.isnan(omitted.set_utc_minutes(1, None)))
    _ = omitted.set_time(1234)
    assert_true(math.isnan(omitted.set_utc_hours(1, 2, None)))
    _ = omitted.set_time(1234)
    assert_true(math.isnan(omitted.set_utc_month(0, None)))
    _ = omitted.set_time(1234)
    assert_true(math.isnan(omitted.set_utc_full_year(2000, None)))

    var original = date_new(0.0)
    var alias = original
    var separate = date_new(original)
    _ = alias.set_time(5000)
    assert_equal(original.get_time(), 5000)
    assert_equal(separate.get_time(), 0)
    assert_equal(date_new(-0.75).get_time(), 0)
    assert_equal(1.0 / date_new(-0.75).get_time(), Float64(FloatLiteral.infinity))
    assert_true(math.isnan(date_new(8640000000000001.0).get_time()))
    assert_true(math.isnan(date_new(Float64(FloatLiteral.infinity)).get_time()))
    assert_equal(date_new(8640000000000000.0).to_iso_string().to_native_strict(), "+275760-09-13T00:00:00.000Z")
    assert_equal(date_new(-8640000000000000.0).to_iso_string().to_native_strict(), "-271821-04-20T00:00:00.000Z")
    assert_equal(date_utc(1970), 0)
    assert_equal(date_utc(70), 0)
    assert_true(math.isnan(date_utc(1970, None)))
    assert_true(math.isnan(date_utc(1970, 0, None)))
    assert_true(math.isnan(date_utc(1e300)))
    assert_true(math.isnan(date_utc(2000, Float64(FloatLiteral.infinity))))
    assert_equal(date_utc(2000, 12), date_utc(2001, 0))
    assert_equal(date_utc(2000, -1), date_utc(1999, 11))
    assert_equal(date_utc(2000, 1, 29), 951782400000.0)
    var current = date_now()
    assert_equal(current, math.trunc(current))

    var valid: List[String] = [
        "1970", "1970-01", "1970-01-01", "1970-01-01T00:00Z",
        "1970-01-01T00:00:00Z", "+001970-01-01T00:00:00.000Z",
        "1970-01-01T05:30:00+05:30", "1969-12-31T19:00:00-05:00",
        "1969-12-31T24:00:00Z", "Thu, 01 Jan 1970 00:00:00 GMT",
    ]
    for text in valid:
        assert_equal(date_parse_native(text), 0)
    var rejected: List[String] = [
        "", "1970-00", "1970-13", "1970-01-00", "1970-01-32",
        "1970-01-01Txx:00:00Z", "1970-01-01T00:xx:00Z",
        "1970-01-01T00:00:xxZ", "1970-01-01T00:00:00.Z",
        "1970-01-01T00:00:00+05:60", "1970-01-01T00:00:00+24:00",
        "1970-01-01T24:00:01Z", "1970-01-01T00:00:00Zjunk",
        "-000000-01-01T00:00:00Z", "😀1970-01-01", "1970-01-01\0",
    ]
    for text in rejected:
        assert_true(math.isnan(date_parse_native(text)))
    assert_equal(date_parse_native("1970-01-01T00:00:00.123456Z"), 123)
    assert_equal(date_new("0000-01-01").get_utc_full_year(), 0)
    assert_equal(date_new("-000001-01-01").get_utc_full_year(), -1)

    var examples: List[Float64] = [0, -86400000, 951782400000, 1700000000000]
    for timestamp in examples:
        var date = date_new(timestamp)
        assert_equal(date_parse_native(date.to_iso_string().to_native_strict()), timestamp)
        assert_equal(date_parse_native(date.to_utc_string().to_native_strict()), timestamp)
        assert_equal(date_parse_native(date.to_string().to_native_strict()), timestamp)
