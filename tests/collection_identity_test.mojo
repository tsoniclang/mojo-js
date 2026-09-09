from std.testing import assert_false, assert_true
from tsonic_js import JsArray, JsMap, JsSet


def main() raises:
    var array = JsArray[Int]([1, 2])
    var shared_array = array
    var other_array = JsArray[Int]([1, 2])
    assert_true(array == shared_array)
    assert_false(array == other_array)
    assert_true(array != other_array)
    var mapping = JsMap[Int, Int]()
    var shared_mapping = mapping
    var other_mapping = JsMap[Int, Int]()
    assert_true(mapping == shared_mapping)
    assert_false(mapping == other_mapping)
    var values = JsSet[Int]()
    var shared_values = values
    var other_values = JsSet[Int]()
    assert_true(values == shared_values)
    assert_false(values == other_values)
    var keys = JsMap[JsArray[Int], Int]()
    _ = keys.set(array, 7)
    assert_true(keys.get(shared_array).value() == 7)
    assert_false(Bool(keys.get(other_array)))
