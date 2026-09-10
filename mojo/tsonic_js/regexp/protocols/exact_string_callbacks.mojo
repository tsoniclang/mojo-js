from .records import (
    RegExpNativeResult,
    _prepare_regexp_callback,
    _prepare_string_callback,
)
from .apply_exact import (
    _apply_exact_callback_0,
    _apply_exact_callback_1,
    _apply_exact_callback_2,
    _apply_exact_callback_3,
    _apply_exact_callback_4,
    _apply_exact_callback_5,
    _apply_exact_callback_6,
    _apply_exact_callback_7,
    _apply_exact_callback_8,
)
from ...string import JsString
from .exact_signatures import (
    _E0,
    _E1,
    _E2,
    _E3,
    _E4,
    _E5,
    _E6,
    _E7,
    _E8,
)
from ..core import JsRegExp


def _exact_string_callback_0[
    E: AnyType
](
    value: JsString, search: JsString, callback: _E0[E], replace_all: Bool
) raises E -> RegExpNativeResult[JsString]:
    return _apply_exact_callback_0(
        _prepare_string_callback(value, search, replace_all), callback
    )


def _exact_regexp_callback_0[
    E: AnyType
](
    value: JsString, search: JsRegExp, callback: _E0[E], replace_all: Bool
) raises E -> RegExpNativeResult[JsString]:
    return _apply_exact_callback_0(
        _prepare_regexp_callback(search, value, replace_all), callback
    )


def js_string_replace_callback_0[
    E: AnyType
](
    value: JsString, search: JsString, callback: _E0[E]
) raises E -> RegExpNativeResult[JsString]:
    return _exact_string_callback_0(value, search, callback, False)


def js_string_replace_callback_0[
    E: AnyType
](
    value: JsString, search: JsRegExp, callback: _E0[E]
) raises E -> RegExpNativeResult[JsString]:
    return _exact_regexp_callback_0(value, search, callback, False)


def js_string_replace_all_callback_0[
    E: AnyType
](
    value: JsString, search: JsString, callback: _E0[E]
) raises E -> RegExpNativeResult[JsString]:
    return _exact_string_callback_0(value, search, callback, True)


def js_string_replace_all_callback_0[
    E: AnyType
](
    value: JsString, search: JsRegExp, callback: _E0[E]
) raises E -> RegExpNativeResult[JsString]:
    return _exact_regexp_callback_0(value, search, callback, True)


def _exact_string_callback_1[
    E: AnyType
](
    value: JsString, search: JsString, callback: _E1[E], replace_all: Bool
) raises E -> RegExpNativeResult[JsString]:
    return _apply_exact_callback_1(
        _prepare_string_callback(value, search, replace_all), callback
    )


def _exact_regexp_callback_1[
    E: AnyType
](
    value: JsString, search: JsRegExp, callback: _E1[E], replace_all: Bool
) raises E -> RegExpNativeResult[JsString]:
    return _apply_exact_callback_1(
        _prepare_regexp_callback(search, value, replace_all), callback
    )


def js_string_replace_callback_1[
    E: AnyType
](
    value: JsString, search: JsString, callback: _E1[E]
) raises E -> RegExpNativeResult[JsString]:
    return _exact_string_callback_1(value, search, callback, False)


def js_string_replace_callback_1[
    E: AnyType
](
    value: JsString, search: JsRegExp, callback: _E1[E]
) raises E -> RegExpNativeResult[JsString]:
    return _exact_regexp_callback_1(value, search, callback, False)


def js_string_replace_all_callback_1[
    E: AnyType
](
    value: JsString, search: JsString, callback: _E1[E]
) raises E -> RegExpNativeResult[JsString]:
    return _exact_string_callback_1(value, search, callback, True)


def js_string_replace_all_callback_1[
    E: AnyType
](
    value: JsString, search: JsRegExp, callback: _E1[E]
) raises E -> RegExpNativeResult[JsString]:
    return _exact_regexp_callback_1(value, search, callback, True)


def _exact_string_callback_2[
    E: AnyType
](
    value: JsString, search: JsString, callback: _E2[E], replace_all: Bool
) raises E -> RegExpNativeResult[JsString]:
    return _apply_exact_callback_2(
        _prepare_string_callback(value, search, replace_all), callback
    )


def _exact_regexp_callback_2[
    E: AnyType
](
    value: JsString, search: JsRegExp, callback: _E2[E], replace_all: Bool
) raises E -> RegExpNativeResult[JsString]:
    return _apply_exact_callback_2(
        _prepare_regexp_callback(search, value, replace_all), callback
    )


def js_string_replace_callback_2[
    E: AnyType
](
    value: JsString, search: JsString, callback: _E2[E]
) raises E -> RegExpNativeResult[JsString]:
    return _exact_string_callback_2(value, search, callback, False)


def js_string_replace_callback_2[
    E: AnyType
](
    value: JsString, search: JsRegExp, callback: _E2[E]
) raises E -> RegExpNativeResult[JsString]:
    return _exact_regexp_callback_2(value, search, callback, False)


