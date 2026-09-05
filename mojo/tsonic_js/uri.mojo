from std.collections import List

from .string import JsString


def encode_uri_component(value: JsString) raises -> JsString:
    return JsString(encode_uri_component_native(value.to_native_strict()))


def decode_uri_component(value: JsString) raises -> JsString:
    return JsString(decode_uri_component_native(value.to_native_strict()))


def encode_uri_component_native(source: String) raises -> String:
    comptime digits = "0123456789ABCDEF"
    var result = String(capacity_bytes=source.byte_length() * 3)
    for index in range(source.byte_length()):
        var byte = UInt8(source.as_bytes()[index])
        if _is_component_byte(byte):
            result += String(source[byte=index])
        else:
            result += "%"
            result += String(digits[byte=Int(byte >> 4)])
            result += String(digits[byte=Int(byte & 15)])
    return result^


def decode_uri_component_native(source: String) raises -> String:
    var bytes = List[Byte](capacity=source.byte_length())
    var index = 0
    while index < source.byte_length():
        var byte = UInt8(source.as_bytes()[index])
        if byte != 37:
            bytes.append(Byte(byte))
            index += 1
            continue
        if index + 2 >= source.byte_length():
            raise Error("Malformed URI component escape")
        var high = _hex_value(UInt8(source.as_bytes()[index + 1]))
        var low = _hex_value(UInt8(source.as_bytes()[index + 2]))
        if high < 0 or low < 0:
            raise Error("Malformed URI component escape")
        bytes.append(Byte(UInt8(high * 16 + low)))
        index += 3
    return String(from_utf8=bytes)


def _is_component_byte(value: UInt8) -> Bool:
    return (
        (value >= 65 and value <= 90)
        or (value >= 97 and value <= 122)
        or (value >= 48 and value <= 57)
        or value == 45
        or value == 95
        or value == 46
        or value == 33
        or value == 126
        or value == 42
        or value == 39
        or value == 40
        or value == 41
    )


def _hex_value(value: UInt8) -> Int:
    if value >= 48 and value <= 57:
        return Int(value - 48)
    if value >= 65 and value <= 70:
        return Int(value - 65) + 10
    if value >= 97 and value <= 102:
        return Int(value - 97) + 10
    return -1
