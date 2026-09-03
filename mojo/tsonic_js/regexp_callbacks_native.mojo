from tsonic_runtime import RaisingCallable

from .regexp import JsRegExp
from .regexp_callbacks import (
    RegExpNativeResult,
    _apply_native_callback_0,
    _apply_native_callback_1,
    _apply_native_callback_2,
    _apply_native_callback_3,
    _apply_native_callback_4,
    _apply_native_callback_5,
    _apply_native_callback_6,
    _apply_native_callback_7,
    _apply_native_callback_8,
    _prepare_native_callback,
    _prepare_regexp_callback,
    _prepare_string_callback,
)
from .string import JsString
from .value import JsValue


comptime _N0[E: AnyType] = RaisingCallable[Tuple[], String, E]
comptime _N1[E: AnyType] = RaisingCallable[Tuple[String], String, E]
comptime _N2[E: AnyType] = RaisingCallable[Tuple[String, JsValue], String, E]
comptime _N3[E: AnyType] = RaisingCallable[
    Tuple[String, JsValue, JsValue], String, E
]
comptime _N4[E: AnyType] = RaisingCallable[
    Tuple[String, JsValue, JsValue, JsValue], String, E
]
comptime _N5[E: AnyType] = RaisingCallable[
    Tuple[String, JsValue, JsValue, JsValue, JsValue], String, E
]
comptime _N6[E: AnyType] = RaisingCallable[
    Tuple[String, JsValue, JsValue, JsValue, JsValue, JsValue], String, E
]
comptime _N7[E: AnyType] = RaisingCallable[
    Tuple[String, JsValue, JsValue, JsValue, JsValue, JsValue, JsValue],
    String,
    E,
]
comptime _N8[E: AnyType] = RaisingCallable[
    Tuple[
        String,
        JsValue,
        JsValue,
        JsValue,
        JsValue,
        JsValue,
        JsValue,
        JsValue,
    ],
    String,
    E,
]


def regexp_replace_native_callback_0[E: AnyType](
    expression: JsRegExp, input: String, callback: _N0[E]
) raises E -> RegExpNativeResult[String]:
    return _apply_native_callback_0(
        _prepare_native_callback(
            _prepare_regexp_callback(expression, JsString(input), False)
        ),
        callback,
    )


def regexp_replace_native_callback_1[E: AnyType](
    expression: JsRegExp, input: String, callback: _N1[E]
) raises E -> RegExpNativeResult[String]:
    return _apply_native_callback_1(
        _prepare_native_callback(
            _prepare_regexp_callback(expression, JsString(input), False)
        ),
        callback,
    )


def regexp_replace_native_callback_2[E: AnyType](
    expression: JsRegExp, input: String, callback: _N2[E]
) raises E -> RegExpNativeResult[String]:
    return _apply_native_callback_2(
        _prepare_native_callback(
            _prepare_regexp_callback(expression, JsString(input), False)
        ),
        callback,
    )


def regexp_replace_native_callback_3[E: AnyType](
    expression: JsRegExp, input: String, callback: _N3[E]
) raises E -> RegExpNativeResult[String]:
    return _apply_native_callback_3(
        _prepare_native_callback(
            _prepare_regexp_callback(expression, JsString(input), False)
        ),
        callback,
    )


def regexp_replace_native_callback_4[E: AnyType](
    expression: JsRegExp, input: String, callback: _N4[E]
) raises E -> RegExpNativeResult[String]:
    return _apply_native_callback_4(
        _prepare_native_callback(
            _prepare_regexp_callback(expression, JsString(input), False)
        ),
        callback,
    )


def regexp_replace_native_callback_5[E: AnyType](
    expression: JsRegExp, input: String, callback: _N5[E]
) raises E -> RegExpNativeResult[String]:
    return _apply_native_callback_5(
        _prepare_native_callback(
            _prepare_regexp_callback(expression, JsString(input), False)
        ),
        callback,
    )


def regexp_replace_native_callback_6[E: AnyType](
    expression: JsRegExp, input: String, callback: _N6[E]
) raises E -> RegExpNativeResult[String]:
    return _apply_native_callback_6(
        _prepare_native_callback(
            _prepare_regexp_callback(expression, JsString(input), False)
        ),
        callback,
    )


def regexp_replace_native_callback_7[E: AnyType](
    expression: JsRegExp, input: String, callback: _N7[E]
) raises E -> RegExpNativeResult[String]:
    return _apply_native_callback_7(
        _prepare_native_callback(
            _prepare_regexp_callback(expression, JsString(input), False)
        ),
        callback,
    )


