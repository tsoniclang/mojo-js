from std import math
from std.ffi import c_int, external_call
from ..date.model import JsDate
from ..string import JsString
from ..value import JsValue
from .date_options import DateOptions
from .locales import default_locale, requested_locales
from .native import IntlResult


def _date_locale(locales: JsValue) raises -> String:
    var requested = requested_locales(locales)
    for locale in requested:
        var candidate = String(locale)
        if external_call["tsonic_js_intl_date_available", c_int](candidate.as_c_string_slice().ptr()):
            return candidate^
    return default_locale()


def _present(value: JsDate, locales: JsValue, options: JsValue, required: String) raises -> String:
    if not math.isfinite(value.get_time()):
        return String("Invalid Date")
    var locale = _date_locale(locales)
    var settings = DateOptions(options, required)
    var result = IntlResult(external_call[
        "tsonic_js_intl_date", OptionalPointer[NoneType, MutUntrackedOrigin],
    ](value.get_time(), locale.as_c_string_slice().ptr(), settings.zone.as_c_string_slice().ptr(),
      c_int(settings.has_zone), settings.calendar.as_c_string_slice().ptr(), settings.numbering.as_c_string_slice().ptr(),
      settings.skeleton.as_c_string_slice().ptr(), settings.date_style, settings.time_style, settings.hour12,
      settings.hour_cycle.as_c_string_slice().ptr(), c_int(settings.basic)))
    return JsString(code_units=result.units()).to_native_strict()


def date_to_locale_string(value: JsDate, locales: JsValue = JsValue(), options: JsValue = JsValue()) raises -> String:
    return _present(value, locales, options, "all")


def date_to_locale_date_string(value: JsDate, locales: JsValue = JsValue(), options: JsValue = JsValue()) raises -> String:
    return _present(value, locales, options, "date")


def date_to_locale_time_string(value: JsDate, locales: JsValue = JsValue(), options: JsValue = JsValue()) raises -> String:
    return _present(value, locales, options, "time")
