from std.collections import List
from tsonic_runtime import RaisingCallable
from .records import (
    RegExpNativeResult,
    _NativeRegExpCallbackBatch,
    _complete_native_callback,
)
from ...value import JsValue


def _apply_native_callback_0[
    CallbackError: AnyType
](
    var prepared: RegExpNativeResult[_NativeRegExpCallbackBatch],
    callback: RaisingCallable[Tuple[], String, CallbackError],
) raises CallbackError -> RegExpNativeResult[String]:
    if not prepared.is_success():
        return RegExpNativeResult[String](prepared.take_error())
    var batch = prepared.take_value()
    var replacements = List[String]()
    for _ in batch.exact.records._elements[]:
        replacements.append(callback.call(()))
    return _complete_native_callback(batch, replacements^)


def _apply_native_callback_1[
    CallbackError: AnyType
](
    var prepared: RegExpNativeResult[_NativeRegExpCallbackBatch],
    callback: RaisingCallable[Tuple[String], String, CallbackError],
) raises CallbackError -> RegExpNativeResult[String]:
    if not prepared.is_success():
        return RegExpNativeResult[String](prepared.take_error())
    var batch = prepared.take_value()
    var replacements = List[String]()
    for index in range(len(batch.exact.records)):
        replacements.append(
            callback.call((batch.matches.get_index(Float64(index)).value(),))
        )
    return _complete_native_callback(batch, replacements^)


def _apply_native_callback_2[
    CallbackError: AnyType
](
    var prepared: RegExpNativeResult[_NativeRegExpCallbackBatch],
    callback: RaisingCallable[Tuple[String, JsValue], String, CallbackError],
) raises CallbackError -> RegExpNativeResult[String]:
    if not prepared.is_success():
        return RegExpNativeResult[String](prepared.take_error())
    var batch = prepared.take_value()
    var replacements = List[String]()
    for index in range(len(batch.exact.records)):
        var record = batch.exact.records.get_index(Float64(index)).value()
        replacements.append(
            callback.call(
                (
                    batch.matches.get_index(Float64(index)).value(),
                    record.argument(1),
                )
            )
        )
    return _complete_native_callback(batch, replacements^)


def _apply_native_callback_3[
    CallbackError: AnyType
](
    var prepared: RegExpNativeResult[_NativeRegExpCallbackBatch],
    callback: RaisingCallable[
        Tuple[String, JsValue, JsValue], String, CallbackError
    ],
) raises CallbackError -> RegExpNativeResult[String]:
    if not prepared.is_success():
        return RegExpNativeResult[String](prepared.take_error())
    var batch = prepared.take_value()
    var replacements = List[String]()
    for index in range(len(batch.exact.records)):
        var record = batch.exact.records.get_index(Float64(index)).value()
        replacements.append(
            callback.call(
                (
                    batch.matches.get_index(Float64(index)).value(),
                    record.argument(1),
                    record.argument(2),
                )
            )
        )
    return _complete_native_callback(batch, replacements^)


def _apply_native_callback_4[
    CallbackError: AnyType
](
    var prepared: RegExpNativeResult[_NativeRegExpCallbackBatch],
    callback: RaisingCallable[
        Tuple[String, JsValue, JsValue, JsValue], String, CallbackError
    ],
) raises CallbackError -> RegExpNativeResult[String]:
    if not prepared.is_success():
        return RegExpNativeResult[String](prepared.take_error())
    var batch = prepared.take_value()
    var replacements = List[String]()
    for index in range(len(batch.exact.records)):
        var record = batch.exact.records.get_index(Float64(index)).value()
        replacements.append(
            callback.call(
                (
                    batch.matches.get_index(Float64(index)).value(),
                    record.argument(1),
                    record.argument(2),
                    record.argument(3),
                )
            )
        )
    return _complete_native_callback(batch, replacements^)


def _apply_native_callback_5[
    CallbackError: AnyType
](
    var prepared: RegExpNativeResult[_NativeRegExpCallbackBatch],
    callback: RaisingCallable[
        Tuple[String, JsValue, JsValue, JsValue, JsValue],
        String,
        CallbackError,
    ],
) raises CallbackError -> RegExpNativeResult[String]:
    if not prepared.is_success():
        return RegExpNativeResult[String](prepared.take_error())
    var batch = prepared.take_value()
    var replacements = List[String]()
    for index in range(len(batch.exact.records)):
        var record = batch.exact.records.get_index(Float64(index)).value()
        replacements.append(
            callback.call(
                (
                    batch.matches.get_index(Float64(index)).value(),
                    record.argument(1),
                    record.argument(2),
                    record.argument(3),
                    record.argument(4),
                )
            )
        )
    return _complete_native_callback(batch, replacements^)


def _apply_native_callback_6[
    CallbackError: AnyType
](
    var prepared: RegExpNativeResult[_NativeRegExpCallbackBatch],
    callback: RaisingCallable[
        Tuple[String, JsValue, JsValue, JsValue, JsValue, JsValue],
        String,
        CallbackError,
    ],
) raises CallbackError -> RegExpNativeResult[String]:
    if not prepared.is_success():
        return RegExpNativeResult[String](prepared.take_error())
    var batch = prepared.take_value()
    var replacements = List[String]()
    for index in range(len(batch.exact.records)):
        var record = batch.exact.records.get_index(Float64(index)).value()
        replacements.append(
            callback.call(
                (
                    batch.matches.get_index(Float64(index)).value(),
                    record.argument(1),
                    record.argument(2),
                    record.argument(3),
                    record.argument(4),
                    record.argument(5),
                )
            )
        )
    return _complete_native_callback(batch, replacements^)


def _apply_native_callback_7[
    CallbackError: AnyType
](
    var prepared: RegExpNativeResult[_NativeRegExpCallbackBatch],
    callback: RaisingCallable[
        Tuple[String, JsValue, JsValue, JsValue, JsValue, JsValue, JsValue],
        String,
        CallbackError,
    ],
) raises CallbackError -> RegExpNativeResult[String]:
    if not prepared.is_success():
        return RegExpNativeResult[String](prepared.take_error())
    var batch = prepared.take_value()
    var replacements = List[String]()
    for index in range(len(batch.exact.records)):
        var record = batch.exact.records.get_index(Float64(index)).value()
        replacements.append(
            callback.call(
                (
                    batch.matches.get_index(Float64(index)).value(),
                    record.argument(1),
                    record.argument(2),
                    record.argument(3),
                    record.argument(4),
                    record.argument(5),
                    record.argument(6),
                )
            )
        )
    return _complete_native_callback(batch, replacements^)


def _apply_native_callback_8[
    CallbackError: AnyType
](
    var prepared: RegExpNativeResult[_NativeRegExpCallbackBatch],
    callback: RaisingCallable[
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
        CallbackError,
    ],
) raises CallbackError -> RegExpNativeResult[String]:
    if not prepared.is_success():
        return RegExpNativeResult[String](prepared.take_error())
    var batch = prepared.take_value()
    var replacements = List[String]()
    for index in range(len(batch.exact.records)):
        var record = batch.exact.records.get_index(Float64(index)).value()
        replacements.append(
            callback.call(
                (
                    batch.matches.get_index(Float64(index)).value(),
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
    return _complete_native_callback(batch, replacements^)
