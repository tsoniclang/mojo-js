from std.ffi import c_int, external_call
from ..value import JsValue, js_truthy
from .options import option_value, string_option, validate_unicode_type
from .number_precision import number_choice, number_precision


def _currency(options: JsValue) raises -> String:
    if option_value(options, "currency").is_undefined():
        return String()
    var value = string_option(options, "currency", "")
    var bytes = value.as_bytes()
    if len(bytes) != 3:
        raise Error("Currency must contain exactly three ASCII letters")
    for byte in bytes:
        if not ((byte >= 65 and byte <= 90) or (byte >= 97 and byte <= 122)):
            raise Error("Currency must contain exactly three ASCII letters")
    return value.upper()


def _grouping(options: JsValue, compact: Bool) raises -> String:
    var default = String("group-min2") if compact else String("group-auto")
    var grouping = option_value(options, "useGrouping")
    if grouping.is_undefined():
        return default^
    if grouping.is_string():
        var value = grouping.string_value().to_native_strict()
        if value == "true" or value == "false":
            return default^
        if value == "auto":
            return String("group-auto")
        if value == "min2":
            return String("group-min2")
        if value == "always":
            return String("group-on-aligned")
        raise Error("Invalid number formatting grouping strategy")
    return String("group-on-aligned") if js_truthy(grouping) else String("group-off")


def _sign(display: String, accounting: Bool) -> String:
    if display == "never":
        return String("sign-never")
    var prefix = String("sign-accounting") if accounting else String("sign")
    if display == "auto":
        return prefix if accounting else String("sign-auto")
    if display == "exceptZero":
        return prefix + "-except-zero"
    return prefix + "-" + display


struct NumberOptions(Movable):
    var skeleton: String
    var numbering: String

    def __init__(out self, options: JsValue) raises:
        _ = number_choice(options, "localeMatcher", "best fit", "lookup|best fit")
        self.numbering = String()
        if not option_value(options, "numberingSystem").is_undefined():
            self.numbering = string_option(options, "numberingSystem", "")
            validate_unicode_type(self.numbering)
        var style = number_choice(options, "style", "decimal", "decimal|percent|currency")
        var currency = _currency(options)
        var currency_display = number_choice(options, "currencyDisplay", "symbol", "code|symbol|narrowSymbol|name")
        var currency_sign = number_choice(options, "currencySign", "standard", "standard|accounting")
        var notation = number_choice(options, "notation", "standard", "standard|scientific|engineering|compact")
        var compact_display = number_choice(options, "compactDisplay", "short", "short|long")
        var minimum_fraction = 0
        var maximum_fraction = 3
        self.skeleton = String()
        if style == "currency":
            if currency == "":
                raise Error("Currency style requires an explicit currency")
            var digits = Int(external_call["tsonic_js_intl_currency_digits", c_int](currency.as_c_string_slice().ptr()))
            if digits < 0:
                raise Error("Unable to resolve currency fraction digits")
            minimum_fraction = digits
            maximum_fraction = digits
            var width = String("short")
            if currency_display == "code":
                width = String("iso-code")
            elif currency_display == "narrowSymbol":
                width = String("narrow")
            elif currency_display == "name":
                width = String("full-name")
            self.skeleton = "currency/" + currency + " unit-width-" + width + " "
        elif style == "percent":
            maximum_fraction = 0
            self.skeleton = String("percent scale/100 ")
        self.skeleton += number_precision(options, notation == "compact", minimum_fraction, maximum_fraction)
        if notation == "compact":
            self.skeleton += " compact-" + compact_display
        elif notation != "standard":
            self.skeleton += " " + notation
        self.skeleton += " " + _grouping(options, notation == "compact")
        var sign = number_choice(options, "signDisplay", "auto", "auto|never|always|exceptZero|negative")
        self.skeleton += " " + _sign(sign, style == "currency" and currency_sign == "accounting")
