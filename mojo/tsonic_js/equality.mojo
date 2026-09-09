def same_value_zero(left: Float64, right: Float64) -> Bool:
    return (left != left and right != right) or left == right


def same_value_zero[T: Equatable](left: T, right: T) -> Bool:
    comptime if T is Float64:
        return (left != left and right != right) or left == right
    return left == right


def canonical_collection_key[T: Copyable & Deinitable](value: T) -> T:
    comptime if T is Float64:
        if value == 0:
            return Float64(0)
    return value.copy()
