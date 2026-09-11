from tsonic_runtime import RaisingCallable
from ..string import JsString
from ..value import JsValue
from .parser import _JsonParser
from .writer import _JsonWriter
from .formatting import _number_indent, _string_indent
from .property_list import json_property_list


def json_parse(source: JsString) raises -> JsValue:
    var parser = _JsonParser(source)
    return parser.parse()


def json_stringify_with_property_list(
    value: JsValue, properties: JsValue
) raises -> Optional[JsString]:
    return _stringify_properties(value, properties, JsString())


def json_stringify_with_property_list_and_space_number(
    value: JsValue, properties: JsValue, space: Float64
) raises -> Optional[JsString]:
    return _stringify_properties(value, properties, _number_indent(space))


def json_stringify_with_property_list_and_space_string(
    value: JsValue, properties: JsValue, space: JsString
) raises -> Optional[JsString]:
    return _stringify_properties(value, properties, _string_indent(space))


def _stringify_properties(
    value: JsValue, properties: JsValue, indent: JsString
) raises -> Optional[JsString]:
    var writer = _JsonWriter(json_property_list(properties), indent)
    if not writer.write_property(JsString(), value, 0):
        return None
    return Optional[JsString](writer.finish())


def json_stringify(value: JsValue) raises -> Optional[JsString]:
    var writer = _JsonWriter()
    if not writer.write_property(JsString(), value, 0):
        return None
    return Optional[JsString](writer.finish())


def json_stringify_for_inspection(value: JsValue) raises -> JsString:
    var writer = _JsonWriter()
    try:
        if not writer.write_property(JsString(), value, 0):
            return JsString("undefined")
        return writer.finish()
    except error:
        if writer.circular:
            return JsString("[Circular]")
        raise error


def json_stringify_with_space_number(
    value: JsValue, space: Float64
) raises -> Optional[JsString]:
    var writer = _JsonWriter(_number_indent(space))
    if not writer.write_property(JsString(), value, 0):
        return None
    return Optional[JsString](writer.finish())


def json_stringify_with_space_string(
    value: JsValue, space: JsString
) raises -> Optional[JsString]:
    var writer = _JsonWriter(_string_indent(space))
    if not writer.write_property(JsString(), value, 0):
        return None
    return Optional[JsString](writer.finish())


def json_stringify_with_replacer(
    value: JsValue,
    replacer: RaisingCallable[Tuple[String, JsValue], JsValue, Error],
) raises -> Optional[JsString]:
    var writer = _JsonWriter(replacer)
    if not writer.write_property(JsString(), value, 0):
        return None
    return Optional[JsString](writer.finish())


def json_stringify_with_replacer_and_space_number(
    value: JsValue,
    replacer: RaisingCallable[Tuple[String, JsValue], JsValue, Error],
    space: Float64,
) raises -> Optional[JsString]:
    var writer = _JsonWriter(replacer, _number_indent(space))
    if not writer.write_property(JsString(), value, 0):
        return None
    return Optional[JsString](writer.finish())


def json_stringify_with_replacer_and_space_string(
    value: JsValue,
    replacer: RaisingCallable[Tuple[String, JsValue], JsValue, Error],
    space: JsString,
) raises -> Optional[JsString]:
    var writer = _JsonWriter(replacer, _string_indent(space))
    if not writer.write_property(JsString(), value, 0):
        return None
    return Optional[JsString](writer.finish())
