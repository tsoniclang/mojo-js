from std import math

from .string import JsString


comptime NUMBER_EPSILON = 2.220446049250313e-16
comptime NUMBER_MAX_SAFE_INTEGER = 9007199254740991.0
comptime NUMBER_MAX_VALUE = 1.7976931348623157e308
comptime NUMBER_MIN_SAFE_INTEGER = -9007199254740991.0
comptime NUMBER_MIN_VALUE = 5e-324
comptime NUMBER_NAN = FloatLiteral.nan
comptime NUMBER_NEGATIVE_INFINITY = FloatLiteral.negative_infinity
comptime NUMBER_POSITIVE_INFINITY = FloatLiteral.infinity


def number_is_finite(value: Float64) -> Bool:
    return math.isfinite(value)


def number_is_integer(value: Float64) -> Bool:
    return math.isfinite(value) and math.trunc(value) == value


def number_is_nan(value: Float64) -> Bool:
    return math.isnan(value)


def number_is_safe_integer(value: Float64) -> Bool:
    return (
        number_is_integer(value) and math.abs(value) <= NUMBER_MAX_SAFE_INTEGER
    )


def number_parse_float(value: JsString) -> Float64:
    try:
        var text = _number_prefix(value.to_native_strict(), False)
        return atof(text)
    except:
        return Float64(FloatLiteral.nan)


def number_parse_int(value: JsString, radix: Float64 = 0) -> Float64:
    try:
        var text = String(value.to_native_strict().strip())
        if not text:
            return Float64(FloatLiteral.nan)
        var sign = 1
        var offset = 0
        if text.startswith("-"):
            sign = -1
            offset = 1
        elif text.startswith("+"):
            offset = 1
        var base = Int(radix)
        if base == 0:
            base = 16 if _has_hex_prefix(text, offset) else 10
        if base < 2 or base > 36:
            return Float64(FloatLiteral.nan)
        if base == 16 and _has_hex_prefix(text, offset):
            offset += 2
        var result = 0.0
        var digits = 0
        while offset < text.byte_length():
            var digit = _digit_value(UInt8(text.as_bytes()[offset]))
            if digit < 0 or digit >= base:
                break
            result = result * Float64(base) + Float64(digit)
            digits += 1
            offset += 1
        return (
            Float64(FloatLiteral.nan) if digits == 0 else Float64(sign) * result
        )
    except:
        return Float64(FloatLiteral.nan)


def _number_prefix(value: String, integer_only: Bool) -> String:
    var text = String(value.strip())
    var end = 0
    var saw_digit = False
    var saw_dot = False
    var saw_exponent = False
    while end < text.byte_length():
        var byte = UInt8(text.as_bytes()[end])
        if byte >= 48 and byte <= 57:
            saw_digit = True
            end += 1
            continue
        if end == 0 and (byte == 43 or byte == 45):
            end += 1
            continue
        if not integer_only and not saw_dot and not saw_exponent and byte == 46:
            saw_dot = True
            end += 1
            continue
        if (
            not integer_only
            and saw_digit
            and not saw_exponent
            and (byte == 69 or byte == 101)
        ):
            saw_exponent = True
            saw_digit = False
            end += 1
            if end < text.byte_length() and (
                UInt8(text.as_bytes()[end]) == 43
                or UInt8(text.as_bytes()[end]) == 45
            ):
                end += 1
            continue
        break
    if not saw_digit:
        return ""
    return String(text[byte=0:end])


def _has_hex_prefix(value: String, offset: Int) -> Bool:
    return (
        offset + 1 < value.byte_length()
        and UInt8(value.as_bytes()[offset]) == 48
        and (
            UInt8(value.as_bytes()[offset + 1]) == 88
            or UInt8(value.as_bytes()[offset + 1]) == 120
        )
    )


def _digit_value(value: UInt8) -> Int:
    if value >= 48 and value <= 57:
        return Int(value - 48)
    if value >= 65 and value <= 90:
        return Int(value - 65) + 10
    if value >= 97 and value <= 122:
        return Int(value - 97) + 10
    return -1
