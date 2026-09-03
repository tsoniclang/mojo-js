from std.collections import List
from std.ffi import c_int, c_size_t, external_call

from .string import JsString


comptime _NFC = 1
comptime _NFD = 2
comptime _NFKC = 3
comptime _NFKD = 4


def string_normalize(value: String) raises -> String:
    return string_normalize(value, "NFC")


def string_normalize(value: String, form: String) raises -> String:
    return _normalize(JsString(value), form).to_native_strict()


def js_string_normalize(value: JsString) raises -> JsString:
    return _normalize(value, "NFC")


def js_string_normalize(value: JsString, form: String) raises -> JsString:
    return _normalize(value, form)


def _normalize(value: JsString, form: String) raises -> JsString:
    var source = value._copy_code_units()
    var result = external_call[
        "tsonic_js_unicode_normalize",
        OptionalPointer[NoneType, MutUntrackedOrigin],
    ](source.unsafe_ptr(), c_size_t(len(source)), _normalization_form(form))
    if not result:
        raise Error("Unable to allocate Unicode normalization result")
    var result_pointer = result.value()
    if external_call["tsonic_js_unicode_normalize_failed", c_int](
        result_pointer
    ):
        var error = external_call[
            "tsonic_js_unicode_normalize_error",
            OptionalPointer[UInt8, ImmUntrackedOrigin],
        ](result_pointer)
        var message = String(
            unsafe_from_utf8_ptr=error.value()
        ) if error else String("Unicode normalization failed")
        external_call["tsonic_js_unicode_normalize_result_free", NoneType](
            result_pointer
        )
        raise Error(message^)
    var length = Int(
        external_call["tsonic_js_unicode_normalize_length", c_size_t](
            result_pointer
        )
    )
    var units = external_call[
        "tsonic_js_unicode_normalize_units",
        OptionalPointer[UInt16, ImmUntrackedOrigin],
    ](result_pointer)
    if length != 0 and not units:
        external_call["tsonic_js_unicode_normalize_result_free", NoneType](
            result_pointer
        )
        raise Error("Unicode normalization produced no output")
    var output = List[UInt16](capacity=length)
    if units:
        for index in range(length):
            output.append(units.value()[unsafe_offset=index])
    external_call["tsonic_js_unicode_normalize_result_free", NoneType](
        result_pointer
    )
    return JsString(code_units=output^)


def _normalization_form(form: String) raises -> c_int:
    if form == "NFC":
        return c_int(_NFC)
    if form == "NFD":
        return c_int(_NFD)
    if form == "NFKC":
        return c_int(_NFKC)
    if form == "NFKD":
        return c_int(_NFKD)
    raise Error("Invalid Unicode normalization form " + form)
