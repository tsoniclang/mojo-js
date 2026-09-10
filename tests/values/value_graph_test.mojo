from std.collections import List
from std.testing import assert_equal, assert_false, assert_true
from tsonic_js import (
    JsString,
    JsValue,
    js_value_from_array_values,
    js_value_structured_clone,
    js_value_to_string,
    json_stringify,
)
from tsonic_js.inspection import inspect_value
from tsonic_js.value import _JsValueBuilder


def cyclic_array() raises -> JsValue:
    var builder = _JsValueBuilder()
    var root = builder.append_array(List[Int]())
    var first = builder.append_number(1)
    var last = builder.append_number(2)
    builder.set_aggregate_children(root, List[Int](first, root, last))
    return builder.value(root)


def main() raises:
    var source = cyclic_array()
    assert_true(source.same_identity(source.array_at(1)))
    assert_equal(js_value_to_string(source).to_native_strict(), "1,,2")
    assert_equal(inspect_value(source), "[ 1, [Circular], 2 ]")
    var clone = js_value_structured_clone(source)
    assert_false(source.same_identity(clone))
    assert_true(clone.same_identity(clone.array_at(1)))
    assert_equal(js_value_to_string(clone).to_native_strict(), "1,,2")
    var nested = js_value_from_array_values(List[JsValue](source, source))
    assert_true(nested.array_at(0).same_identity(nested.array_at(1)))
    assert_true(
        nested.array_at(0).same_identity(nested.array_at(0).array_at(1))
    )
    assert_equal(js_value_to_string(nested).to_native_strict(), "1,,2,1,,2")
    var nested_clone = js_value_structured_clone(nested)
    assert_true(
        nested_clone.array_at(0).same_identity(nested_clone.array_at(1))
    )
    assert_false(nested_clone.array_at(0).same_identity(source))
    var rejected = False
    try:
        _ = json_stringify(source)
    except:
        rejected = True
    assert_true(rejected)

    var builder = _JsValueBuilder()
    var first = builder.append_object(
        List[JsString](JsString("next")), List[Int]()
    )
    var second = builder.append_object(
        List[JsString](JsString("next")), List[Int](first)
    )
    builder.set_aggregate_children(first, List[Int](second))
    var object = builder.value(first)
    var copied = js_value_structured_clone(object)
    assert_true(copied.same_identity(copied.object_value(0).object_value(0)))
    assert_false(copied.same_identity(object))
    assert_equal(inspect_value(copied), "{ next: { next: [Circular] } }")

    var invalid_builder = _JsValueBuilder()
    var invalid = invalid_builder.append_array(List[Int](99))
    rejected = False
    try:
        _ = js_value_structured_clone(invalid_builder.value(invalid))
    except error:
        rejected = String(error).find("invalid reference") >= 0
    assert_true(rejected)
