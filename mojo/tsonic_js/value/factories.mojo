from std.collections import List
from std.memory import ArcPointer
from tsonic_runtime import RaisingCallable
from ..string import JsString
from ..symbol import JsSymbol
from .model import JsValue, _JsonProjectionState
from .builder import _JsValueBuilder
from .graph import _append_js_value_graph


def js_value_from_bool(value: Bool) -> JsValue:
    return JsValue(value)


def js_value_from_number(value: Float64) -> JsValue:
    return JsValue(value)


def js_value_from_string(value: JsString) -> JsValue:
    return JsValue(value)


def js_value_from_symbol(value: JsSymbol) -> JsValue:
    return JsValue(value)


def js_value_from_null() -> JsValue:
    return JsValue.null()


def js_value_from_undefined() -> JsValue:
    return JsValue.undefined()


def js_value_from_json_projection(
    project: RaisingCallable[Tuple[String], JsValue, Error]
) -> JsValue:
    return JsValue(ArcPointer(_JsonProjectionState(project)))


def js_value_from_array_values(var values: List[JsValue]) raises -> JsValue:
    var builder = _JsValueBuilder()
    var children = List[Int](capacity=len(values))
    var copied = List[JsValue]()
    var copied_indexes = List[Int]()
    for value in values^:
        children.append(
            _append_js_value_graph(
                builder, value, copied, copied_indexes, 0
            )
        )
    return builder.value(builder.append_array(children^))


def js_value_from_object_entries(
    var keys: List[JsString], var values: List[JsValue]
) raises -> JsValue:
    if len(keys) != len(values):
        raise Error("JavaScript object keys and values have different lengths")
    var builder = _JsValueBuilder()
    var copied_keys = List[JsString](capacity=len(keys))
    var children = List[Int](capacity=len(values))
    var copied = List[JsValue]()
    var copied_indexes = List[Int]()
    for index in range(len(keys)):
        copied_keys.append(keys[index])
        children.append(
            _append_js_value_graph(
                builder,
                values[index],
                copied,
                copied_indexes,
                0,
            )
        )
    return builder.value(builder.append_object(copied_keys^, children^))


def js_value_error(message: String) raises -> JsValue:
    var builder = _JsValueBuilder()
    var keys = List[JsString]()
    var children = List[Int]()
    keys.append(JsString("name"))
    children.append(builder.append_string(JsString("Error")))
    keys.append(JsString("message"))
    children.append(builder.append_string(JsString(message)))
    return builder.value(builder.append_object(keys^, children^))
