from .string import JsString


def boolean_to_string(value: Bool) -> JsString:
    return JsString("true" if value else "false")


def boolean_value_of(value: Bool) -> Bool:
    return value
