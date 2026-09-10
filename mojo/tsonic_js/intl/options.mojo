from ..string import JsString
from ..value import JsValue, js_value_to_string, js_truthy


def option_value(options: JsValue, name: String) raises -> JsValue:
    if options.is_null():
        raise Error("Internationalization options cannot be null")
    if options.is_object():
        return options.property_get(JsString(name))
    return JsValue()


def string_option(options: JsValue, name: String, default: String) raises -> String:
    return option_string(option_value(options, name), default)


def option_string(value: JsValue, default: String) raises -> String:
    if value.is_symbol():
        raise Error("A symbol cannot be converted to an internationalization option string")
    return default if value.is_undefined() else js_value_to_string(value).to_native_strict()


def unicode_type_option(options: JsValue, name: String) raises -> String:
    var selected = option_value(options, name)
    if selected.is_undefined():
        return String()
    var value = option_string(selected, "")
    validate_unicode_type(value)
    return value^


def boolean_option(options: JsValue, name: String) raises -> Int32:
    var value = option_value(options, name)
    return Int32(-1) if value.is_undefined() else Int32(js_truthy(value))


def validate_unicode_type(value: String) raises:
    if len(value) == 0:
        raise Error("Unicode locale type must be non-empty")
    for part in value.split("-"):
        var bytes = String(part).as_bytes()
        if len(bytes) < 3 or len(bytes) > 8:
            raise Error("Invalid Unicode locale type")
        for byte in bytes:
            if not ((byte >= 48 and byte <= 57) or (byte >= 65 and byte <= 90) or (byte >= 97 and byte <= 122)):
                raise Error("Invalid Unicode locale type")


struct CollationOptions(Copyable):
    var collation: String
    var search: Bool
    var numeric: Int32
    var case_first: Int32
    var sensitivity: Int32
    var punctuation: Int32

    def __init__(out self, options: JsValue) raises:
        var usage = string_option(options, "usage", "sort")
        if usage != "sort" and usage != "search":
            raise Error("Collation usage must be sort or search")
        self.search = usage == "search"
        var matcher = string_option(options, "localeMatcher", "best fit")
        if matcher != "lookup" and matcher != "best fit":
            raise Error("Locale matcher must be lookup or best fit")
        self.collation = unicode_type_option(options, "collation")
        self.numeric = boolean_option(options, "numeric")
        var case_value = option_value(options, "caseFirst")
        var case_first = option_string(case_value, "")
        if case_first == "":
            if not case_value.is_undefined():
                raise Error("Invalid collation case order")
            self.case_first = -1
        elif case_first == "false":
            self.case_first = 0
        elif case_first == "upper":
            self.case_first = 1
        elif case_first == "lower":
            self.case_first = 2
        else:
            raise Error("Invalid collation case order")
        var sensitivity_value = option_value(options, "sensitivity")
        var sensitivity = option_string(sensitivity_value, "")
        if sensitivity == "":
            if not sensitivity_value.is_undefined():
                raise Error("Invalid collation sensitivity")
            self.sensitivity = -1
        elif sensitivity == "base":
            self.sensitivity = 0
        elif sensitivity == "accent":
            self.sensitivity = 1
        elif sensitivity == "case":
            self.sensitivity = 2
        elif sensitivity == "variant":
            self.sensitivity = 3
        else:
            raise Error("Invalid collation sensitivity")
        self.punctuation = boolean_option(options, "ignorePunctuation")