def regexp_replace_native_callback_8[E: AnyType](
    expression: JsRegExp, input: String, callback: _N8[E]
) raises E -> RegExpNativeResult[String]:
    return _apply_native_callback_8(
        _prepare_native_callback(
            _prepare_regexp_callback(expression, JsString(input), False)
        ),
        callback,
    )


def _native_string_callback_0[E: AnyType](
    value: String,
    search: JsString,
    callback: _N0[E],
    replace_all: Bool,
) raises E -> RegExpNativeResult[String]:
    return _apply_native_callback_0(
        _prepare_native_callback(
            _prepare_string_callback(
                JsString(value), search, replace_all
            )
        ),
        callback,
    )


def _native_regexp_callback_0[E: AnyType](
    value: String,
    search: JsRegExp,
    callback: _N0[E],
    replace_all: Bool,
) raises E -> RegExpNativeResult[String]:
    return _apply_native_callback_0(
        _prepare_native_callback(
            _prepare_regexp_callback(search, JsString(value), replace_all)
        ),
        callback,
    )


def string_replace_callback_0[E: AnyType](
    value: String, search: String, callback: _N0[E]
) raises E -> RegExpNativeResult[String]:
    return _native_string_callback_0(value, JsString(search), callback, False)


def string_replace_callback_0[E: AnyType](
    value: String, search: JsRegExp, callback: _N0[E]
) raises E -> RegExpNativeResult[String]:
    return _native_regexp_callback_0(value, search, callback, False)


def string_replace_all_callback_0[E: AnyType](
    value: String, search: String, callback: _N0[E]
) raises E -> RegExpNativeResult[String]:
    return _native_string_callback_0(value, JsString(search), callback, True)


def string_replace_all_callback_0[E: AnyType](
    value: String, search: JsRegExp, callback: _N0[E]
) raises E -> RegExpNativeResult[String]:
    return _native_regexp_callback_0(value, search, callback, True)


def _native_string_callback_1[E: AnyType](
    value: String, search: JsString, callback: _N1[E], replace_all: Bool
) raises E -> RegExpNativeResult[String]:
    return _apply_native_callback_1(
        _prepare_native_callback(
            _prepare_string_callback(JsString(value), search, replace_all)
        ), callback
    )


def _native_regexp_callback_1[E: AnyType](
    value: String, search: JsRegExp, callback: _N1[E], replace_all: Bool
) raises E -> RegExpNativeResult[String]:
    return _apply_native_callback_1(
        _prepare_native_callback(
            _prepare_regexp_callback(search, JsString(value), replace_all)
        ), callback
    )


def string_replace_callback_1[E: AnyType](value: String, search: String, callback: _N1[E]) raises E -> RegExpNativeResult[String]:
    return _native_string_callback_1(value, JsString(search), callback, False)


def string_replace_callback_1[E: AnyType](value: String, search: JsRegExp, callback: _N1[E]) raises E -> RegExpNativeResult[String]:
    return _native_regexp_callback_1(value, search, callback, False)


def string_replace_all_callback_1[E: AnyType](value: String, search: String, callback: _N1[E]) raises E -> RegExpNativeResult[String]:
    return _native_string_callback_1(value, JsString(search), callback, True)


def string_replace_all_callback_1[E: AnyType](value: String, search: JsRegExp, callback: _N1[E]) raises E -> RegExpNativeResult[String]:
    return _native_regexp_callback_1(value, search, callback, True)


def _native_string_callback_2[E: AnyType](value: String, search: JsString, callback: _N2[E], replace_all: Bool) raises E -> RegExpNativeResult[String]:
    return _apply_native_callback_2(_prepare_native_callback(_prepare_string_callback(JsString(value), search, replace_all)), callback)


def _native_regexp_callback_2[E: AnyType](value: String, search: JsRegExp, callback: _N2[E], replace_all: Bool) raises E -> RegExpNativeResult[String]:
    return _apply_native_callback_2(_prepare_native_callback(_prepare_regexp_callback(search, JsString(value), replace_all)), callback)


def string_replace_callback_2[E: AnyType](value: String, search: String, callback: _N2[E]) raises E -> RegExpNativeResult[String]:
    return _native_string_callback_2(value, JsString(search), callback, False)


def string_replace_callback_2[E: AnyType](value: String, search: JsRegExp, callback: _N2[E]) raises E -> RegExpNativeResult[String]:
    return _native_regexp_callback_2(value, search, callback, False)


