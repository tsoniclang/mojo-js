from std.ffi import c_int, external_call
from std.memory import ArcPointer
from tsonic_runtime import WeakReferenceIdentity
from ..array import JsArray
from ..date.factories import date_now
from ..string import JsString
from ..value import JsValue
from .date_options import DateOptions
from .date_value import date_value
from .datetime_options import IntlResolvedDateTimeFormatOptions
from .format_part import IntlFormatPart
from .locales import date_locale, requested_locales
from .native import IntlResult
from .parts import formatted_parts


struct IntlDateTimeFormat(Equatable, ImplicitlyCopyable):
    var _owner: ArcPointer[IntlResult]

    def __init__(out self, locales: JsValue = JsValue(), options: JsValue = JsValue()) raises:
        var requested = requested_locales(locales)
        var settings = DateOptions(options, "all", "date")
        var locale = date_locale(requested)
        var owner = IntlResult(external_call[
            "tsonic_js_intl_datetime_open", OptionalPointer[NoneType, MutUntrackedOrigin],
        ](locale.as_c_string_slice().ptr(), settings.zone.as_c_string_slice().ptr(), c_int(settings.has_zone),
          settings.calendar.as_c_string_slice().ptr(), settings.numbering.as_c_string_slice().ptr(),
          settings.skeleton.as_c_string_slice().ptr(), settings.date_style, settings.time_style,
          settings.hour12, settings.hour_cycle.as_c_string_slice().ptr(), c_int(settings.basic)))
        owner.check()
        self._owner = ArcPointer(owner^)

    def __eq__(self, other: Self) -> Bool:
        return self._owner is other._owner

    def weak_identity(self) -> WeakReferenceIdentity:
        return WeakReferenceIdentity(self._owner)

    def _result(self, value: Float64, parts: Bool) raises -> IntlResult:
        var result = IntlResult(external_call[
            "tsonic_js_intl_datetime_format", OptionalPointer[NoneType, MutUntrackedOrigin],
        ](self._owner[].pointer.value(), value, c_int(parts)))
        result.check()
        return result^

    def format(self) raises -> String:
        var result = self._result(date_now(), False)
        return JsString(code_units=result.units()).to_native_strict()

    def format[Value: Movable](self, value: Value) raises -> String:
        var result = self._result(date_value(value), False)
        return JsString(code_units=result.units()).to_native_strict()

    def format_to_parts(self) raises -> JsArray[IntlFormatPart]:
        var result = self._result(date_now(), True)
        return formatted_parts(result)

    def format_to_parts[Value: Movable](self, value: Value) raises -> JsArray[IntlFormatPart]:
        var result = self._result(date_value(value), True)
        return formatted_parts(result)

    def resolved_options(self) raises -> IntlResolvedDateTimeFormatOptions:
        return IntlResolvedDateTimeFormatOptions(self._owner[])


def intl_datetime_format_new(locales: JsValue = JsValue(), options: JsValue = JsValue()) raises -> IntlDateTimeFormat:
    return IntlDateTimeFormat(locales, options)
