from std import math, random


comptime MATH_E = 2.718281828459045
comptime MATH_LN10 = 2.302585092994046
comptime MATH_LN2 = 0.6931471805599453
comptime MATH_LOG10E = 0.4342944819032518
comptime MATH_LOG2E = 1.4426950408889634
comptime MATH_PI = 3.141592653589793
comptime MATH_SQRT1_2 = 0.7071067811865476
comptime MATH_SQRT2 = 1.4142135623730951


def math_abs(value: Float64) -> Float64:
    return math.abs(value)


def math_acos(value: Float64) -> Float64:
    return math.acos(value)


def math_acosh(value: Float64) -> Float64:
    return math.acosh(value)


def math_asin(value: Float64) -> Float64:
    return math.asin(value)


def math_asinh(value: Float64) -> Float64:
    return math.asinh(value)


def math_atan(value: Float64) -> Float64:
    return math.atan(value)


def math_atan2(y: Float64, x: Float64) -> Float64:
    return math.atan2(y, x)


def math_atanh(value: Float64) -> Float64:
    return math.atanh(value)


def math_cbrt(value: Float64) -> Float64:
    return math.cbrt(value)


def math_ceil(value: Float64) -> Float64:
    return math.ceil(value)


def math_clz32(value: Float64) -> Float64:
    var bits = _to_uint32(value)
    if bits == 0:
        return 32
    var count = 0
    var mask = UInt32(0x80000000)
    while (bits & mask) == 0:
        count += 1
        mask >>= 1
    return Float64(count)


def math_cos(value: Float64) -> Float64:
    return math.cos(value)


def math_cosh(value: Float64) -> Float64:
    return math.cosh(value)


def math_exp(value: Float64) -> Float64:
    return math.exp(value)


def math_expm1(value: Float64) -> Float64:
    return math.expm1(value)


def math_floor(value: Float64) -> Float64:
    return math.floor(value)


def math_fround(value: Float64) -> Float64:
    return Float64(Float32(value))


def math_hypot(*values: Float64) -> Float64:
    var scale = 0.0
    var sum = 0.0
    for value in values:
        if value != value:
            return value
        var magnitude = math.abs(value)
        if magnitude == Float64(FloatLiteral.infinity):
            return magnitude
        if magnitude > scale:
            var ratio = scale / magnitude
            sum = 1.0 + sum * ratio * ratio
            scale = magnitude
        elif magnitude != 0:
            var ratio = magnitude / scale
            sum += ratio * ratio
    return 0.0 if scale == 0 else scale * math.sqrt(sum)


def math_imul(left: Float64, right: Float64) -> Float64:
    var product = UInt64(_to_uint32(left)) * UInt64(_to_uint32(right))
    var low = UInt32(product & 0xFFFFFFFF)
    return Float64(Int64(low) - 0x100000000) if low >= 0x80000000 else Float64(
        low
    )


def math_log(value: Float64) -> Float64:
    return math.log(value)


def math_log10(value: Float64) -> Float64:
    return math.log10(value)


def math_log1p(value: Float64) -> Float64:
    return math.log1p(value)


def math_log2(value: Float64) -> Float64:
    return math.log2(value)


def math_max(*values: Float64) -> Float64:
    var result = Float64(FloatLiteral.negative_infinity)
    for value in values:
        if value != value:
            return value
        if value > result or (
            value == 0 and result == 0 and not _negative_zero(value)
        ):
            result = value
    return result


def math_min(*values: Float64) -> Float64:
    var result = Float64(FloatLiteral.infinity)
    for value in values:
        if value != value:
            return value
        if value < result or (
            value == 0 and result == 0 and _negative_zero(value)
        ):
            result = value
    return result


def math_pow(base: Float64, exponent: Float64) -> Float64:
    return math.pow(base, exponent)


def math_random() -> Float64:
    return random.random_float64()


def math_round(value: Float64) -> Float64:
    if (
        value != value
        or value == Float64(FloatLiteral.infinity)
        or value == Float64(FloatLiteral.negative_infinity)
        or value == 0
    ):
        return value
    var rounded = math.floor(value + 0.5)
    return -0.0 if rounded == 0 and value < 0 else rounded


def math_sign(value: Float64) -> Float64:
    if value != value or value == 0:
        return value
    return -1.0 if value < 0 else 1.0


def math_sin(value: Float64) -> Float64:
    return math.sin(value)


def math_sinh(value: Float64) -> Float64:
    return math.sinh(value)


def math_sqrt(value: Float64) -> Float64:
    return math.sqrt(value)


def math_tan(value: Float64) -> Float64:
    return math.tan(value)


def math_tanh(value: Float64) -> Float64:
    return math.tanh(value)


def math_trunc(value: Float64) -> Float64:
    return math.trunc(value)


def _to_uint32(value: Float64) -> UInt32:
    if (
        value != value
        or value == 0
        or value == Float64(FloatLiteral.infinity)
        or value == Float64(FloatLiteral.negative_infinity)
    ):
        return 0
    var integer = math.trunc(value)
    var modulo = integer - math.floor(integer / 4294967296.0) * 4294967296.0
    return UInt32(modulo)


def _negative_zero(value: Float64) -> Bool:
    return value == 0 and 1.0 / value == Float64(FloatLiteral.negative_infinity)
