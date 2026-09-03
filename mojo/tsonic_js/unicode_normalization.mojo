from std.collections import List
from std.ffi import c_int, external_call

from .string import JsString


comptime _U_ZERO_ERROR = 0
comptime _U_BUFFER_OVERFLOW_ERROR = 15


def string_normalize(value: String) raises -> String:
    return string_normalize(value, "NFC")


def string_normalize(value: String, form: String) raises -> String:
    return _normalize(JsString(value), form).to_native_strict()


def js_string_normalize(value: JsString) raises -> JsString:
    return _normalize(value, "NFC")


def js_string_normalize(value: JsString, form: String) raises -> JsString:
    return _normalize(value, form)


def _normalize(value: JsString, form: String) raises -> JsString:
    var status = c_int(_U_ZERO_ERROR)
    var normalizer = _normalizer(form, Pointer(to=status))
    if not normalizer or status != _U_ZERO_ERROR:
        raise Error("Unable to initialize Unicode normalization form " + form)
    var source = value._copy_code_units()
    status = c_int(_U_ZERO_ERROR)
    var required = Int(
        external_call["unorm2_normalize_78", c_int](
            normalizer.value(),
            source.unsafe_ptr(),
            c_int(len(source)),
            OptionalPointer[UInt16, MutUntrackedOrigin](),
            c_int(0),
            Pointer(to=status),
        )
    )
    if required < 0 or (
        status != _U_ZERO_ERROR and status != _U_BUFFER_OVERFLOW_ERROR
    ):
        raise Error("Unable to measure normalized Unicode string")
    var output = List[UInt16](capacity=required)
    for _ in range(required):
        output.append(0)
    status = c_int(_U_ZERO_ERROR)
    var written = Int(
        external_call["unorm2_normalize_78", c_int](
            normalizer.value(),
            source.unsafe_ptr(),
            c_int(len(source)),
            output.unsafe_ptr(),
            c_int(required),
            Pointer(to=status),
        )
    )
    if status != _U_ZERO_ERROR or written != required:
        raise Error("Unable to normalize Unicode string")
    return JsString(code_units=output^)


def _normalizer(
    form: String,
    status: Pointer[c_int, MutAnyOrigin],
) -> OptionalPointer[NoneType, ImmUntrackedOrigin]:
    if form == "NFC":
        return external_call[
            "unorm2_getNFCInstance_78",
            OptionalPointer[NoneType, ImmUntrackedOrigin],
        ](status)
    if form == "NFD":
        return external_call[
            "unorm2_getNFDInstance_78",
            OptionalPointer[NoneType, ImmUntrackedOrigin],
        ](status)
    if form == "NFKC":
        return external_call[
            "unorm2_getNFKCInstance_78",
            OptionalPointer[NoneType, ImmUntrackedOrigin],
        ](status)
    if form == "NFKD":
        return external_call[
            "unorm2_getNFKDInstance_78",
            OptionalPointer[NoneType, ImmUntrackedOrigin],
        ](status)
    return OptionalPointer[NoneType, ImmUntrackedOrigin]()
