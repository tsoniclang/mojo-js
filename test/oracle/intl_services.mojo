from std.collections import List
from tsonic_js import (
    IntlCollator,
    IntlDateTimeFormat,
    IntlFormatPart,
    IntlNumberFormat,
    IntlResolvedNumberFormatOptions,
    JsArray,
    JsString,
    JsValue,
    js_value_from_array_values,
    js_value_from_object_entries,
)
from locale_inputs import field, number_input, unsigned_input


def record_value(names: String, var values: List[JsValue]) raises -> JsValue:
    var keys = List[JsString]()
    for name in names.split("|"):
        keys.append(JsString(String(name)))
    return js_value_from_object_entries(keys^, values^)


def parts_value(parts: JsArray[IntlFormatPart]) raises -> JsValue:
    var values = List[JsValue]()
    for part in parts.iter_values():
        var fields = List[JsValue]()
        fields.append(JsValue(JsString(part.get_type())))
        fields.append(JsValue(JsString(part.get_value())))
        values.append(record_value("type|value", fields^))
    return js_value_from_array_values(values^)


def append_optional(
    mut names: List[JsString],
    mut values: List[JsValue],
    name: String,
    value: Optional[Float64],
):
    if value:
        names.append(JsString(name))
        values.append(JsValue(value.value()))


def append_optional(
    mut names: List[JsString],
    mut values: List[JsValue],
    name: String,
    value: Optional[String],
):
    if value:
        names.append(JsString(name))
        values.append(JsValue(JsString(value.value())))


def number_options_value(
    options: IntlResolvedNumberFormatOptions,
) raises -> JsValue:
    var names = List[JsString]()
    var values = List[JsValue]()
    names.append(JsString("locale"))
    values.append(JsValue(JsString(options.get_locale())))
    names.append(JsString("numberingSystem"))
    values.append(JsValue(JsString(options.get_numbering_system())))
    names.append(JsString("style"))
    values.append(JsValue(JsString(options.get_style())))
    append_optional(names, values, "currency", options.get_currency())
    append_optional(
        names, values, "currencyDisplay", options.get_currency_display()
    )
    append_optional(names, values, "currencySign", options.get_currency_sign())
    append_optional(names, values, "unit", options.get_unit())
    append_optional(names, values, "unitDisplay", options.get_unit_display())
    names.append(JsString("minimumIntegerDigits"))
    values.append(JsValue(options.get_minimum_integer_digits()))
    append_optional(
        names,
        values,
        "minimumFractionDigits",
        options.get_minimum_fraction_digits(),
    )
    append_optional(
        names,
        values,
        "maximumFractionDigits",
        options.get_maximum_fraction_digits(),
    )
    append_optional(
        names,
        values,
        "minimumSignificantDigits",
        options.get_minimum_significant_digits(),
    )
    append_optional(
        names,
        values,
        "maximumSignificantDigits",
        options.get_maximum_significant_digits(),
    )
    var grouping = options.get_use_grouping()
    names.append(JsString("useGrouping"))
    values.append(
        JsValue(grouping[Bool]) if grouping.isa[Bool]() else JsValue(
            JsString(grouping[String])
        )
    )
    names.append(JsString("notation"))
    values.append(JsValue(JsString(options.get_notation())))
    append_optional(
        names, values, "compactDisplay", options.get_compact_display()
    )
    names.append(JsString("signDisplay"))
    values.append(JsValue(JsString(options.get_sign_display())))
    names.append(JsString("roundingIncrement"))
    values.append(JsValue(options.get_rounding_increment()))
    names.append(JsString("roundingMode"))
    values.append(JsValue(JsString(options.get_rounding_mode())))
    names.append(JsString("roundingPriority"))
    values.append(JsValue(JsString(options.get_rounding_priority())))
    names.append(JsString("trailingZeroDisplay"))
    values.append(JsValue(JsString(options.get_trailing_zero_display())))
    return js_value_from_object_entries(names^, values^)


def number_service[
    dtype: DType
](
    formatter: IntlNumberFormat, value: Scalar[dtype], operation: String
) raises -> JsValue:
    if operation == "numberParts":
        return parts_value(formatter.format_to_parts(value))
    return JsValue(JsString(formatter.format(value)))


def evaluate_service(record: JsValue, operation: String) raises -> JsValue:
    var locales = field(record, "locales")
    var options = field(record, "options")
    if (
        operation == "numberFormat"
        or operation == "numberParts"
        or operation == "numberResolved"
    ):
        var formatter = IntlNumberFormat(locales, options)
        if operation == "numberResolved":
            return number_options_value(formatter.resolved_options())
        var input = field(record, "value")
        var kind = field(record, "numericKind")
        if (
            not kind.is_undefined()
            and kind.string_value().to_native_strict() == "integer"
        ):
            var decimal = input.string_value().to_native_strict()
            if decimal.startswith("-"):
                return number_service(formatter, Int64(Int(decimal)), operation)
            return number_service(
                formatter, UInt64(unsigned_input(decimal)), operation
            )
        return number_service(formatter, number_input(input), operation)
    if (
        operation == "dateFormat"
        or operation == "dateParts"
        or operation == "dateResolvedBase"
    ):
        var formatter = IntlDateTimeFormat(locales, options)
        if operation == "dateResolvedBase":
            var resolved = formatter.resolved_options()
            var values = List[JsValue]()
            values.append(JsValue(JsString(resolved.get_locale())))
            values.append(JsValue(JsString(resolved.get_calendar())))
            values.append(JsValue(JsString(resolved.get_numbering_system())))
            values.append(JsValue(JsString(resolved.get_time_zone())))
            return record_value(
                "locale|calendar|numberingSystem|timeZone", values^
            )
        var input = number_input(field(record, "value"))
        if operation == "dateParts":
            return parts_value(formatter.format_to_parts(input))
        return JsValue(JsString(formatter.format(input)))
    if operation == "collatorCompare" or operation == "collatorResolved":
        var collator = IntlCollator(locales, options)
        if operation == "collatorCompare":
            var order = collator.compare_units(
                field(record, "value").string_value(),
                field(record, "right").string_value(),
            )
            return JsValue(-1.0 if order < 0 else 1.0 if order > 0 else 0.0)
        var resolved = collator.resolved_options()
        var values = List[JsValue]()
        values.append(JsValue(JsString(resolved.get_locale())))
        values.append(JsValue(JsString(resolved.get_usage())))
        values.append(JsValue(JsString(resolved.get_sensitivity())))
        values.append(JsValue(resolved.get_ignore_punctuation()))
        values.append(JsValue(JsString(resolved.get_collation())))
        values.append(JsValue(resolved.get_numeric()))
        values.append(JsValue(JsString(resolved.get_case_first())))
        return record_value(
            "locale|usage|sensitivity|ignorePunctuation|collation|numeric|caseFirst",
            values^,
        )
    raise Error("Unknown Intl service oracle operation")
