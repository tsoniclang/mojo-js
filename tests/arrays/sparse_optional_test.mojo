from std.collections import List
from std.testing import assert_equal, assert_false, assert_true
from tsonic_js import JsArray
from tsonic_js.array_values import (
    array_present_value,
    array_value_is_nullish,
    array_value_is_undefined,
)


def main() raises:
    var slots = List[Optional[Optional[Float64]]]()
    slots.append(Optional[Optional[Float64]](Optional[Float64](1.0)))
    slots.append(Optional[Optional[Float64]]())
    slots.append(Optional[Optional[Float64]](Optional[Float64]()))
    slots.append(Optional[Optional[Float64]](Optional[Float64](3.0)))
    var array = JsArray[Optional[Float64]](elements=slots^)
    assert_equal(len(array), 4)
    assert_false(array.get(1))
    assert_true(array.get(2))
    assert_false(array.get(2).value())
    assert_equal(array.read_value(0).value(), 1.0)
    assert_false(array.read_value(1))
    assert_false(array.read_value(2))
    assert_true(array_value_is_undefined(Optional[Float64]()))
    assert_true(array_value_is_nullish(Optional[Float64]()))
    assert_false(array_value_is_undefined(Optional[Float64](0.0)))
    assert_false(array_value_is_nullish(Optional[Float64](0.0)))
    var present = Optional[Optional[Float64]](Optional[Float64](7.0))
    assert_equal(array_present_value(present).value(), 7.0)
    var values = array.iter_values()
    assert_equal(len(values), 4)
    assert_false(values[1])
    assert_false(values[2])
    assert_equal(values[3].value(), 3.0)
