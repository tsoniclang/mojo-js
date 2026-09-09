from std.collections import List
from std.ffi import c_int, c_size_t, external_call
from ..value import JsValue
from .native import IntlResult


def canonical_locale(value: String) raises -> String:
    var text = String(value)
    var result = IntlResult(external_call[
        "tsonic_js_intl_locale", OptionalPointer[NoneType, MutUntrackedOrigin],
    ](text.as_c_string_slice().ptr(), c_size_t(len(text.as_bytes()))))
    return result.text()


def default_locale() raises -> String:
    var result = IntlResult(external_call[
        "tsonic_js_intl_default_locale", OptionalPointer[NoneType, MutUntrackedOrigin],
    ]())
    return result.text()


def requested_locales(value: JsValue) raises -> List[String]:
    var result = List[String]()
    if value.is_undefined():
        return result^
    if value.is_string():
        result.append(canonical_locale(value.string_value().to_native_strict()))
        return result^
    if not value.is_array():
        raise Error("Locales must be a language tag or a closed array of language tags")
    var length = value.array_length()
    if length > 4096:
        raise Error("Requested locales exceed the finite runtime limit")
    for index in range(length):
        var item = value.array_at(index)
        if not item.is_string():
            raise Error("Each locale must be a language-tag string")
        var locale = canonical_locale(item.string_value().to_native_strict())
        if locale not in result:
            result.append(locale^)
    return result^


def case_locale(value: JsValue) raises -> String:
    var requested = requested_locales(value)
    return requested[0] if len(requested) != 0 else default_locale()


def collation_locale(requested: List[String]) raises -> String:
    for locale in requested:
        var candidate = String(locale)
        if external_call["tsonic_js_intl_collation_available", c_int](candidate.as_c_string_slice().ptr()):
            return candidate^
    return default_locale()
