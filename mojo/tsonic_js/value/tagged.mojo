from std.collections import List
from ..string import JsString
from .model import JsValue
from .builder import _JsValueBuilder


def _js_value_from_tagged_callback_argument(value: JsValue) raises -> JsValue:
    var builder = _JsValueBuilder()
    var root = _append_tagged_callback_argument(builder, value)
    return builder.value(root)


def _append_tagged_callback_argument(
    mut builder: _JsValueBuilder, value: JsValue
) raises -> Int:
    var kind = _required_tagged_field(value, "kind").string_value()
    if kind == JsString("undefined"):
        return builder.append_undefined()
    if kind == JsString("null"):
        return builder.append_null()
    if kind == JsString("boolean"):
        return builder.append_bool(
            _required_tagged_field(value, "value").bool_value()
        )
    if kind == JsString("number"):
        return builder.append_number(
            _required_tagged_field(value, "value").number_value()
        )
    if kind == JsString("string"):
        return builder.append_string(
            _required_tagged_field(value, "value").string_value()
        )
    if kind == JsString("object"):
        var entries = _required_tagged_field(value, "entries")
        var keys = List[JsString]()
        var children = List[Int]()
        for index in range(entries.array_length()):
            var entry = entries.array_at(index)
            if entry.array_length() != 2:
                raise Error(
                    "JavaScript callback object entry has invalid arity"
                )
            keys.append(entry.array_at(0).string_value())
            children.append(
                _append_tagged_callback_argument(builder, entry.array_at(1))
            )
        return builder.append_object(keys^, children^)
    raise Error("JavaScript callback argument has an unsupported tagged kind")


def _required_tagged_field(value: JsValue, name: String) raises -> JsValue:
    var field = value.object_get(JsString(name))
    if not field:
        raise Error("JavaScript callback argument is missing field " + name)
    return field.value()
