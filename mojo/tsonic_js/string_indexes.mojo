from std.sys import size_of
from tsonic_runtime.numeric import (
    SOURCE_MAX_SAFE_INTEGER,
    source_number_to_integer_or_infinity,
)


def string_absolute_index(value: Float64, length: Int) -> Optional[Int]:
    var integer = source_number_to_integer_or_infinity(value)
    if integer < 0 or integer >= Float64(length):
        return None
    return Optional[Int](Int(integer))


def string_clamped_index(value: Float64, length: Int) -> Int:
    var integer = source_number_to_integer_or_infinity(value)
    if integer <= 0:
        return 0
    if integer >= Float64(length):
        return length
    return Int(integer)


def string_relative_index(value: Float64, length: Int) -> Int:
    var integer = source_number_to_integer_or_infinity(value)
    if integer < 0:
        if integer <= -Float64(length):
            return 0
        return length + Int(integer)
    if integer >= Float64(length):
        return length
    return Int(integer)


def string_capacity(length: Float64) raises -> Int:
    comptime maximum_units = Int.MAX // size_of[UInt16]()
    if length < 0 or length != length or length >= Float64(maximum_units + 1):
        raise Error("string length exceeds native storage capacity")
    return Int(length)


def string_repeat_count(count: Float64) raises -> Float64:
    var repetitions = source_number_to_integer_or_infinity(count)
    if repetitions < 0 or repetitions == Float64(FloatLiteral.infinity):
        raise Error("invalid JavaScript string repeat count")
    return repetitions


def string_repeat_shape(length: Int, count: Float64) raises -> Tuple[Int, Int]:
    var repetitions = string_repeat_count(count)
    if repetitions == 0 or length == 0:
        return (0, 0)
    if repetitions * Float64(length) > SOURCE_MAX_SAFE_INTEGER:
        raise Error("JavaScript string length exceeds the source length domain")
    var count_value = string_capacity(repetitions)
    comptime maximum_units = Int.MAX // size_of[UInt16]()
    if count_value > maximum_units // length:
        raise Error("string length exceeds native storage capacity")
    return (count_value, length * count_value)
