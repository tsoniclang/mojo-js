from std import math
from ..value import JsValue
from .options import option_value, string_option


def number_option(
    value: JsValue, minimum: Int, maximum: Int, default: Int
) raises -> Int:
    if value.is_undefined():
        return default
    if not value.is_number():
        raise Error("Number formatting requires a numeric digit option")
    var number = value.number_value()
    if (
        not math.isfinite(number)
        or number < Float64(minimum)
        or number > Float64(maximum)
    ):
        raise Error("Number formatting digit option is out of range")
    return Int(math.floor(number))


def number_choice(
    options: JsValue, name: String, default: String, choices: String
) raises -> String:
    var value = string_option(options, name, default)
    for choice in choices.split("|"):
        if value == choice:
            return value^
    raise Error("Invalid number formatting option: ", name)


def _increment(value: Int, fraction: Int) -> String:
    var digits = String(value)
    if fraction == 0:
        return "precision-increment/" + digits
    if len(digits) <= fraction:
        return (
            "precision-increment/0." + "0" * (fraction - len(digits)) + digits
        )
    var split = len(digits) - fraction
    return (
        "precision-increment/"
        + String(digits[:split])
        + "."
        + String(digits[split:])
    )


@fieldwise_init
struct NumberPrecision(ImplicitlyCopyable):
    var skeleton: String
    var minimum_integer: Float64
    var minimum_fraction: Optional[Float64]
    var maximum_fraction: Optional[Float64]
    var minimum_significant: Optional[Float64]
    var maximum_significant: Optional[Float64]
    var rounding_increment: Float64
    var rounding_mode: String
    var rounding_priority: String
    var trailing_zero_display: String


def number_precision(
    options: JsValue, compact: Bool, default_minimum: Int, default_maximum: Int
) raises -> NumberPrecision:
    var minimum_integer = number_option(
        option_value(options, "minimumIntegerDigits"), 1, 21, 1
    )
    var minimum_fraction = option_value(options, "minimumFractionDigits")
    var maximum_fraction = option_value(options, "maximumFractionDigits")
    var minimum_significant = option_value(options, "minimumSignificantDigits")
    var maximum_significant = option_value(options, "maximumSignificantDigits")
    var increment = number_option(
        option_value(options, "roundingIncrement"), 1, 5000, 1
    )
    var increment_valid = False
    for allowed in String(
        "1|2|5|10|20|25|50|100|200|250|500|1000|2000|2500|5000"
    ).split("|"):
        if increment == Int(String(allowed)):
            increment_valid = True
    if not increment_valid:
        raise Error("Invalid number formatting rounding increment")
    var mode = number_choice(
        options,
        "roundingMode",
        "halfExpand",
        "ceil|floor|expand|trunc|halfCeil|halfFloor|halfExpand|halfTrunc|halfEven",
    )
    var priority = number_choice(
        options, "roundingPriority", "auto", "auto|morePrecision|lessPrecision"
    )
    var trailing = number_choice(
        options, "trailingZeroDisplay", "auto", "auto|stripIfInteger"
    )
    var rounding = String()
    var modes = String(
        "ceil|floor|expand|trunc|halfCeil|halfFloor|halfExpand|halfTrunc|halfEven"
    ).split("|")
    var native_modes = String(
        "ceiling|floor|up|down|half-ceiling|half-floor|half-up|half-down|half-even"
    ).split("|")
    for index in range(len(modes)):
        if mode == modes[index]:
            rounding = "rounding-mode-" + String(native_modes[index])
    var has_significant = (
        not minimum_significant.is_undefined()
        or not maximum_significant.is_undefined()
    )
    var has_fraction = (
        not minimum_fraction.is_undefined()
        or not maximum_fraction.is_undefined()
    )
    var need_significant = priority != "auto" or has_significant
    var need_fraction = priority != "auto" or (
        not has_significant and (has_fraction or not compact)
    )
    var significant = String()
    var fraction = String()
    var fraction_minimum = 0
    var fraction_maximum = 0
    var resolved_minimum_fraction = Optional[Float64]()
    var resolved_maximum_fraction = Optional[Float64]()
    var resolved_minimum_significant = Optional[Float64]()
    var resolved_maximum_significant = Optional[Float64]()
    if need_significant:
        var minimum = number_option(minimum_significant, 1, 21, 1)
        var maximum = number_option(maximum_significant, minimum, 21, 21)
        significant = "@" * minimum + "#" * (maximum - minimum)
        resolved_minimum_significant = Float64(minimum)
        resolved_maximum_significant = Float64(maximum)
    if need_fraction:
        var minimum = number_option(minimum_fraction, 0, 100, -1)
        var maximum = number_option(maximum_fraction, 0, 100, -1)
        var default_max = default_minimum if increment != 1 else default_maximum
        if minimum == -1:
            minimum = (
                min(default_minimum, maximum) if maximum
                != -1 else default_minimum
            )
        if maximum == -1:
            maximum = max(default_max, minimum)
        if minimum > maximum:
            raise Error(
                "Minimum fraction digits exceed maximum fraction digits"
            )
        fraction_minimum = minimum
        fraction_maximum = maximum
        fraction = "." + "0" * minimum + "#" * (maximum - minimum)
        resolved_minimum_fraction = Float64(minimum)
        resolved_maximum_fraction = Float64(maximum)
    if not need_fraction and not need_significant:
        fraction = String(".")
        significant = String("@#")
        priority = String("morePrecision")
        resolved_minimum_fraction = 0.0
        resolved_maximum_fraction = 0.0
        resolved_minimum_significant = 1.0
        resolved_maximum_significant = 2.0
    var precision = (
        significant if not need_fraction and need_significant else fraction
    )
    if priority != "auto":
        precision = (
            fraction
            + "/"
            + significant
            + ("r" if priority == "morePrecision" else "s")
        )
    if increment != 1:
        if (
            need_significant
            or priority != "auto"
            or fraction_minimum != fraction_maximum
        ):
            raise Error(
                "Rounding increments require equal fraction digits and"
                " automatic fraction precision"
            )
        precision = _increment(increment, fraction_minimum)
    if trailing == "stripIfInteger":
        precision += "/w"
    return NumberPrecision(
        precision + " " + rounding + " integer-width/*" + "0" * minimum_integer,
        Float64(minimum_integer),
        resolved_minimum_fraction,
        resolved_maximum_fraction,
        resolved_minimum_significant,
        resolved_maximum_significant,
        Float64(increment),
        mode^,
        priority^,
        trailing^,
    )
