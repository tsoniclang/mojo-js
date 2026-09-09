from std.memory import bitcast
from std.testing import assert_equal, assert_false, assert_true
from tsonic_js import JsIteratorReturn, JsIteratorYield, JsMap, JsSet, JsValue, array_from


def map_mutations() raises:
    var values = JsMap[Float64, String]()
    _ = values.set(1, "one")
    _ = values.set(2, "two")
    var iterator = values.entries()
    var alias = iterator
    assert_true(iterator == alias)
    assert_false(iterator == values.entries())
    assert_equal(iterator.next_optional().value()[1], "one")
    _ = values.set(2, "updated")
    _ = values.set(3, "three")
    assert_equal(alias.next_optional().value()[1], "updated")
    assert_true(values.delete(3))
    _ = values.set(3, "reinserted")
    assert_equal(iterator.next_optional().value()[1], "reinserted")
    assert_false(iterator.next_optional())
    _ = values.set(4, "four")
    assert_false(alias.next_optional())
    assert_equal(values.js_size(), 4)


def clear_and_reinsert() raises:
    var values = JsSet[Float64]()
    _ = values.add(1)
    _ = values.add(2)
    var first = values.values()
    var second = values.values()
    assert_equal(first.next_optional().value(), 1)
    values.clear()
    _ = values.add(3)
    assert_equal(first.next_optional().value(), 3)
    assert_equal(second.next_optional().value(), 3)
    assert_false(first.next_optional())
    _ = values.add(4)
    assert_false(first.next_optional())
    assert_equal(second.next_optional().value(), 4)
    assert_false(second.next_optional())


def deletion_during_iteration() raises:
    var values = JsSet[Float64]()
    for value in range(5):
        _ = values.add(Float64(value))
    var visited = String()
    for value in values.values():
        visited += String(Int(value))
        if value == 0:
            assert_true(values.delete(1))
            _ = values.add(5)
        if value == 2:
            assert_true(values.delete(0))
    assert_equal(visited, "02345")
    assert_equal(values.js_size(), 4)


def empty_and_exhausted_iterators() raises:
    var values = JsMap[Float64, Float64]()
    var closed = values.keys()
    assert_false(closed.next_optional())
    _ = values.set(1, 1)
    assert_false(closed.next_optional())
    var live = values.keys()
    _ = values.set(2, 2)
    var snapshot = array_from(live)
    assert_equal(len(snapshot), 2)
    assert_equal(snapshot.read_value(1), 2)
    assert_false(live.next_optional())


def signed_zero_and_nan() raises:
    var values = JsSet[Float64]()
    _ = values.add(-0.0)
    assert_equal(bitcast[.uint64](values.values().next_optional().value()), 0)
    _ = values.add(Float64("nan"))
    _ = values.add(Float64("nan"))
    assert_equal(values.js_size(), 2)
    assert_true(values.has(Float64("nan")))
    assert_true(values.delete(Float64("nan")))


def iterator_releases_finished_storage() raises:
    var values = JsSet[Float64]()
    _ = values.add(1)
    var iterator = values.values()
    assert_equal(values._values._data[].readers, 1)
    assert_equal(iterator.next_optional().value(), 1)
    assert_false(iterator.next_optional())
    assert_equal(values._values._data[].readers, 0)
    assert_true(values.delete(1))
    assert_equal(values._values.slot_count(), 0)


def main() raises:
    map_mutations()
    clear_and_reinsert()
    deletion_during_iteration()
    empty_and_exhausted_iterators()
    signed_zero_and_nan()
    iterator_releases_finished_storage()
    var values = JsSet[String]()
    _ = values.add("first")
    var iterator = values.values()
    var first = iterator.next(JsValue(7.0))
    assert_true(first.isa[JsIteratorYield[String]]())
    var yielded = first[JsIteratorYield[String]].copy()
    assert_false(yielded.get_done().value())
    assert_equal(yielded.get_value(), "first")
    var alias = yielded
    yielded.set_value("changed")
    assert_equal(alias.get_value(), "changed")
    var last = iterator.next()
    assert_true(last.isa[JsIteratorReturn[JsValue]]())
    assert_true(last[JsIteratorReturn[JsValue]].get_done())
    assert_true(last[JsIteratorReturn[JsValue]].get_value().is_undefined())
    _ = values.add("later")
    assert_true(iterator.next().isa[JsIteratorReturn[JsValue]]())
