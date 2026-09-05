from std.collections import List
from std.testing import assert_equal
from tsonic_js import (
    JsArray,
    array_filter_value,
    array_for_each_value,
    array_map_with_index,
    array_reduce_from_first_value,
    array_reduce_initial_value,
    array_sort_compare,
    js_truthy_absent_result,
    js_truthy_number,
    js_truthy_present_result,
)
from tsonic_runtime import Location


@fieldwise_init
struct TypedCallbackError(Copyable, Writable):
    var code: Int

    def write_to(self, mut writer: Some[Writer]):
        writer.write("typed callback error ", self.code)


def greater_than_one(value: Float64) raises Error -> Bool:
    return value > 1


def add(left: Float64, right: Float64) raises Error -> Float64:
    return left + right


def compare(left: Float64, right: Float64) raises Error -> Float64:
    return left - right


def typed_error(
    value: Float64,
    _index: Float64,
) raises TypedCallbackError -> Float64:
    raise TypedCallbackError(Int(value))


def main() raises:
    var values = List[Float64]()
    values.append(3)
    values.append(1)
    values.append(2)
    var array = JsArray[Float64](values^)

    var offset = 10.0

    def map_with_offset(
        value: Float64,
        index: Float64,
    ) raises Error {imm offset} -> Float64:
        return offset + value + index

    var mapped = array_map_with_index(array, map_with_offset)
    assert_equal(mapped.get(0).value(), 13)
    assert_equal(mapped.get(1).value(), 12)
    assert_equal(mapped.get(2).value(), 14)

    var filtered = array_filter_value(array, greater_than_one)
    assert_equal(len(filtered), 2)
    assert_equal(filtered.get(0).value(), 3)
    assert_equal(filtered.get(1).value(), 2)

    assert_equal(array_reduce_initial_value(array, add, 0.0), 6)
    assert_equal(array_reduce_from_first_value(array, add), 6)

    _ = array_sort_compare(array, compare)
    assert_equal(array.get(0).value(), 1)
    assert_equal(array.get(1).value(), 2)
    assert_equal(array.get(2).value(), 3)

    var total = Location[Float64](0)

    def visit(value: Float64) raises Error {mut total}:
        total.write(total.read() + value)

    array_for_each_value(array, visit)
    assert_equal(total.read(), 6)

    assert_equal(js_truthy_number(0.0), False)
    assert_equal(js_truthy_number(2.0), True)
    assert_equal(js_truthy_present_result((0.0,)), True)
    assert_equal(js_truthy_absent_result(None), False)

    var typed_error_code = 0
    try:
        _ = array_map_with_index(array, typed_error)
    except error:
        typed_error_code = error.code
    assert_equal(typed_error_code, 1)
