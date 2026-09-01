from .string import JsString


fn boolean_to_string(value: Bool) -> JsString:
    return JsString("true" if value else "false")


fn boolean_value_of(value: Bool) -> Bool:
    return value
