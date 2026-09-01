from std import math
from std.collections import List
from std.memory import bitcast

from .string import JsString


comptime NUMBER_EPSILON = 2.220446049250313e-16
comptime NUMBER_MAX_SAFE_INTEGER = 9007199254740991.0
comptime NUMBER_MAX_VALUE = 1.7976931348623157e308
comptime NUMBER_MIN_SAFE_INTEGER = -9007199254740991.0
comptime NUMBER_MIN_VALUE = 5e-324
comptime NUMBER_NAN = FloatLiteral.nan
comptime NUMBER_NEGATIVE_INFINITY = FloatLiteral.negative_infinity
comptime NUMBER_POSITIVE_INFINITY = FloatLiteral.infinity


def js_truthy_number(value: Float64) -> Bool:
    return value != 0 and value == value


def js_truthy_number(value: Float32) -> Bool:
    return value != 0 and value == value


def number_to_string(value: Float64) -> JsString:
    if value != value:
        return JsString("NaN")
    if value == Float64(FloatLiteral.infinity):
        return JsString("Infinity")
    if value == Float64(FloatLiteral.negative_infinity):
        return JsString("-Infinity")
    if value == 0:
        return JsString("0")
    var source = String(value)
    var bytes = source.as_bytes()
    var offset = 0
    var negative = False
    if bytes[0] == Byte(45):
        negative = True
        offset = 1
    var exponent_offset = source.byte_length()
    for index in range(offset, source.byte_length()):
        if bytes[index] == Byte(101):
            exponent_offset = index
            break
    var digits = List[UInt16]()
    var digits_before_decimal = 0
    var saw_decimal = False
    for index in range(offset, exponent_offset):
        if bytes[index] == Byte(46):
            digits_before_decimal = len(digits)
            saw_decimal = True
        else:
            digits.append(UInt16(bytes[index]))
    if not saw_decimal:
        digits_before_decimal = len(digits)
    var source_exponent = 0
    if exponent_offset < source.byte_length():
        var index = exponent_offset + 1
        var exponent_negative = False
        if bytes[index] == Byte(43) or bytes[index] == Byte(45):
            exponent_negative = bytes[index] == Byte(45)
            index += 1
        while index < source.byte_length():
            source_exponent = source_exponent * 10 + Int(
                UInt8(bytes[index]) - 48
            )
            index += 1
        if exponent_negative:
            source_exponent = -source_exponent
    var leading = 0
    while leading < len(digits) and digits[leading] == 48:
        leading += 1
    var decimal_exponent = digits_before_decimal - leading - 1 + source_exponent
    var significant = List[UInt16]()
    for index in range(leading, len(digits)):
        significant.append(digits[index])
    while len(significant) > 1 and significant[len(significant) - 1] == 48:
        _ = significant.pop()
    var result = List[UInt16]()
    if negative:
        result.append(45)
    if decimal_exponent >= 21 or decimal_exponent <= -7:
        result.append(significant[0])
        if len(significant) > 1:
            result.append(46)
            for index in range(1, len(significant)):
                result.append(significant[index])
        result.append(101)
        result.append(UInt16(43 if decimal_exponent >= 0 else 45))
        _append_decimal_integer(result, abs(decimal_exponent))
    elif decimal_exponent < 0:
        result.append(48)
        result.append(46)
        for _ in range(-decimal_exponent - 1):
            result.append(48)
        for digit in significant:
            result.append(digit)
    else:
        var integer_digits = decimal_exponent + 1
        for index in range(integer_digits):
            result.append(
                significant[index] if index < len(significant) else UInt16(48)
            )
        if integer_digits < len(significant):
            result.append(46)
            for index in range(integer_digits, len(significant)):
                result.append(significant[index])
    return JsString(code_units=result^)


def number_value_of(value: Float64) -> Float64:
    return value


def number_to_string_radix(value: Int8, radix: Float64) raises -> JsString:
    return _signed_to_string_radix(Int64(value), radix)


def number_to_string_radix(value: UInt8, radix: Float64) raises -> JsString:
    return _unsigned_to_string_radix(UInt64(value), radix)