def js_string_replace_all_callback_2[
    E: AnyType
](
    value: JsString, search: JsString, callback: _E2[E]
) raises E -> RegExpNativeResult[JsString]:
    return _exact_string_callback_2(value, search, callback, True)


def js_string_replace_all_callback_2[
    E: AnyType
](
    value: JsString, search: JsRegExp, callback: _E2[E]
) raises E -> RegExpNativeResult[JsString]:
    return _exact_regexp_callback_2(value, search, callback, True)


def _exact_string_callback_3[
    E: AnyType
](
    value: JsString, search: JsString, callback: _E3[E], replace_all: Bool
) raises E -> RegExpNativeResult[JsString]:
    return _apply_exact_callback_3(
        _prepare_string_callback(value, search, replace_all), callback
    )


def _exact_regexp_callback_3[
    E: AnyType
](
    value: JsString, search: JsRegExp, callback: _E3[E], replace_all: Bool
) raises E -> RegExpNativeResult[JsString]:
    return _apply_exact_callback_3(
        _prepare_regexp_callback(search, value, replace_all), callback
    )


def js_string_replace_callback_3[
    E: AnyType
](
    value: JsString, search: JsString, callback: _E3[E]
) raises E -> RegExpNativeResult[JsString]:
    return _exact_string_callback_3(value, search, callback, False)


def js_string_replace_callback_3[
    E: AnyType
](
    value: JsString, search: JsRegExp, callback: _E3[E]
) raises E -> RegExpNativeResult[JsString]:
    return _exact_regexp_callback_3(value, search, callback, False)


def js_string_replace_all_callback_3[
    E: AnyType
](
    value: JsString, search: JsString, callback: _E3[E]
) raises E -> RegExpNativeResult[JsString]:
    return _exact_string_callback_3(value, search, callback, True)


def js_string_replace_all_callback_3[
    E: AnyType
](
    value: JsString, search: JsRegExp, callback: _E3[E]
) raises E -> RegExpNativeResult[JsString]:
    return _exact_regexp_callback_3(value, search, callback, True)


def _exact_string_callback_4[
    E: AnyType
](
    value: JsString, search: JsString, callback: _E4[E], replace_all: Bool
) raises E -> RegExpNativeResult[JsString]:
    return _apply_exact_callback_4(
        _prepare_string_callback(value, search, replace_all), callback
    )


def _exact_regexp_callback_4[
    E: AnyType
](
    value: JsString, search: JsRegExp, callback: _E4[E], replace_all: Bool
) raises E -> RegExpNativeResult[JsString]:
    return _apply_exact_callback_4(
        _prepare_regexp_callback(search, value, replace_all), callback
    )


def js_string_replace_callback_4[
    E: AnyType
](
    value: JsString, search: JsString, callback: _E4[E]
) raises E -> RegExpNativeResult[JsString]:
    return _exact_string_callback_4(value, search, callback, False)


def js_string_replace_callback_4[
    E: AnyType
](
    value: JsString, search: JsRegExp, callback: _E4[E]
) raises E -> RegExpNativeResult[JsString]:
    return _exact_regexp_callback_4(value, search, callback, False)


def js_string_replace_all_callback_4[
    E: AnyType
](
    value: JsString, search: JsString, callback: _E4[E]
) raises E -> RegExpNativeResult[JsString]:
    return _exact_string_callback_4(value, search, callback, True)


def js_string_replace_all_callback_4[
    E: AnyType
](
    value: JsString, search: JsRegExp, callback: _E4[E]
) raises E -> RegExpNativeResult[JsString]:
    return _exact_regexp_callback_4(value, search, callback, True)


def _exact_string_callback_5[
    E: AnyType
](
    value: JsString, search: JsString, callback: _E5[E], replace_all: Bool
) raises E -> RegExpNativeResult[JsString]:
    return _apply_exact_callback_5(
        _prepare_string_callback(value, search, replace_all), callback
    )


def _exact_regexp_callback_5[
    E: AnyType
](
    value: JsString, search: JsRegExp, callback: _E5[E], replace_all: Bool
) raises E -> RegExpNativeResult[JsString]:
    return _apply_exact_callback_5(
        _prepare_regexp_callback(search, value, replace_all), callback
    )


def js_string_replace_callback_5[
    E: AnyType
](
    value: JsString, search: JsString, callback: _E5[E]
) raises E -> RegExpNativeResult[JsString]:
    return _exact_string_callback_5(value, search, callback, False)


def js_string_replace_callback_5[
    E: AnyType
](
    value: JsString, search: JsRegExp, callback: _E5[E]
) raises E -> RegExpNativeResult[JsString]:
    return _exact_regexp_callback_5(value, search, callback, False)


def js_string_replace_all_callback_5[
    E: AnyType
](
    value: JsString, search: JsString, callback: _E5[E]
) raises E -> RegExpNativeResult[JsString]:
    return _exact_string_callback_5(value, search, callback, True)


