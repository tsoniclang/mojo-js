from ..core import JsRegExp
from .records import (
    RegExpNativeResult,
    _prepare_native_callback,
    _prepare_regexp_callback,
)
from .apply_native import (
    _apply_native_callback_0,
    _apply_native_callback_1,
    _apply_native_callback_2,
    _apply_native_callback_3,
    _apply_native_callback_4,
    _apply_native_callback_5,
    _apply_native_callback_6,
    _apply_native_callback_7,
    _apply_native_callback_8,
)
from ...string import JsString
from .native_signatures import (
    _N0,
    _N1,
    _N2,
    _N3,
    _N4,
    _N5,
    _N6,
    _N7,
    _N8,
)


def regexp_replace_native_callback_0[
    E: AnyType
](
    expression: JsRegExp, input: String, callback: _N0[E]
) raises E -> RegExpNativeResult[String]:
    return _apply_native_callback_0(
        _prepare_native_callback(
            _prepare_regexp_callback(expression, JsString(input), False)
        ),
        callback,
    )


def regexp_replace_native_callback_1[
    E: AnyType
](
    expression: JsRegExp, input: String, callback: _N1[E]
) raises E -> RegExpNativeResult[String]:
    return _apply_native_callback_1(
        _prepare_native_callback(
            _prepare_regexp_callback(expression, JsString(input), False)
        ),
        callback,
    )


def regexp_replace_native_callback_2[
    E: AnyType
](
    expression: JsRegExp, input: String, callback: _N2[E]
) raises E -> RegExpNativeResult[String]:
    return _apply_native_callback_2(
        _prepare_native_callback(
            _prepare_regexp_callback(expression, JsString(input), False)
        ),
        callback,
    )


def regexp_replace_native_callback_3[
    E: AnyType
](
    expression: JsRegExp, input: String, callback: _N3[E]
) raises E -> RegExpNativeResult[String]:
    return _apply_native_callback_3(
        _prepare_native_callback(
            _prepare_regexp_callback(expression, JsString(input), False)
        ),
        callback,
    )


def regexp_replace_native_callback_4[
    E: AnyType
](
    expression: JsRegExp, input: String, callback: _N4[E]
) raises E -> RegExpNativeResult[String]:
    return _apply_native_callback_4(
        _prepare_native_callback(
            _prepare_regexp_callback(expression, JsString(input), False)
        ),
        callback,
    )


def regexp_replace_native_callback_5[
    E: AnyType
](
    expression: JsRegExp, input: String, callback: _N5[E]
) raises E -> RegExpNativeResult[String]:
    return _apply_native_callback_5(
        _prepare_native_callback(
            _prepare_regexp_callback(expression, JsString(input), False)
        ),
        callback,
    )


def regexp_replace_native_callback_6[
    E: AnyType
](
    expression: JsRegExp, input: String, callback: _N6[E]
) raises E -> RegExpNativeResult[String]:
    return _apply_native_callback_6(
        _prepare_native_callback(
            _prepare_regexp_callback(expression, JsString(input), False)
        ),
        callback,
    )


def regexp_replace_native_callback_7[
    E: AnyType
](
    expression: JsRegExp, input: String, callback: _N7[E]
) raises E -> RegExpNativeResult[String]:
    return _apply_native_callback_7(
        _prepare_native_callback(
            _prepare_regexp_callback(expression, JsString(input), False)
        ),
        callback,
    )


def regexp_replace_native_callback_8[
    E: AnyType
](
    expression: JsRegExp, input: String, callback: _N8[E]
) raises E -> RegExpNativeResult[String]:
    return _apply_native_callback_8(
        _prepare_native_callback(
            _prepare_regexp_callback(expression, JsString(input), False)
        ),
        callback,
    )
