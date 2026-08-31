from std.collections import List
from std.testing import assert_equal, assert_false, assert_true
from tsonic_js import JsArray


def main() raises:
    var values = List[Int32]()
    values.append(1)
    values.append(2)
    var array = JsArray[Int32](values^)
    var shared = array

    assert_equal(shared.push(3), 3)
    assert_equal(array.get(2).value(), 3)
    assert_true(array.same_storage(shared))

    array.set(5, 9)
    assert_equal(len(array), 6)
    assert_false(array.has(3))
    assert_true(array.has(5))
    assert_equal(array.get(5).value(), 9)

    assert_true(array.delete(1))
    assert_false(array.has(1))
