from std import math
from tsonic_js import JsDate, date_new, date_parse_native, number_to_string


def number(value: Float64):
    print(number_to_string(value).to_native_lossy())


def describe(date: JsDate) raises:
    number(date.get_time())
    number(date.get_full_year())
    number(date.get_month())
    number(date.get_date())
    number(date.get_day())
    number(date.get_hours())
    number(date.get_minutes())
    number(date.get_seconds())
    number(date.get_milliseconds())
    number(date.get_timezone_offset())
    print("Invalid Date" if math.isnan(date.get_time()) else date.to_iso_string().to_native_strict())
    if not math.isnan(date.get_time()):
        number(date_parse_native(date.to_utc_string().to_native_strict()))
        number(date_parse_native(date.to_string().to_native_strict()))


def main() raises:
    var timestamps: List[Float64] = [
        0, -86400000, 951782400000, 1710053999000, 1710054000000,
        1730613599000, 1730613600000, 1325239199000, 1325239200000,
        Float64(FloatLiteral.nan),
    ]
    for timestamp in timestamps:
        describe(date_new(timestamp))
    var texts: List[String] = [
        "2024-03-10T02:30:00", "2024-11-03T01:30:00",
        "2011-12-30T12:00:00", "2000-02-29", "2000-02-29T00:00:00",
    ]
    for text in texts:
        describe(date_new(text))
    describe(date_new(2024, 2, Float64(10), Float64(2), Float64(30)))
    describe(date_new(2024, 10, Float64(3), Float64(1), Float64(30)))
    describe(date_new(2011, 11, Float64(30), Float64(12)))
    var setters = date_new("2024-03-10T00:30:00")
    _ = setters.set_hours(2)
    describe(setters)
    _ = setters.set_minutes(50, Float64(30), Float64(0))
    describe(setters)
    _ = setters.set_month(10, Float64(3))
    _ = setters.set_hours(1, Float64(30), Float64(0), Float64(0))
    describe(setters)
    _ = setters.set_full_year(2025)
    describe(setters)
    _ = setters.set_time(Float64(FloatLiteral.nan))
    _ = setters.set_full_year(2000)
    describe(setters)
