from std.collections import List
from ..string import JsString
from .model import JsValue
from .builder import _JsValueBuilder


def _append_js_value_graph(
    mut builder: _JsValueBuilder,
    value: JsValue,
    mut copied: List[JsValue],
    mut copied_indexes: List[Int],
    depth: Int,
) raises -> Int:
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
    var view = value._nodes[][value._index].source_view
    if view:
        return builder.append_source_view(value._kind(), view.value())
    for index in range(len(copied)):
        if copied[index].same_identity(value):
            return copied_indexes[index]
    if depth > 512:
        raise Error("JavaScript value graph exceeds its nesting budget")
    if value.is_array():
        var target = builder.append_array(List[Int](), value._aggregate_identity())
        copied.append(value)
        copied_indexes.append(target)
        var children = List[Int](capacity=value.array_length())
        for index in range(value.array_length()):
            children.append(
                _append_js_value_graph(
                    builder,
                    value.array_at(index),
                    copied,
                    copied_indexes,
                    depth + 1,
                )
            )
        builder.set_aggregate_children(target, children^)
        return target
    if value.is_object():
        var keys = List[JsString](capacity=value.object_length())
        for index in range(value.object_length()):
            keys.append(value.object_key(index))
        var target = builder.append_object(keys^, List[Int](), value._aggregate_identity())
        copied.append(value)
        copied_indexes.append(target)
        var children = List[Int](capacity=value.object_length())
        for index in range(value.object_length()):
            children.append(
                _append_js_value_graph(
                    builder,
                    value.object_value(index),
                    copied,
                    copied_indexes,
                    depth + 1,
                )
            )
        builder.set_aggregate_children(target, children^)
        return target
    raise Error("JavaScript value graph contains an unsupported node")
