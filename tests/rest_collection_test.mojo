from std.collections import List
from std.testing import assert_equal
from tsonic_js import (
    JsArray,
    JsString,
    native_string_concat,
    math_max,
    math_min,
)


@no_inline
def insert(values: JsArray[String], value: String) -> Float64:
    return values.push([value])


@no_inline
def insert_generic[
    T: Copyable & Deinitable
](values: JsArray[T], value: T) -> Float64:
    return values.push([value.copy()])


def main() raises:
    var values = JsArray[String]()
    var short_value = String("header.html")
    var long_value = String(
        "a heap-backed value longer than small-string storage"
    )
    assert_equal(insert(values, short_value), 1)
    assert_equal(insert_generic(values, long_value), 2)
    assert_equal(values.get(0).value(), short_value)
    assert_equal(values.get(1).value(), long_value)
    assert_equal(values.push(List[String]()), 2)
    assert_equal(values.push([short_value, long_value]), 4)
    assert_equal(values.unshift(["first", "second"]), 6)
    assert_equal(values.get(0).value(), "first")
    var removed = values.splice(2, items=List[String]())
    assert_equal(len(removed), 4)
    assert_equal(len(values), 2)
    assert_equal(
        native_string_concat(short_value, [".", "partial"]),
        "header.html.partial",
    )
    assert_equal(
        JsString("a").concat([JsString("b"), JsString("c")]).to_native_strict(),
        "abc",
    )
    assert_equal(
        math_max(List[Float64]()), Float64(FloatLiteral.negative_infinity)
    )
    assert_equal(math_min([3.0, 1.0, 2.0]), 1.0)