def number_to_string_radix(value: Int16, radix: Float64) raises -> JsString:
    return _signed_to_string_radix(Int64(value), radix)


def number_to_string_radix(value: UInt16, radix: Float64) raises -> JsString:
    return _unsigned_to_string_radix(UInt64(value), radix)


def number_to_string_radix(value: Int32, radix: Float64) raises -> JsString:
    return _signed_to_string_radix(Int64(value), radix)


def number_to_string_radix(value: UInt32, radix: Float64) raises -> JsString:
    return _unsigned_to_string_radix(UInt64(value), radix)


def number_to_string_radix(value: Int64, radix: Float64) raises -> JsString:
    return _signed_to_string_radix(value, radix)


def number_to_string_radix(value: UInt64, radix: Float64) raises -> JsString:
    return _unsigned_to_string_radix(value, radix)


def number_to_string_radix(value: Int, radix: Float64) raises -> JsString:
    return _signed_to_string_radix(Int64(value), radix)


def number_to_string_radix(value: UInt, radix: Float64) raises -> JsString:
    return _unsigned_to_string_radix(UInt64(value), radix)


def _signed_to_string_radix(value: Int64, radix: Float64) raises -> JsString:
    if value >= 0:
        return _unsigned_to_string_radix(UInt64(value), radix)
    var magnitude = UInt64(-(value + 1)) + 1
    return _unsigned_to_string_radix(magnitude, radix, True)


def _unsigned_to_string_radix(
    value: UInt64, radix: Float64, negative: Bool = False
) raises -> JsString:
    var base = _format_count(radix, 2, 36, "toString radix")
    var reversed = List[UInt16]()
    var remaining = value
    if remaining == 0:
        reversed.append(48)
    while remaining != 0:
        var digit = Int(remaining % UInt64(base))
        reversed.append(UInt16(48 + digit if digit < 10 else 87 + digit))
        remaining //= UInt64(base)
    var output = List[UInt16]()
    if negative:
        output.append(45)
    var index = len(reversed) - 1
    while index >= 0:
        output.append(reversed[index])
        index -= 1
    return JsString(code_units=output^)


def number_to_fixed(
    value: Float64, fraction_digits: Float64 = 0
) raises -> JsString:
    var digits = _format_count(
        fraction_digits, 0, 100, "toFixed fraction digits"
    )
    if not math.isfinite(value) or math.abs(value) >= 1e21:
        return number_to_string(value)
    var exact = _exact_decimal(math.abs(value))
    var scale = exact.scale
    var coefficient = exact.coefficient.copy()
    var shift = scale - digits
    var rounded = List[UInt16]()
    if shift <= 0:
        rounded = coefficient^
        for _ in range(-shift):
            rounded.append(48)
    else:
        var keep = len(coefficient) - shift
        if keep < 0:
            rounded.append(48)
        elif keep == 0:
            rounded.append(UInt16(49 if coefficient[0] >= 53 else 48))
        else:
            rounded = _round_decimal_digits(coefficient^, keep)
    var output = List[UInt16]()
    if _is_negative_nonzero(value):
        output.append(45)
    if digits == 0:
        for unit in rounded:
            output.append(unit)
        return JsString(code_units=output^)
    if len(rounded) <= digits:
        output.append(48)
        output.append(46)
        for _ in range(digits - len(rounded)):
            output.append(48)
        for unit in rounded:
            output.append(unit)
    else:
        var decimal = len(rounded) - digits
        for index in range(len(rounded)):
            if index == decimal:
                output.append(46)
            output.append(rounded[index])
    return JsString(code_units=output^)


def number_to_exponential(
    value: Float64,
    fraction_digits: Optional[Float64] = None,
) raises -> JsString:
    if not fraction_digits:
        return _shortest_exponential(value)
    var digits = _format_count(
        fraction_digits.value(), 0, 100, "toExponential fraction digits"
    )
    return _format_significant(value, digits + 1, True)


def number_to_exponential_default(value: Float64) -> JsString:
    return _shortest_exponential(value)


