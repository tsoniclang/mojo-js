def same_value_zero(left: Float64, right: Float64) -> Bool:
    return (left != left and right != right) or left == right


def same_value_zero[T: Equatable](left: T, right: T) -> Bool:
    return left == right
