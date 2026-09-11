from std.collections import List
from std.memory import bitcast
from std.collections.string import Codepoint
from tsonic_runtime.number_string import source_number_to_string
from .string import JsString
from .value import JsValue


def _escaped_unit(value: UInt32) -> String:
    var digits = "0123456789abcdef".as_bytes()
    var result = String("\\u")
    for shift in range(12, -1, -4):
        result += String(
            Codepoint(
                unsafe_unchecked_codepoint=UInt32(
                    digits[Int((value >> UInt32(shift)) & 15)]
                )
            )
        )
    return result


def quote_inspected_string(value: JsString) -> String:
    var result = String("'")
    var index = 0
    while index < len(value):
        var unit = UInt32(value.code_unit_at(index).value())
        index += 1
        if unit == 0x27:
            result += "\\'"
        elif unit == 0x5C:
            result += "\\\\"
        elif unit == 0x0A:
            result += "\\n"
        elif unit == 0x0D:
            result += "\\r"
        elif unit == 0x09:
            result += "\\t"
        elif unit == 0x08:
            result += "\\b"
        elif unit == 0x0C:
            result += "\\f"
        elif unit >= 0xD800 and unit <= 0xDBFF:
            if index < len(value):
                var low = UInt32(value.code_unit_at(index).value())
                if low >= 0xDC00 and low <= 0xDFFF:
                    result += String(
                        Codepoint(
                            unsafe_unchecked_codepoint=0x10000
                            + ((unit - 0xD800) << 10)
                            + low
                            - 0xDC00
                        )
                    )
                    index += 1
                    continue
            result += _escaped_unit(unit)
        elif (unit >= 0xDC00 and unit <= 0xDFFF) or unit < 0x20 or unit == 0x7F:
            result += _escaped_unit(unit)
        else:
            result += String(Codepoint(unsafe_unchecked_codepoint=unit))
    return result + "'"


def _plain_key(value: JsString) -> Bool:
    if len(value) == 0:
        return False
    for index in range(len(value)):
        var unit = value.code_unit_at(index).value()
        if (
            (unit >= 65 and unit <= 90)
            or (unit >= 97 and unit <= 122)
            or unit == 95
            or unit == 36
        ):
            continue
        if index != 0 and unit >= 48 and unit <= 57:
            continue
        return False
    return True


def inspect_value(
    value: JsValue, depth: Int = 2, array_limit: Int = 100,
    show_hidden: Bool = False,
) -> String:
    var active = List[JsValue]()
    return _inspect(value, depth, max(0, array_limit), show_hidden, active)


def _inspect(
    value: JsValue, depth: Int, array_limit: Int, show_hidden: Bool,
    mut active: List[JsValue]
) -> String:
    if value.is_undefined():
        return "undefined"
    if value.is_null():
        return "null"
    if value.is_bool():
        return "true" if value._bool_value() else "false"
    if value.is_number():
        var number = value._number_value()
        return "-0" if number == 0 and bitcast[.uint64](
            number
        ) != 0 else source_number_to_string(number)
    if value.is_bigint():
        return value._string_value().to_native_lossy() + "n"
    if value.is_string():
        return quote_inspected_string(value._string_value())
    var storage = value._storage()
    var node = value._node_index()
    if value.is_symbol():
        return String(storage[][node].symbol_value.value())
    if value.is_byte_view():
        var presentation = storage[][node].native_presentation
        if presentation:
            return presentation.value()[].inspect.call((array_limit,))
        var view = storage[][node].byte_view.value()
        var output = "Uint8Array(" + String(view.length) + ") ["
        var limit = min(view.length, array_limit)
        for index in range(limit):
            output += " " if index == 0 else ", "
            output += String(view.storage[][view.offset + index])
        if limit < view.length:
            output += ", " if limit else " "
            output += "... " + String(view.length - limit) + " more items"
        return output + (" ]" if view.length else "]")
    for ancestor in active:
        if ancestor.same_identity(value):
            return "[Circular]"
    var array = value.is_array()
    if depth < 0:
        return "[Array]" if array else "[Object]"
    var count = value._aggregate_length()
    if count == 0:
        if array and show_hidden:
            return "[ [length]: 0 ]"
        return "[]" if array else "{}"
    active.append(value)
    var result = String("[ " if array else "{ ")
    var limit = min(count, array_limit) if array else count
    var index = 0
    while index < limit:
        if index != 0:
            result += ", "
        if array and not value._aggregate_has(index):
            var start = index
            while index < limit and not value._aggregate_has(index):
                index += 1
            var missing = index - start
            result += (
                "<"
                + String(missing)
                + (" empty item>" if missing == 1 else " empty items>")
            )
            continue
        if not array:
            var key = value._aggregate_key(index)
            result += key.to_native_lossy() if _plain_key(
                key
            ) else quote_inspected_string(key)
            result += ": "
        result += _inspect(
            value._aggregate_value(index), depth - 1, array_limit, show_hidden, active
        )
        index += 1
    if limit != count:
        if limit != 0:
            result += ", "
        var remaining = count - limit
        result += (
            "... "
            + String(remaining)
            + (" more item" if remaining == 1 else " more items")
        )
    _ = active.pop()
    if array and show_hidden:
        result += ", [length]: " + String(count)
    return result + (" ]" if array else " }")
