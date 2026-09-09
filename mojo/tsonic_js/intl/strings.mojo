from std.ffi import c_int, c_size_t, external_call
from ..string import JsString
from ..value import JsValue
from .casing_units import convert_case_units
from .locales import case_locale, collation_locale, requested_locales
from .native import IntlResult
from .options import CollationOptions


def js_string_to_locale_lower_case(value: JsString, locales: JsValue = JsValue()) raises -> JsString:
    return JsString(code_units=convert_case_units(value._copy_code_units(), case_locale(locales), False))


def js_string_to_locale_upper_case(value: JsString, locales: JsValue = JsValue()) raises -> JsString:
    return JsString(code_units=convert_case_units(value._copy_code_units(), case_locale(locales), True))


def string_to_locale_lower_case(value: String, locales: JsValue = JsValue()) raises -> String:
    return js_string_to_locale_lower_case(JsString(value), locales).to_native_strict()


def string_to_locale_upper_case(value: String, locales: JsValue = JsValue()) raises -> String:
    return js_string_to_locale_upper_case(JsString(value), locales).to_native_strict()


def js_string_locale_compare(
    left: JsString, right: JsString, locales: JsValue = JsValue(), options: JsValue = JsValue(),
) raises -> Float64:
    var requested = requested_locales(locales)
    var settings = CollationOptions(options)
    var locale = collation_locale(requested)
    var first = left._copy_code_units()
    var second = right._copy_code_units()
    var result = IntlResult(external_call[
        "tsonic_js_intl_compare", OptionalPointer[NoneType, MutUntrackedOrigin],
    ](first.unsafe_ptr(), c_size_t(len(first)), second.unsafe_ptr(), c_size_t(len(second)),
      locale.as_c_string_slice().ptr(), settings.collation.as_c_string_slice().ptr(),
      c_int(settings.search), settings.numeric, settings.case_first, settings.sensitivity, settings.punctuation))
    return result.order()


def string_locale_compare(
    left: String, right: String, locales: JsValue = JsValue(), options: JsValue = JsValue(),
) raises -> Float64:
    return js_string_locale_compare(JsString(left), JsString(right), locales, options)