def string_replace_all_callback_2[E: AnyType](value: String, search: String, callback: _N2[E]) raises E -> RegExpNativeResult[String]:
    return _native_string_callback_2(value, JsString(search), callback, True)


def string_replace_all_callback_2[E: AnyType](value: String, search: JsRegExp, callback: _N2[E]) raises E -> RegExpNativeResult[String]:
    return _native_regexp_callback_2(value, search, callback, True)


def _native_string_callback_3[E: AnyType](value: String, search: JsString, callback: _N3[E], replace_all: Bool) raises E -> RegExpNativeResult[String]:
    return _apply_native_callback_3(_prepare_native_callback(_prepare_string_callback(JsString(value), search, replace_all)), callback)


def _native_regexp_callback_3[E: AnyType](value: String, search: JsRegExp, callback: _N3[E], replace_all: Bool) raises E -> RegExpNativeResult[String]:
    return _apply_native_callback_3(_prepare_native_callback(_prepare_regexp_callback(search, JsString(value), replace_all)), callback)


def string_replace_callback_3[E: AnyType](value: String, search: String, callback: _N3[E]) raises E -> RegExpNativeResult[String]:
    return _native_string_callback_3(value, JsString(search), callback, False)


def string_replace_callback_3[E: AnyType](value: String, search: JsRegExp, callback: _N3[E]) raises E -> RegExpNativeResult[String]:
    return _native_regexp_callback_3(value, search, callback, False)


def string_replace_all_callback_3[E: AnyType](value: String, search: String, callback: _N3[E]) raises E -> RegExpNativeResult[String]:
    return _native_string_callback_3(value, JsString(search), callback, True)


def string_replace_all_callback_3[E: AnyType](value: String, search: JsRegExp, callback: _N3[E]) raises E -> RegExpNativeResult[String]:
    return _native_regexp_callback_3(value, search, callback, True)


def _native_string_callback_4[E: AnyType](value: String, search: JsString, callback: _N4[E], replace_all: Bool) raises E -> RegExpNativeResult[String]:
    return _apply_native_callback_4(_prepare_native_callback(_prepare_string_callback(JsString(value), search, replace_all)), callback)


def _native_regexp_callback_4[E: AnyType](value: String, search: JsRegExp, callback: _N4[E], replace_all: Bool) raises E -> RegExpNativeResult[String]:
    return _apply_native_callback_4(_prepare_native_callback(_prepare_regexp_callback(search, JsString(value), replace_all)), callback)


def string_replace_callback_4[E: AnyType](value: String, search: String, callback: _N4[E]) raises E -> RegExpNativeResult[String]:
    return _native_string_callback_4(value, JsString(search), callback, False)


def string_replace_callback_4[E: AnyType](value: String, search: JsRegExp, callback: _N4[E]) raises E -> RegExpNativeResult[String]:
    return _native_regexp_callback_4(value, search, callback, False)


def string_replace_all_callback_4[E: AnyType](value: String, search: String, callback: _N4[E]) raises E -> RegExpNativeResult[String]:
    return _native_string_callback_4(value, JsString(search), callback, True)


def string_replace_all_callback_4[E: AnyType](value: String, search: JsRegExp, callback: _N4[E]) raises E -> RegExpNativeResult[String]:
    return _native_regexp_callback_4(value, search, callback, True)


def _native_string_callback_5[E: AnyType](value: String, search: JsString, callback: _N5[E], replace_all: Bool) raises E -> RegExpNativeResult[String]:
    return _apply_native_callback_5(_prepare_native_callback(_prepare_string_callback(JsString(value), search, replace_all)), callback)


def _native_regexp_callback_5[E: AnyType](value: String, search: JsRegExp, callback: _N5[E], replace_all: Bool) raises E -> RegExpNativeResult[String]:
    return _apply_native_callback_5(_prepare_native_callback(_prepare_regexp_callback(search, JsString(value), replace_all)), callback)


def string_replace_callback_5[E: AnyType](value: String, search: String, callback: _N5[E]) raises E -> RegExpNativeResult[String]:
    return _native_string_callback_5(value, JsString(search), callback, False)


def string_replace_callback_5[E: AnyType](value: String, search: JsRegExp, callback: _N5[E]) raises E -> RegExpNativeResult[String]:
    return _native_regexp_callback_5(value, search, callback, False)


def string_replace_all_callback_5[E: AnyType](value: String, search: String, callback: _N5[E]) raises E -> RegExpNativeResult[String]:
    return _native_string_callback_5(value, JsString(search), callback, True)


