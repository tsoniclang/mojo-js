from std.utils import Variant
from tsonic_runtime import Null, Undefined

from .string import JsString


comptime JsPrimitiveValue = Variant[
    Undefined,
    Null,
    Bool,
    Float64,
    JsString,
]

comptime JsValue = JsPrimitiveValue


def js_value_from_bool(value: Bool) -> JsValue:
    return JsValue(value)


def js_value_from_number(value: Float64) -> JsValue:
    return JsValue(value)


def js_value_from_string(value: JsString) -> JsValue:
    return JsValue(value)


def js_value_from_null() -> JsValue:
    return JsValue(Null())


def js_value_from_undefined() -> JsValue:
    return JsValue(Undefined())


def js_truthy(value: JsValue) -> Bool:
    if value.isa[Undefined]() or value.isa[Null]():
        return False
    if value.isa[Bool]():
        return value[Bool]
    if value.isa[Float64]():
        var number = value[Float64]
        return number != 0 and number == number
    return len(value[JsString]) != 0
