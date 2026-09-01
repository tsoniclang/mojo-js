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

    var sequence = JsArray[Int32]()
    assert_equal(sequence.unshift(2, 3), 2)
    assert_equal(sequence.unshift(1), 3)
    assert_equal(sequence.shift().value(), 1)
    assert_equal(sequence.pop().value(), 3)
    assert_equal(sequence.at(-1).value(), 2)
    assert_true(sequence.includes(2))
    assert_equal(sequence.index_of(2), 0)
    assert_equal(sequence.last_index_of(2), 0)
    assert_equal(sequence.join().to_native_strict(), "2")

    _ = sequence.push(4, 6, 8)
    var middle = sequence.slice(1, 3)
    assert_equal(len(middle), 2)
    assert_equal(middle.get(0).value(), 4)
    assert_equal(middle.get(1).value(), 6)
    var removed = sequence.splice(1, 2, 5, 7)
    assert_equal(len(removed), 2)
    assert_equal(removed.get(0).value(), 4)
    assert_equal(removed.get(1).value(), 6)
    assert_equal(sequence.get(1).value(), 5)
    assert_equal(sequence.get(2).value(), 7)
    _ = sequence.fill(9, 1, 3)
    assert_equal(sequence.get(1).value(), 9)
    assert_equal(sequence.get(2).value(), 9)
    _ = sequence.copy_within(2, 0, 2)
    assert_equal(sequence.get(2).value(), 2)
    assert_equal(sequence.get(3).value(), 9)
    _ = sequence.reverse()
    assert_equal(sequence.get(0).value(), 9)
    _ = sequence.sort()
    assert_equal(sequence.get(0).value(), 2)