def number_to_exponential_digits(
    value: Float64, fraction_digits: Float64
) raises -> JsString:
    var digits = _format_count(
        fraction_digits, 0, 100, "toExponential fraction digits"
    )
    return _format_significant(value, digits + 1, True)


def number_to_precision(
    value: Float64,
    precision: Optional[Float64] = None,
) raises -> JsString:
    if not precision:
        return number_to_string(value)
    var digits = _format_count(
        precision.value(), 1, 100, "toPrecision precision"
    )
    return _format_significant(value, digits, False)


def number_to_precision_default(value: Float64) -> JsString:
    return number_to_string(value)


def number_to_precision_digits(
    value: Float64, precision: Float64
) raises -> JsString:
    var digits = _format_count(precision, 1, 100, "toPrecision precision")
    return _format_significant(value, digits, False)


def _format_significant(
    value: Float64, precision: Int, exponential: Bool
) raises -> JsString:
    if not math.isfinite(value):
        return number_to_string(value)
    if value == 0:
        var zero = List[UInt16]()
        zero.append(48)
        if precision > 1:
            zero.append(46)
            for _ in range(precision - 1):
                zero.append(48)
        if exponential:
            _append_exponent(zero, 0)
        return JsString(code_units=zero^)
    var exact = _exact_decimal(math.abs(value))
    var scale = exact.scale
    var coefficient = exact.coefficient.copy()
    var exponent = len(coefficient) - scale - 1
    var rounded = _round_decimal_digits(coefficient^, precision)
    if len(rounded) > precision:
        exponent += 1
        _ = rounded.pop()
    while len(rounded) < precision:
        rounded.append(48)
    var use_exponential = exponential or exponent < -6 or exponent >= precision
    var output = List[UInt16]()
    if _is_negative_nonzero(value):
        output.append(45)
    if use_exponential:
        output.append(rounded[0])
        if precision > 1:
            output.append(46)
            for index in range(1, precision):
                output.append(rounded[index])
        _append_exponent(output, exponent)
        return JsString(code_units=output^)
    var integer_digits = exponent + 1
    if integer_digits <= 0:
        output.append(48)
        output.append(46)
        for _ in range(-integer_digits):
            output.append(48)
        for unit in rounded:
            output.append(unit)
    elif integer_digits >= precision:
        for unit in rounded:
            output.append(unit)
        for _ in range(integer_digits - precision):
            output.append(48)
    else:
        for index in range(precision):
            if index == integer_digits:
                output.append(46)
            output.append(rounded[index])
    return JsString(code_units=output^)


def _shortest_exponential(value: Float64) -> JsString:
    if not math.isfinite(value) or value == 0:
        var result = number_to_string(value)
        if value == 0:
            return JsString("0e+0")
        return result
    var source = number_to_string(value)
    var negative = _is_negative_nonzero(value)
    var start = 1 if negative else 0
    var exponent_marker = -1
    for index in range(start, len(source)):
        var unit = source.code_unit_at(index).value()
        if unit == 101:
            exponent_marker = index
            break
    if exponent_marker >= 0:
        return source
    var decimal = -1
    for index in range(start, len(source)):
        if source.code_unit_at(index).value() == 46:
            decimal = index
            break
    var significant = List[UInt16]()
    var exponent: Int
    if decimal < 0:
        exponent = len(source) - start - 1
        for index in range(start, len(source)):
            significant.append(source.code_unit_at(index).value())
    elif decimal > start:
        exponent = decimal - start - 1
        for index in range(start, len(source)):
            if index != decimal:
                significant.append(source.code_unit_at(index).value())
    else:
        var first = decimal + 1
        while first < len(source) and source.code_unit_at(first).value() == 48:
            first += 1
        exponent = -(first - decimal)
        for index in range(first, len(source)):
            significant.append(source.code_unit_at(index).value())
    var output = List[UInt16]()
    if negative:
        output.append(45)
    output.append(significant[0])
    if len(significant) > 1:
        output.append(46)
        for index in range(1, len(significant)):
            output.append(significant[index])
    _append_exponent(output, exponent)
    return JsString(code_units=output^)


