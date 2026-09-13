from std.ffi import c_int, external_call
from ..value import JsValue, js_truthy
from .options import option_value, option_string, unicode_type_option
from .number_precision import NumberPrecision, number_choice, number_precision
from .number_unit import number_unit, number_unit_skeleton


def _currency(options: JsValue) raises -> String:
    var selected = option_value(options, "currency")
    if selected.is_undefined():
        return String()
    var value = option_string(selected, "")
    var bytes = value.as_bytes()
    if len(bytes) != 3:
        raise Error("Currency must contain exactly three ASCII letters")
    for byte in bytes:
        if not ((byte >= 65 and byte <= 90) or (byte >= 97 and byte <= 122)):
            raise Error("Currency must contain exactly three ASCII letters")
    return value.upper()


def _grouping(options: JsValue, compact: Bool) raises -> Optional[String]:
    var default = String("min2") if compact else String("auto")
    var grouping = option_value(options, "useGrouping")
    if grouping.is_undefined():
        return default^
    if grouping.is_string():
        var value = grouping.string_value().to_native_strict()
        if value == "true" or value == "false":
            return default^
        if value == "auto":
            return String("auto")
        if value == "min2":
            return String("min2")
        if value == "always":
            return String("always")
        raise Error("Invalid number formatting grouping strategy")
    if js_truthy(grouping):
        return String("always")
    return None


def _grouping_skeleton(grouping: Optional[String]) -> String:
    if not grouping:
        return String("group-off")
    if grouping.value() == "always":
        return String("group-on-aligned")
    return "group-" + grouping.value()


def _sign(display: String, accounting: Bool) -> String:
    if display == "never":
        return String("sign-never")
    var prefix = String("sign-accounting") if accounting else String("sign")
    if display == "auto":
        return prefix if accounting else String("sign-auto")
    if display == "exceptZero":
        return prefix + "-except-zero"
    return prefix + "-" + display


struct NumberOptions(ImplicitlyCopyable):
    var skeleton: String
    var numbering: String
    var style: String
    var currency: Optional[String]
    var currency_display: Optional[String]
    var currency_sign: Optional[String]
    var unit: Optional[String]
    var unit_display: Optional[String]
    var notation: String
    var compact_display: Optional[String]
    var grouping: Optional[String]
    var sign_display: String
    var precision: NumberPrecision

    def __init__(out self, options: JsValue) raises:
        _ = number_choice(
            options, "localeMatcher", "best fit", "lookup|best fit"
        )
        self.numbering = unicode_type_option(options, "numberingSystem")
        var style = number_choice(
            options, "style", "decimal", "decimal|percent|currency|unit"
        )
        var currency = _currency(options)
        var currency_display = number_choice(
            options,
            "currencyDisplay",
            "symbol",
            "code|symbol|narrowSymbol|name",
        )
        var currency_sign = number_choice(
            options, "currencySign", "standard", "standard|accounting"
        )
        var unit = number_unit(options, style == "unit")
        var unit_display = number_choice(
            options, "unitDisplay", "short", "short|long|narrow"
        )
        var notation = number_choice(
            options,
            "notation",
            "standard",
            "standard|scientific|engineering|compact",
        )
        self.style = style
        self.notation = notation
        self.currency = None
        self.currency_display = None
        self.currency_sign = None
        self.unit = None
        self.unit_display = None
        var minimum_fraction = 0
        var maximum_fraction = 3
        self.skeleton = String()
        if style == "currency":
            if currency == "":
                raise Error("Currency style requires an explicit currency")
            self.currency = currency
            self.currency_display = currency_display
            self.currency_sign = currency_sign
            var digits = Int(
                external_call["tsonic_js_intl_currency_digits", c_int](
                    currency.as_c_string_slice().unsafe_ptr()
                )
            )
            if digits < 0:
                raise Error("Unable to resolve currency fraction digits")
            if notation == "standard":
                minimum_fraction = digits
                maximum_fraction = digits
            var width = String("short")
            if currency_display == "code":
                width = String("iso-code")
            elif currency_display == "narrowSymbol":
                width = String("narrow")
            elif currency_display == "name":
                width = String("full-name")
            self.skeleton = (
                "currency/" + currency + " unit-width-" + width + " "
            )
        elif style == "percent":
            maximum_fraction = 0
            self.skeleton = String("percent scale/100 ")
        elif style == "unit":
            self.unit = unit
            self.unit_display = unit_display
            self.skeleton = number_unit_skeleton(unit.value(), unit_display)
        self.precision = number_precision(
            options, notation == "compact", minimum_fraction, maximum_fraction
        )
        self.skeleton += self.precision.skeleton
        var compact_display = number_choice(
            options, "compactDisplay", "short", "short|long"
        )
        self.compact_display = None
        if notation == "compact":
            self.compact_display = compact_display
            self.skeleton += " compact-" + compact_display
        elif notation != "standard":
            self.skeleton += " " + notation
        self.grouping = _grouping(options, notation == "compact")
        self.skeleton += " " + _grouping_skeleton(self.grouping)
        var sign = number_choice(
            options,
            "signDisplay",
            "auto",
            "auto|never|always|exceptZero|negative",
        )
        self.sign_display = sign
        self.skeleton += " " + _sign(
            sign, style == "currency" and currency_sign == "accounting"
        )
