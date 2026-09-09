from std.testing import assert_equal, assert_false, assert_true
from tsonic_js import JsArray, JsValue, array_from, array_join_native
from tsonic_js.array_callbacks_transform import array_map_with_array
from tsonic_js.array_callbacks_predicates import (
    array_find_index_zero,
    array_find_index_value,
    array_find_with_array,
    array_some_zero,
)
from tsonic_js.array_callbacks_sort import array_sort_compare
from tsonic_js.constructors import array_from_map_with_index
from tsonic_js.value import js_value_from_number


def shrink(
    value: Float64, index: Float64, array: JsArray[Float64]
) raises -> Float64:
    if index == 0:
        _ = array.pop()
        _ = array.pop()
    return value


def select_before_write(
    value: Float64, index: Float64, array: JsArray[Float64]
) raises -> Bool:
    array.set(Int(index), 99)
    return value == 1


def accept() raises -> Bool:
    return True


def undefined(value: JsValue) raises -> Bool:
    return value.is_undefined()


def main() raises:
    var values = JsArray[Float64]([1, 2, 3])
    var mapped = array_map_with_array(values, shrink)
    assert_equal(len(mapped), 3)
    assert_equal(mapped.get(0).value(), 1)
    assert_false(mapped.has(1))
    assert_false(mapped.has(2))

    var selected = JsArray[Float64]([1, 2])
    assert_equal(
        array_find_with_array(selected, select_before_write).value(), 1
    )
    assert_equal(selected.get(0).value(), 99)

    var sparse = JsArray[JsValue]()
    sparse.set(2, js_value_from_number(2))
    assert_equal(array_find_index_zero(sparse, accept), 0)
    assert_equal(array_find_index_value(sparse, undefined), 0)
    assert_true(array_some_zero(sparse, accept))
    var copied = array_from(sparse)
    assert_true(copied.has(0))
    assert_true(copied.get(0).value().is_undefined())
    assert_equal(len(copied.iter_values()), 3)

    var only_holes = JsArray[JsValue]()
    only_holes.set(1, js_value_from_number(1))
    _ = only_holes.delete(1)
    assert_false(array_some_zero(only_holes, accept))
    assert_equal(array_find_index_zero(only_holes, accept), 0)

    var sorting = JsArray[Float64]([3, 2, 1])

    def compare(left: Float64, right: Float64) raises {imm sorting} -> Float64:
        if len(sorting) == 3:
            _ = sorting.push([99])
        return left - right

    _ = array_sort_compare(sorting, compare)
    assert_equal(array_join_native(sorting), "1,2,3,99")

    var growing = JsArray[Float64]([1, 2])

    def append(value: Float64, index: Float64) raises {imm growing} -> Float64:
        if index == 0:
            _ = growing.push([3])
        return value

    var result = array_from_map_with_index(growing, append)
    assert_equal(array_join_native(result), "1,2,3")
