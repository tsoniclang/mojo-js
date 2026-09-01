from std.testing import assert_almost_equal, assert_equal, assert_false, assert_true
from tsonic_js import *


def main() raises:
    assert_equal(math_abs(-2), 2)
    assert_equal(math_floor(1.9), 1)
    assert_equal(math_ceil(1.1), 2)
    assert_equal(math_trunc(-1.9), -1)
    assert_equal(math_round(1.5), 2)
    assert_equal(math_min(3, 1, 2), 1)
    assert_equal(math_max(3, 1, 2), 3)
    assert_equal(math_pow(2, 3), 8)
    assert_equal(math_sign(-5), -1)
    assert_equal(math_clz32(1), 31)
    assert_equal(math_imul(0x7FFFFFFF, 2), -2)
    assert_almost_equal(math_acos(1), 0)
    assert_almost_equal(math_acosh(1), 0)
    assert_almost_equal(math_asin(0), 0)
    assert_almost_equal(math_asinh(0), 0)
    assert_almost_equal(math_atan(0), 0)
    assert_almost_equal(math_atan2(0, 1), 0)
    assert_almost_equal(math_atanh(0), 0)
    assert_almost_equal(math_sqrt(9), 3)
    assert_almost_equal(math_cbrt(27), 3)
    assert_almost_equal(math_hypot(3, 4), 5)
    assert_almost_equal(math_sin(0), 0)
    assert_almost_equal(math_cos(0), 1)
    assert_almost_equal(math_exp(0), 1)
    assert_almost_equal(math_expm1(0), 0)
    assert_almost_equal(math_log(MATH_E), 1)
    assert_almost_equal(math_log10(1), 0)
    assert_almost_equal(math_log1p(0), 0)
    assert_almost_equal(math_log2(1), 0)
    assert_almost_equal(math_cosh(0), 1)
    assert_almost_equal(math_sinh(0), 0)
    assert_almost_equal(math_tan(0), 0)
    assert_almost_equal(math_tanh(0), 0)
    assert_almost_equal(math_fround(1.25), 1.25)
    var random_value = math_random()
    assert_true(random_value >= 0 and random_value < 1)
    assert_true(number_is_finite(1))
    assert_true(number_is_integer(1))
    assert_true(number_is_safe_integer(NUMBER_MAX_SAFE_INTEGER))
    assert_true(number_is_nan(Float64(FloatLiteral.nan)))
    assert_false(number_is_finite(Float64(FloatLiteral.infinity)))
    assert_equal(number_parse_int(JsString("ff"), 16), 255)
    assert_equal(number_parse_float(JsString("12.5tail")), 12.5)
    assert_equal(number_value_of(12.5), 12.5)
    assert_equal(number_to_fixed(123.456, 2).to_native_strict(), "123.46")
    assert_equal(number_to_fixed(1.005, 2).to_native_strict(), "1.00")
    assert_equal(number_to_fixed(2.35, 1).to_native_strict(), "2.4")
    assert_equal(
        number_to_fixed(1e20, 0).to_native_strict(),
        "100000000000000000000",
    )
    assert_equal(
        number_to_exponential_default(77).to_native_strict(), "7.7e+1"
    )
    assert_equal(
        number_to_exponential_digits(77, 2).to_native_strict(), "7.70e+1"
    )
    assert_equal(
        number_to_precision_digits(12345, 3).to_native_strict(), "1.23e+4"
    )
    assert_equal(
        number_to_precision_digits(123.45, 4).to_native_strict(), "123.5"
    )
    assert_equal(
        number_to_precision_digits(0.0012345, 2).to_native_strict(), "0.0012"
    )

    var epoch = JsDate(0)
    assert_equal(epoch.get_time(), 0)
    assert_equal(epoch.get_utc_full_year(), 1970)
    assert_equal(epoch.get_utc_month(), 0)
    assert_equal(epoch.get_utc_date(), 1)
    assert_equal(epoch.get_utc_day(), 4)
    assert_equal(epoch.get_utc_hours(), 0)
    assert_equal(epoch.get_utc_minutes(), 0)
    assert_equal(epoch.get_utc_seconds(), 0)
    assert_equal(epoch.get_utc_milliseconds(), 0)
    assert_equal(epoch.value_of(), 0)
    assert_equal(epoch.to_iso_string().to_native_strict(), "1970-01-01T00:00:00.000Z")
    assert_equal(date_parse(JsString("1970-01-01T00:00:01.000Z")), 1000)
    assert_equal(date_utc(1970, 0), 0)
    assert_true(date_now() > 0)
    assert_equal(epoch.set_utc_milliseconds(5), 5)
    assert_equal(epoch.get_utc_milliseconds(), 5)
    _ = epoch.set_utc_seconds(2, 6)
    assert_equal(epoch.get_utc_seconds(), 2)
    assert_equal(epoch.get_utc_milliseconds(), 6)
    _ = epoch.set_utc_minutes(3, 4, 7)
    assert_equal(epoch.get_utc_minutes(), 3)
    _ = epoch.set_utc_hours(5, 6, 7, 8)
    assert_equal(epoch.get_utc_hours(), 5)
    _ = epoch.set_utc_date(2)
    assert_equal(epoch.get_utc_date(), 2)
    _ = epoch.set_utc_month(1, 3)
    assert_equal(epoch.get_utc_month(), 1)
    _ = epoch.set_utc_full_year(2000, 2, 4)
    assert_equal(epoch.get_utc_full_year(), 2000)
    var json = epoch.to_json()
    assert_true(json.isa[JsString]())
    assert_equal(
        json[JsString].to_native_strict(),
        epoch.to_iso_string().to_native_strict(),
    )
    assert_true(epoch.to_utc_string().to_native_strict().byte_length() > 0)
    assert_true(epoch.to_string().to_native_strict().byte_length() > 0)
