from std.ffi import c_int, external_call
from std.memory import ArcPointer
from tsonic_runtime import WeakReferenceIdentity
from ..array import JsArray
from ..string import JsString
from ..value import JsValue
from .format_part import IntlFormatPart
from .locales import number_locale, requested_locales
from .native import IntlResult
from .number_options import NumberOptions
from .number_resolved import IntlResolvedNumberFormatOptions
from .number_value import number_result
from .parts import formatted_parts


@fieldwise_init
struct _NumberFormatOwner:
    var native: IntlResult
    var options: NumberOptions


struct IntlNumberFormat(Equatable, ImplicitlyCopyable):
    var _owner: ArcPointer[_NumberFormatOwner]

    def __init__(
        out self, locales: JsValue = JsValue(), options: JsValue = JsValue()
    ) raises:
        var requested = requested_locales(locales)
        var settings = NumberOptions(options)
        var locale = number_locale(requested)
        var native = IntlResult(
            external_call[
                "tsonic_js_intl_number_formatter_open",
                OptionalPointer[NoneType, MutUntrackedOrigin],
            ](
                locale.as_c_string_slice().unsafe_ptr(),
                settings.numbering.as_c_string_slice().unsafe_ptr(),
                settings.skeleton.as_c_string_slice().unsafe_ptr(),
                c_int(settings.style == "unit"),
            )
        )
        native.check()
        self._owner = ArcPointer(_NumberFormatOwner(native^, settings^))

    def __eq__(self, other: Self) -> Bool:
        return self._owner is other._owner

    def weak_identity(self) -> WeakReferenceIdentity:
        return WeakReferenceIdentity(self._owner)

    def format[dtype: DType](self, value: Scalar[dtype]) raises -> String:
        var result = number_result(self._owner[].native, value, False)
        return JsString(code_units=result.units()).to_native_strict()

    def format_to_parts[
        dtype: DType
    ](self, value: Scalar[dtype]) raises -> JsArray[IntlFormatPart]:
        var result = number_result(self._owner[].native, value, True)
        return formatted_parts(result)

    def format(self, value: Int) raises -> String:
        var result = number_result(self._owner[].native, value, False)
        return JsString(code_units=result.units()).to_native_strict()

    def format_to_parts(self, value: Int) raises -> JsArray[IntlFormatPart]:
        var result = number_result(self._owner[].native, value, True)
        return formatted_parts(result)

    def format(self, value: UInt) raises -> String:
        var result = number_result(self._owner[].native, value, False)
        return JsString(code_units=result.units()).to_native_strict()

    def format_to_parts(self, value: UInt) raises -> JsArray[IntlFormatPart]:
        var result = number_result(self._owner[].native, value, True)
        return formatted_parts(result)

    def resolved_options(self) raises -> IntlResolvedNumberFormatOptions:
        return IntlResolvedNumberFormatOptions(
            self._owner[].native, self._owner[].options
        )


def intl_number_format_new(
    locales: JsValue = JsValue(), options: JsValue = JsValue()
) raises -> IntlNumberFormat:
    return IntlNumberFormat(locales, options)
