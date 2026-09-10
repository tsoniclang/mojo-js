from tsonic_js import JsString, JsValue


def field(record: JsValue, name: String) raises -> JsValue:
    var value = record.object_get(JsString(name))
    return value.value() if value else JsValue()


def number_input(input: JsValue) raises -> Float64:
    if input.is_number():
        return input.number_value()
    var special = input.string_value().to_native_strict()
    if special == "-0":
        return Float64(-0.0)
    if special == "NaN":
        return Float64(FloatLiteral.nan)
    if special == "Infinity":
        return Float64(FloatLiteral.infinity)
    if special == "-Infinity":
        return Float64(FloatLiteral.negative_infinity)
    raise Error("Unknown numeric oracle input")