def _format_count(
    value: Float64, minimum: Int, maximum: Int, name: String
) raises -> Int:
    var count = 0 if value != value or value == 0 else Int(math.trunc(value))
    if not math.isfinite(value) or count < minimum or count > maximum:
        raise Error(
            name
            + " must be between "
            + String(minimum)
            + " and "
            + String(maximum)
        )
    return count


def _is_negative_nonzero(value: Float64) -> Bool:
    return value != 0 and (bitcast[.uint64](value) >> 63) == 1


def _exact_decimal(value: Float64) -> _ExactDecimal:
    var bits = bitcast[.uint64](value)
    var raw_exponent = Int((bits >> 52) & 0x7FF)
    var mantissa = bits & 0x000FFFFFFFFFFFFF
    var binary_exponent = -1074
    if raw_exponent != 0:
        mantissa |= UInt64(1) << 52
        binary_exponent = raw_exponent - 1023 - 52
    var coefficient = _DecimalCoefficient(mantissa)
    var scale = 0
    if binary_exponent >= 0:
        for _ in range(binary_exponent):
            coefficient.multiply(2)
    else:
        scale = -binary_exponent
        for _ in range(scale):
            coefficient.multiply(5)
        while scale > 0 and coefficient.divisible_by_ten():
            coefficient.divide_by_ten()
            scale -= 1
    return _ExactDecimal(coefficient.digits(), scale)


def _round_decimal_digits(var digits: List[UInt16], keep: Int) -> List[UInt16]:
    if len(digits) <= keep:
        while len(digits) < keep:
            digits.append(48)
        return digits^
    var round_up = digits[keep] >= 53
    while len(digits) > keep:
        _ = digits.pop()
    if not round_up:
        return digits^
    var index = keep - 1
    while index >= 0 and digits[index] == 57:
        digits[index] = 48
        index -= 1
    if index >= 0:
        digits[index] += 1
    else:
        digits.insert(0, 49)
    return digits^


def _append_exponent(mut output: List[UInt16], exponent: Int):
    output.append(101)
    output.append(UInt16(43 if exponent >= 0 else 45))
    _append_decimal_integer(output, abs(exponent))


struct _ExactDecimal(Movable):
    var coefficient: List[UInt16]
    var scale: Int

    def __init__(out self, var coefficient: List[UInt16], scale: Int):
        self.coefficient = coefficient^
        self.scale = scale


struct _DecimalCoefficient(Movable):
    var chunks: List[UInt32]

    def __init__(out self, value: UInt64):
        self.chunks = List[UInt32]()
        self.chunks.append(UInt32(value % 1000000000))
        var upper = value / 1000000000
        if upper != 0:
            self.chunks.append(UInt32(upper))

    def multiply(mut self, factor: UInt32):
        var carry = UInt64(0)
        for index in range(len(self.chunks)):
            var product = UInt64(self.chunks[index]) * UInt64(factor) + carry
            self.chunks[index] = UInt32(product % 1000000000)
            carry = product / 1000000000
        if carry != 0:
            self.chunks.append(UInt32(carry))

    def divisible_by_ten(self) -> Bool:
        return self.chunks[0] % 10 == 0

    def divide_by_ten(mut self):
        var carry = UInt64(0)
        var index = len(self.chunks) - 1
        while index >= 0:
            var current = carry * 1000000000 + UInt64(self.chunks[index])
            self.chunks[index] = UInt32(current / 10)
            carry = current % 10
            index -= 1
        if len(self.chunks) > 1 and self.chunks[len(self.chunks) - 1] == 0:
            _ = self.chunks.pop()

    def digits(self) -> List[UInt16]:
        var output = List[UInt16]()
        var index = len(self.chunks) - 1
        _append_decimal_integer(output, Int(self.chunks[index]))
        index -= 1
        while index >= 0:
            var text = String(self.chunks[index])
            for _ in range(9 - text.byte_length()):
                output.append(48)
            for byte in text.as_bytes():
                output.append(UInt16(byte))
            index -= 1
        return output^


def _append_decimal_integer(mut output: List[UInt16], value: Int):
    var text = String(value)
    for byte in text.as_bytes():
        output.append(UInt16(byte))


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
