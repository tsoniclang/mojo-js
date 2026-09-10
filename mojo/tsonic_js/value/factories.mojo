from std.collections import List
from std.memory import ArcPointer
from tsonic_runtime import Callable, RaisingCallable, WeakReferenceIdentity
from ..string import JsString
from ..symbol import JsSymbol
from .model import JsValue, _SourceValueView, _NativeValuePresentation, _JsValueNode, _ARRAY, _OBJECT
from .byte_view import JsByteView
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


def js_value_from_byte_view(view: JsByteView) -> JsValue:
    var nodes = List[_JsValueNode]()
    nodes.append(_JsValueNode(view))
    return JsValue(ArcPointer(nodes^), 0)


def js_value_from_native_bytes(
    view: JsByteView,
    brand: String,
    to_json: RaisingCallable[Tuple[String], JsValue, Error],
    to_string: Callable[Tuple[], JsString],
    inspect: Callable[Tuple[Int], String],
) -> JsValue:
    var presentation = ArcPointer(_NativeValuePresentation(brand, to_json, to_string, inspect))
    var nodes = List[_JsValueNode]()
    nodes.append(_JsValueNode(view, Optional(presentation)))
    return JsValue(ArcPointer(nodes^), 0)


def js_value_from_source_array(
    identity: WeakReferenceIdentity,
    length: Callable[Tuple[], Int],
    has: Callable[Tuple[Int], Bool],
    value: Callable[Tuple[Int], JsValue],
) -> JsValue:
    var view = ArcPointer(_SourceValueView(identity, length, None, Optional[Callable[Tuple[Int], Bool]](has), value, None, None))
    var nodes = List[_JsValueNode]()
    nodes.append(_JsValueNode(_ARRAY, view))
    return JsValue(ArcPointer(nodes^), 0)


def js_value_from_source_object(
    identity: WeakReferenceIdentity,
    length: Callable[Tuple[], Int],
    key: Callable[Tuple[Int], JsString],
    value: Callable[Tuple[Int], JsValue],
    to_json: Optional[RaisingCallable[Tuple[String], JsValue, Error]] = None,
    property_reader: Optional[RaisingCallable[Tuple[JsString], JsValue, Error]] = None,
) -> JsValue:
    var view = ArcPointer(_SourceValueView(identity, length, Optional[Callable[Tuple[Int], JsString]](key), None, value, to_json, property_reader))
    var nodes = List[_JsValueNode]()
    nodes.append(_JsValueNode(_OBJECT, view))
    return JsValue(ArcPointer(nodes^), 0)


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