def js_string_replace_all_callback_5[
    E: AnyType
](
    value: JsString, search: JsRegExp, callback: _E5[E]
) raises E -> RegExpNativeResult[JsString]:
    return _exact_regexp_callback_5(value, search, callback, True)


def _exact_string_callback_6[
    E: AnyType
](
    value: JsString, search: JsString, callback: _E6[E], replace_all: Bool
) raises E -> RegExpNativeResult[JsString]:
    return _apply_exact_callback_6(
        _prepare_string_callback(value, search, replace_all), callback
    )


def _exact_regexp_callback_6[
    E: AnyType
](
    value: JsString, search: JsRegExp, callback: _E6[E], replace_all: Bool
) raises E -> RegExpNativeResult[JsString]:
    return _apply_exact_callback_6(
        _prepare_regexp_callback(search, value, replace_all), callback
    )


def js_string_replace_callback_6[
    E: AnyType
](
    value: JsString, search: JsString, callback: _E6[E]
) raises E -> RegExpNativeResult[JsString]:
    return _exact_string_callback_6(value, search, callback, False)


def js_string_replace_callback_6[
    E: AnyType
](
    value: JsString, search: JsRegExp, callback: _E6[E]
) raises E -> RegExpNativeResult[JsString]:
    return _exact_regexp_callback_6(value, search, callback, False)


def js_string_replace_all_callback_6[
    E: AnyType
](
    value: JsString, search: JsString, callback: _E6[E]
) raises E -> RegExpNativeResult[JsString]:
    return _exact_string_callback_6(value, search, callback, True)


def js_string_replace_all_callback_6[
    E: AnyType
](
    value: JsString, search: JsRegExp, callback: _E6[E]
) raises E -> RegExpNativeResult[JsString]:
    return _exact_regexp_callback_6(value, search, callback, True)


def _exact_string_callback_7[
    E: AnyType
](
    value: JsString, search: JsString, callback: _E7[E], replace_all: Bool
) raises E -> RegExpNativeResult[JsString]:
    return _apply_exact_callback_7(
        _prepare_string_callback(value, search, replace_all), callback
    )


def _exact_regexp_callback_7[
    E: AnyType
](
    value: JsString, search: JsRegExp, callback: _E7[E], replace_all: Bool
) raises E -> RegExpNativeResult[JsString]:
    return _apply_exact_callback_7(
        _prepare_regexp_callback(search, value, replace_all), callback
    )


def js_string_replace_callback_7[
    E: AnyType
](
    value: JsString, search: JsString, callback: _E7[E]
) raises E -> RegExpNativeResult[JsString]:
    return _exact_string_callback_7(value, search, callback, False)


def js_string_replace_callback_7[
    E: AnyType
](
    value: JsString, search: JsRegExp, callback: _E7[E]
) raises E -> RegExpNativeResult[JsString]:
    return _exact_regexp_callback_7(value, search, callback, False)


def js_string_replace_all_callback_7[
    E: AnyType
](
    value: JsString, search: JsString, callback: _E7[E]
) raises E -> RegExpNativeResult[JsString]:
    return _exact_string_callback_7(value, search, callback, True)


def js_string_replace_all_callback_7[
    E: AnyType
](
    value: JsString, search: JsRegExp, callback: _E7[E]
) raises E -> RegExpNativeResult[JsString]:
    return _exact_regexp_callback_7(value, search, callback, True)


def _exact_string_callback_8[
    E: AnyType
](
    value: JsString, search: JsString, callback: _E8[E], replace_all: Bool
) raises E -> RegExpNativeResult[JsString]:
    return _apply_exact_callback_8(
        _prepare_string_callback(value, search, replace_all), callback
    )


def _exact_regexp_callback_8[
    E: AnyType
](
    value: JsString, search: JsRegExp, callback: _E8[E], replace_all: Bool
) raises E -> RegExpNativeResult[JsString]:
    return _apply_exact_callback_8(
        _prepare_regexp_callback(search, value, replace_all), callback
    )


def js_string_replace_callback_8[
    E: AnyType
](
    value: JsString, search: JsString, callback: _E8[E]
) raises E -> RegExpNativeResult[JsString]:
    return _exact_string_callback_8(value, search, callback, False)


def js_string_replace_callback_8[
    E: AnyType
](
    value: JsString, search: JsRegExp, callback: _E8[E]
) raises E -> RegExpNativeResult[JsString]:
    return _exact_regexp_callback_8(value, search, callback, False)


def js_string_replace_all_callback_8[
    E: AnyType
](
    value: JsString, search: JsString, callback: _E8[E]
) raises E -> RegExpNativeResult[JsString]:
    return _exact_string_callback_8(value, search, callback, True)


def js_string_replace_all_callback_8[
    E: AnyType
](
    value: JsString, search: JsRegExp, callback: _E8[E]
) raises E -> RegExpNativeResult[JsString]:
    return _exact_regexp_callback_8(value, search, callback, True)
