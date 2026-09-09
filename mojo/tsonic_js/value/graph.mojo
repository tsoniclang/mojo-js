from std.collections import List
from ..string import JsString
from .model import JsValue
from .builder import _JsValueBuilder


def _append_js_value_graph(
    mut builder: _JsValueBuilder,
    value: JsValue,
    mut active: List[JsValue],
    mut copied: List[JsValue],
    mut copied_indexes: List[Int],
    depth: Int,
) raises -> Int:
    if depth > 512:
        raise Error("JavaScript value graph exceeds its nesting budget")
    if value.is_undefined():
        return builder.append_undefined()
    if value.is_null():
        return builder.append_null()
    if value.is_bool():
        return builder.append_bool(value._bool_value())
    if value.is_number():
        return builder.append_number(value._number_value())
    if value.is_string():
        return builder.append_string(value._string_value())
    if value.is_symbol():
        return builder.append_symbol(value.symbol_value())
    if value.is_json_projection():
        return builder.append_json_projection(value._json_projection())
    for ancestor in active:
        if ancestor.same_identity(value):
            raise Error("cyclic JavaScript value cannot be materialized")
    for index in range(len(copied)):
        if copied[index].same_identity(value):
            return copied_indexes[index]
    active.append(value)
    if value.is_array():
        var children = List[Int](capacity=value.array_length())
        for index in range(value.array_length()):
            children.append(
                _append_js_value_graph(
                    builder,
                    value.array_at(index),
                    active,
                    copied,
                    copied_indexes,
                    depth + 1,
                )
            )
        _ = active.pop()
        var target = builder.append_array(
            children^, value._aggregate_identity()
        )
        copied.append(value)
        copied_indexes.append(target)
        return target
    if value.is_object():
        var keys = List[JsString](capacity=value.object_length())
        var children = List[Int](capacity=value.object_length())
        for index in range(value.object_length()):
            keys.append(value.object_key(index))
            children.append(
                _append_js_value_graph(
                    builder,
                    value.object_value(index),
                    active,
                    copied,
                    copied_indexes,
                    depth + 1,
                )
            )
        _ = active.pop()
        var target = builder.append_object(
            keys^, children^, value._aggregate_identity()
        )
        copied.append(value)
        copied_indexes.append(target)
        return target
    _ = active.pop()
    raise Error("JavaScript value graph contains an unsupported node")

