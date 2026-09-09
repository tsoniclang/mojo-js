from ..core import JsRegExp
from .records import RegExpNativeResult, _prepare_regexp_callback
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


def regexp_replace_exact_callback_0[
    E: AnyType
](
    expression: JsRegExp, input: JsString, callback: _E0[E]
) raises E -> RegExpNativeResult[JsString]:
    return _apply_exact_callback_0(
        _prepare_regexp_callback(expression, input, False), callback
    )


def regexp_replace_exact_callback_1[
    E: AnyType
](
    expression: JsRegExp, input: JsString, callback: _E1[E]
) raises E -> RegExpNativeResult[JsString]:
    return _apply_exact_callback_1(
        _prepare_regexp_callback(expression, input, False), callback
    )


def regexp_replace_exact_callback_2[
    E: AnyType
](
    expression: JsRegExp, input: JsString, callback: _E2[E]
) raises E -> RegExpNativeResult[JsString]:
    return _apply_exact_callback_2(
        _prepare_regexp_callback(expression, input, False), callback
    )


def regexp_replace_exact_callback_3[
    E: AnyType
](
    expression: JsRegExp, input: JsString, callback: _E3[E]
) raises E -> RegExpNativeResult[JsString]:
    return _apply_exact_callback_3(
        _prepare_regexp_callback(expression, input, False), callback
    )


def regexp_replace_exact_callback_4[
    E: AnyType
](
    expression: JsRegExp, input: JsString, callback: _E4[E]
) raises E -> RegExpNativeResult[JsString]:
    return _apply_exact_callback_4(
        _prepare_regexp_callback(expression, input, False), callback
    )


def regexp_replace_exact_callback_5[
    E: AnyType
](
    expression: JsRegExp, input: JsString, callback: _E5[E]
) raises E -> RegExpNativeResult[JsString]:
    return _apply_exact_callback_5(
        _prepare_regexp_callback(expression, input, False), callback
    )


def regexp_replace_exact_callback_6[
    E: AnyType
](
    expression: JsRegExp, input: JsString, callback: _E6[E]
) raises E -> RegExpNativeResult[JsString]:
    return _apply_exact_callback_6(
        _prepare_regexp_callback(expression, input, False), callback
    )


def regexp_replace_exact_callback_7[
    E: AnyType
](
    expression: JsRegExp, input: JsString, callback: _E7[E]
) raises E -> RegExpNativeResult[JsString]:
    return _apply_exact_callback_7(
        _prepare_regexp_callback(expression, input, False), callback
    )


def regexp_replace_exact_callback_8[
    E: AnyType
](
    expression: JsRegExp, input: JsString, callback: _E8[E]
) raises E -> RegExpNativeResult[JsString]:
    return _apply_exact_callback_8(
        _prepare_regexp_callback(expression, input, False), callback
    )
