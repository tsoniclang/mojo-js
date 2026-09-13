from std.ffi import c_int, external_call
from ..string import JsString
from ..value import JsValue
from .locales import number_locale, requested_locales
from .native import IntlResult
from .number_options import NumberOptions


def _present[
    origin: Origin
](
    value: Float64,
    decimal: OptionalPointer[Int8, origin],
    locales: JsValue,
    options: JsValue,
) raises -> String:
    var requested = requested_locales(locales)
    var settings = NumberOptions(options)
    var locale = number_locale(requested)
    var result = IntlResult(
        external_call[
            "tsonic_js_intl_number",
            OptionalPointer[NoneType, MutUntrackedOrigin],
        ](
            value,
            decimal,
            locale.as_c_string_slice().ptr(),
            settings.numbering.as_c_string_slice().ptr(),
            settings.skeleton.as_c_string_slice().ptr(),
        )
    )
    return JsString(code_units=result.units()).to_native_strict()


def number_to_locale_string[
    dtype: DType
](
    value: Scalar[dtype],
    locales: JsValue = JsValue(),
    options: JsValue = JsValue(),
) raises -> String:
    comptime if dtype.is_integral():
        var decimal = String(value)
        return _present(
            0.0, decimal.as_c_string_slice().ptr(), locales, options
        )
    else:
        return _present(
            Float64(value),
            OptionalPointer[Int8, ImmUntrackedOrigin](),
            locales,
            options,
        )


def number_to_locale_string(
    value: Int, locales: JsValue = JsValue(), options: JsValue = JsValue()
) raises -> String:
    var decimal = String(value)
    return _present(0.0, decimal.as_c_string_slice().ptr(), locales, options)


def number_to_locale_string(
    value: UInt, locales: JsValue = JsValue(), options: JsValue = JsValue()
) raises -> String:
    var decimal = String(value)
    return _present(0.0, decimal.as_c_string_slice().ptr(), locales, options)
