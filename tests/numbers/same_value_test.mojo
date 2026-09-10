from std.math import copysign
from std.testing import assert_equal, assert_false, assert_true
from tsonic_js.equality import canonical_collection_key, same_value, same_value_zero


def scalar_width[dtype: DType]() raises:
    comptime Scalar = SIMD[dtype, 1]
    var nan = Scalar(FloatLiteral.nan)
    var negative_zero = Scalar(-0.0)
    var positive_zero = Scalar(0.0)
    var infinity = Scalar(FloatLiteral.infinity)
    assert_true(same_value(nan, nan))
    assert_false(same_value(nan, positive_zero))
    assert_true(same_value(negative_zero, negative_zero))
    assert_false(same_value(negative_zero, positive_zero))
    assert_false(same_value(positive_zero, negative_zero))
    assert_true(same_value_zero(negative_zero, positive_zero))
    assert_true(same_value_zero(nan, nan))
    assert_true(same_value(infinity, infinity))
    assert_false(same_value(infinity, -infinity))
    assert_true(same_value(Scalar(3.5), Scalar(3.5)))
    assert_false(same_value(Scalar(3.5), Scalar(4.5)))
    assert_equal(copysign(Scalar(1), canonical_collection_key(negative_zero)), Scalar(1))


def main() raises:
    scalar_width[DType.float16]()
    scalar_width[DType.float32]()
    scalar_width[DType.float64]()
    var greatest = UInt64(18446744073709551615)
    assert_true(same_value(greatest, greatest))
    assert_false(same_value(greatest, greatest - 1))
    assert_true(same_value(String("value"), String("value")))
    assert_false(same_value(True, False))
