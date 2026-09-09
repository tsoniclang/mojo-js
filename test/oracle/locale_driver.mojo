from std.pathlib import Path
from std.sys import argv
from tsonic_js import JsString, JsValue, json_parse, json_stringify, js_value_from_string, js_value_from_number, js_string_to_locale_lower_case, js_string_to_locale_upper_case, js_string_locale_compare
from tsonic_js import date_new, date_to_locale_string, date_to_locale_date_string, date_to_locale_time_string


def field(record: JsValue, name: String) raises -> JsValue:
    var value = record.object_get(JsString(name))
    return value.value() if value else JsValue()


def evaluate(record: JsValue) raises -> JsValue:
    var operation = field(record, "operation").string_value().to_native_strict()
    if operation == "date" or operation == "time" or operation == "datetime":
        var input = field(record, "value")
        var date = date_new(input.string_value()) if input.is_string() else date_new(input.number_value())
        var locales = field(record, "locales")
        var options = field(record, "options")
        var output = date_to_locale_date_string(date, locales, options) if operation == "date" else (
            date_to_locale_time_string(date, locales, options) if operation == "time" else date_to_locale_string(date, locales, options)
        )
        return js_value_from_string(JsString(output))
    var value = field(record, "value").string_value()
    var locales = field(record, "locales")
    if operation == "lower":
        return js_value_from_string(js_string_to_locale_lower_case(value, locales))
    if operation == "upper":
        return js_value_from_string(js_string_to_locale_upper_case(value, locales))
    if operation == "defaultLower":
        return js_value_from_string(value.to_lower_case())
    if operation == "defaultUpper":
        return js_value_from_string(value.to_upper_case())
    if operation == "compare":
        var order = js_string_locale_compare(value, field(record, "right").string_value(), locales, field(record, "options"))
        return js_value_from_number(-1.0 if order < 0 else 1.0 if order > 0 else 0.0)
    raise Error("Unknown locale oracle operation")


def main() raises:
    var arguments = argv()
    if len(arguments) != 2:
        raise Error("Expected the locale case input file")
    var source = Path(arguments[1]).read_text()
    for line in source.splitlines():
        try:
            var result = evaluate(json_parse(JsString(String(line))))
            print(json_stringify(result).to_native_strict())
        except:
            print("!error")
