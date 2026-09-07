from std.testing import assert_equal

from tsonic_js.number import number_to_string


def main() raises:
    assert_equal(
        number_to_string(1704067200000.0).to_native_strict(), "1704067200000"
    )
    assert_equal(number_to_string(-0.0).to_native_strict(), "0")
    assert_equal(number_to_string(1e21).to_native_strict(), "1e+21")
    assert_equal(number_to_string(1e-7).to_native_strict(), "1e-7")
    assert_equal(
        number_to_string(Float64(FloatLiteral.nan)).to_native_strict(), "NaN"
    )
    assert_equal(
        number_to_string(Float64(FloatLiteral.infinity)).to_native_strict(),
        "Infinity",
    )