def string_replace_all_callback_5[E: AnyType](value: String, search: JsRegExp, callback: _N5[E]) raises E -> RegExpNativeResult[String]:
    return _native_regexp_callback_5(value, search, callback, True)


def _native_string_callback_6[E: AnyType](value: String, search: JsString, callback: _N6[E], replace_all: Bool) raises E -> RegExpNativeResult[String]:
    return _apply_native_callback_6(_prepare_native_callback(_prepare_string_callback(JsString(value), search, replace_all)), callback)


def _native_regexp_callback_6[E: AnyType](value: String, search: JsRegExp, callback: _N6[E], replace_all: Bool) raises E -> RegExpNativeResult[String]:
    return _apply_native_callback_6(_prepare_native_callback(_prepare_regexp_callback(search, JsString(value), replace_all)), callback)


def string_replace_callback_6[E: AnyType](value: String, search: String, callback: _N6[E]) raises E -> RegExpNativeResult[String]:
    return _native_string_callback_6(value, JsString(search), callback, False)


def string_replace_callback_6[E: AnyType](value: String, search: JsRegExp, callback: _N6[E]) raises E -> RegExpNativeResult[String]:
    return _native_regexp_callback_6(value, search, callback, False)


def string_replace_all_callback_6[E: AnyType](value: String, search: String, callback: _N6[E]) raises E -> RegExpNativeResult[String]:
    return _native_string_callback_6(value, JsString(search), callback, True)


def string_replace_all_callback_6[E: AnyType](value: String, search: JsRegExp, callback: _N6[E]) raises E -> RegExpNativeResult[String]:
    return _native_regexp_callback_6(value, search, callback, True)


def _native_string_callback_7[E: AnyType](value: String, search: JsString, callback: _N7[E], replace_all: Bool) raises E -> RegExpNativeResult[String]:
    return _apply_native_callback_7(_prepare_native_callback(_prepare_string_callback(JsString(value), search, replace_all)), callback)


def _native_regexp_callback_7[E: AnyType](value: String, search: JsRegExp, callback: _N7[E], replace_all: Bool) raises E -> RegExpNativeResult[String]:
    return _apply_native_callback_7(_prepare_native_callback(_prepare_regexp_callback(search, JsString(value), replace_all)), callback)


def string_replace_callback_7[E: AnyType](value: String, search: String, callback: _N7[E]) raises E -> RegExpNativeResult[String]:
    return _native_string_callback_7(value, JsString(search), callback, False)


def string_replace_callback_7[E: AnyType](value: String, search: JsRegExp, callback: _N7[E]) raises E -> RegExpNativeResult[String]:
    return _native_regexp_callback_7(value, search, callback, False)


def string_replace_all_callback_7[E: AnyType](value: String, search: String, callback: _N7[E]) raises E -> RegExpNativeResult[String]:
    return _native_string_callback_7(value, JsString(search), callback, True)


def string_replace_all_callback_7[E: AnyType](value: String, search: JsRegExp, callback: _N7[E]) raises E -> RegExpNativeResult[String]:
    return _native_regexp_callback_7(value, search, callback, True)


def _native_string_callback_8[E: AnyType](value: String, search: JsString, callback: _N8[E], replace_all: Bool) raises E -> RegExpNativeResult[String]:
    return _apply_native_callback_8(_prepare_native_callback(_prepare_string_callback(JsString(value), search, replace_all)), callback)


def _native_regexp_callback_8[E: AnyType](value: String, search: JsRegExp, callback: _N8[E], replace_all: Bool) raises E -> RegExpNativeResult[String]:
    return _apply_native_callback_8(_prepare_native_callback(_prepare_regexp_callback(search, JsString(value), replace_all)), callback)


def string_replace_callback_8[E: AnyType](value: String, search: String, callback: _N8[E]) raises E -> RegExpNativeResult[String]:
    return _native_string_callback_8(value, JsString(search), callback, False)


def string_replace_callback_8[E: AnyType](value: String, search: JsRegExp, callback: _N8[E]) raises E -> RegExpNativeResult[String]:
    return _native_regexp_callback_8(value, search, callback, False)


def string_replace_all_callback_8[E: AnyType](value: String, search: String, callback: _N8[E]) raises E -> RegExpNativeResult[String]:
    return _native_string_callback_8(value, JsString(search), callback, True)


def string_replace_all_callback_8[E: AnyType](value: String, search: JsRegExp, callback: _N8[E]) raises E -> RegExpNativeResult[String]:
    return _native_regexp_callback_8(value, search, callback, True)
