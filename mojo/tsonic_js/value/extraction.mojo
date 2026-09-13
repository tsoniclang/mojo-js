from .model import JsValue
from tsonic_runtime import Null, Undefined


def js_value_null(value: JsValue) raises -> Null:
    if not value.is_null():
        raise Error("A selected null result has a different source value tag")
    return Null()


def js_value_undefined(value: JsValue) raises -> Undefined:
    if not value.is_undefined():
        raise Error(
            "A selected undefined result has a different source value tag"
        )
    return Undefined()


def js_value_bool(value: JsValue) raises -> Bool:
    return value.bool_value()


def js_value_number(value: JsValue) raises -> Float64:
    return value.number_value()


def js_value_native_string(value: JsValue) raises -> String:
    return value.string_value().to_native_strict()
