from ..value import JsValue
from .options import option_string, option_value


def _single_unit(value: String) -> Bool:
    comptime units = (
        "|acre|bit|byte|celsius|centimeter|day|degree|fahrenheit|fluid-ounce|"
        "foot|gallon|gigabit|gigabyte|gram|hectare|hour|inch|kilobit|kilobyte|"
        "kilogram|kilometer|liter|megabit|megabyte|meter|microsecond|mile|"
        "mile-scandinavian|milliliter|millimeter|millisecond|minute|month|"
        "nanosecond|ounce|percent|petabyte|pound|second|stone|terabit|terabyte|"
        "week|yard|year|"
    )
    return (
        value != "" and "|" not in value and "|" + value + "|" in String(units)
    )


def number_unit(options: JsValue, required: Bool) raises -> Optional[String]:
    var selected = option_value(options, "unit")
    if selected.is_undefined():
        if required:
            raise Error("Unit style requires an explicit unit")
        return None
    var value = option_string(selected, "")
    if _single_unit(value):
        return value^
    var parts = value.split("-per-")
    if len(parts) != 2:
        raise Error("Invalid number formatting unit identifier")
    if not _single_unit(String(parts[0])) or not _single_unit(String(parts[1])):
        raise Error("Invalid number formatting unit identifier")
    return value^


def number_unit_skeleton(unit: String, display: String) -> String:
    var width = String("full-name") if display == "long" else display
    return "unit/" + unit + " unit-width-" + width + " "
