from std.math import copysign


def _same_float_value(left: Float64, right: Float64) -> Bool:
    if left != left:
        return right != right
    if left == 0 and right == 0:
        return copysign(Float64(1), left) == copysign(Float64(1), right)
    return left == right


def same_value[T: Equatable](left: T, right: T) -> Bool:
    comptime if T is Float64:
        return _same_float_value(rebind[Float64](left), rebind[Float64](right))
    elif T is Float32:
        return _same_float_value(Float64(rebind[Float32](left)), Float64(rebind[Float32](right)))
    elif T is Float16:
        return _same_float_value(Float64(rebind[Float16](left)), Float64(rebind[Float16](right)))
    return left == right


def same_value_zero[T: Equatable](left: T, right: T) -> Bool:
    return left == right or same_value(left, right)


def canonical_collection_key[T: Copyable & Deinitable](value: T) -> T:
    comptime if T is Float64:
        if value == 0:
            return Float64(0)
    elif T is Float32:
        if value == 0:
            return Float32(0)
    elif T is Float16:
        if value == 0:
            return Float16(0)
    return value.copy()
