from std.collections import List
from tsonic_runtime import RaisingCallable
from ...string import JsString
from .records import (
    RegExpNativeResult,
    _RegExpCallbackBatch,
    _complete_exact_callback,
)
from ...value import JsValue


def _apply_exact_callback_0[
    CallbackError: AnyType
](
    var prepared: RegExpNativeResult[_RegExpCallbackBatch],
    callback: RaisingCallable[Tuple[], JsString, CallbackError],
) raises CallbackError -> RegExpNativeResult[JsString]:
    if not prepared.is_success():
        return RegExpNativeResult[JsString](prepared.take_error())
    var batch = prepared.take_value()
    var replacements = List[JsString]()
    for _ in batch.records._elements[]:
        replacements.append(callback.call(()))
    return _complete_exact_callback(batch, replacements^)


def _apply_exact_callback_1[
    CallbackError: AnyType
](
    var prepared: RegExpNativeResult[_RegExpCallbackBatch],
    callback: RaisingCallable[Tuple[JsString], JsString, CallbackError],
) raises CallbackError -> RegExpNativeResult[JsString]:
    if not prepared.is_success():
        return RegExpNativeResult[JsString](prepared.take_error())
    var batch = prepared.take_value()
    var replacements = List[JsString]()
    for stored_record in batch.records._elements[]:
        var record = stored_record.value()
        replacements.append(callback.call((record.matched(),)))
    return _complete_exact_callback(batch, replacements^)


def _apply_exact_callback_2[
    CallbackError: AnyType
](
    var prepared: RegExpNativeResult[_RegExpCallbackBatch],
    callback: RaisingCallable[
        Tuple[JsString, JsValue], JsString, CallbackError
    ],
) raises CallbackError -> RegExpNativeResult[JsString]:
    if not prepared.is_success():
        return RegExpNativeResult[JsString](prepared.take_error())
    var batch = prepared.take_value()
    var replacements = List[JsString]()
    for stored_record in batch.records._elements[]:
        var record = stored_record.value()
        replacements.append(
            callback.call((record.matched(), record.argument(1)))
        )
    return _complete_exact_callback(batch, replacements^)


def _apply_exact_callback_3[
    CallbackError: AnyType
](
    var prepared: RegExpNativeResult[_RegExpCallbackBatch],
    callback: RaisingCallable[
        Tuple[JsString, JsValue, JsValue], JsString, CallbackError
    ],
) raises CallbackError -> RegExpNativeResult[JsString]:
    if not prepared.is_success():
        return RegExpNativeResult[JsString](prepared.take_error())
    var batch = prepared.take_value()
    var replacements = List[JsString]()
    for stored_record in batch.records._elements[]:
        var record = stored_record.value()
        replacements.append(
            callback.call(
                (record.matched(), record.argument(1), record.argument(2))
            )
        )
    return _complete_exact_callback(batch, replacements^)


def _apply_exact_callback_4[
    CallbackError: AnyType
](
    var prepared: RegExpNativeResult[_RegExpCallbackBatch],
    callback: RaisingCallable[
        Tuple[JsString, JsValue, JsValue, JsValue], JsString, CallbackError
    ],
) raises CallbackError -> RegExpNativeResult[JsString]:
    if not prepared.is_success():
        return RegExpNativeResult[JsString](prepared.take_error())
    var batch = prepared.take_value()
    var replacements = List[JsString]()
    for stored_record in batch.records._elements[]:
        var record = stored_record.value()
        replacements.append(
            callback.call(
                (
                    record.matched(),
                    record.argument(1),
                    record.argument(2),
                    record.argument(3),
                )
            )
        )
    return _complete_exact_callback(batch, replacements^)


def _apply_exact_callback_5[
    CallbackError: AnyType
](
    var prepared: RegExpNativeResult[_RegExpCallbackBatch],
    callback: RaisingCallable[
        Tuple[JsString, JsValue, JsValue, JsValue, JsValue],
        JsString,
        CallbackError,
    ],
) raises CallbackError -> RegExpNativeResult[JsString]:
    if not prepared.is_success():
        return RegExpNativeResult[JsString](prepared.take_error())
    var batch = prepared.take_value()
    var replacements = List[JsString]()
    for stored_record in batch.records._elements[]:
        var record = stored_record.value()
        replacements.append(
            callback.call(
                (
                    record.matched(),
                    record.argument(1),
                    record.argument(2),
                    record.argument(3),
                    record.argument(4),
                )
            )
        )
    return _complete_exact_callback(batch, replacements^)


def _apply_exact_callback_6[
    CallbackError: AnyType
](
    var prepared: RegExpNativeResult[_RegExpCallbackBatch],
    callback: RaisingCallable[
        Tuple[JsString, JsValue, JsValue, JsValue, JsValue, JsValue],
        JsString,
        CallbackError,
    ],
) raises CallbackError -> RegExpNativeResult[JsString]:
    if not prepared.is_success():
        return RegExpNativeResult[JsString](prepared.take_error())
    var batch = prepared.take_value()
    var replacements = List[JsString]()
    for stored_record in batch.records._elements[]:
        var record = stored_record.value()
        replacements.append(
            callback.call(
                (
                    record.matched(),
                    record.argument(1),
                    record.argument(2),
                    record.argument(3),
                    record.argument(4),
                    record.argument(5),
                )
            )
        )
    return _complete_exact_callback(batch, replacements^)


def _apply_exact_callback_7[
    CallbackError: AnyType
](
    var prepared: RegExpNativeResult[_RegExpCallbackBatch],
    callback: RaisingCallable[
        Tuple[JsString, JsValue, JsValue, JsValue, JsValue, JsValue, JsValue],
        JsString,
        CallbackError,
    ],
) raises CallbackError -> RegExpNativeResult[JsString]:
    if not prepared.is_success():
        return RegExpNativeResult[JsString](prepared.take_error())
    var batch = prepared.take_value()
    var replacements = List[JsString]()
    for stored_record in batch.records._elements[]:
        var record = stored_record.value()
        replacements.append(
            callback.call(
                (
                    record.matched(),
                    record.argument(1),
                    record.argument(2),
                    record.argument(3),
                    record.argument(4),
                    record.argument(5),
                    record.argument(6),
                )
            )
        )
    return _complete_exact_callback(batch, replacements^)


def _apply_exact_callback_8[
    CallbackError: AnyType
](
    var prepared: RegExpNativeResult[_RegExpCallbackBatch],
    callback: RaisingCallable[
        Tuple[
            JsString,
            JsValue,
            JsValue,
            JsValue,
            JsValue,
            JsValue,
            JsValue,
            JsValue,
        ],
        JsString,
        CallbackError,
    ],
) raises CallbackError -> RegExpNativeResult[JsString]:
    if not prepared.is_success():
        return RegExpNativeResult[JsString](prepared.take_error())
    var batch = prepared.take_value()
    var replacements = List[JsString]()
    for stored_record in batch.records._elements[]:
        var record = stored_record.value()
        replacements.append(
            callback.call(
                (
                    record.matched(),
                    record.argument(1),
                    record.argument(2),
                    record.argument(3),
                    record.argument(4),
                    record.argument(5),
                    record.argument(6),
                    record.argument(7),
                )
            )
        )
    return _complete_exact_callback(batch, replacements^)
