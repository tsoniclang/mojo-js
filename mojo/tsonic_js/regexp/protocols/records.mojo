from ...array import JsArray
from ...string import JsString
from ...value import JsValue, _js_value_from_tagged_callback_argument
from ..core import JsRegExp
from ..engine.bridge import _RegExpBridge
from std.collections import List
from ..results.decode import _required_object_field


struct RegExpNativeResult[T: Movable & Deinitable](Movable):
    var _value: Optional[Self.T]
    var _error: Optional[Error]

    def __init__(out self, var value: Self.T):
        self._value = Optional[Self.T](value^)
        self._error = None

    def __init__(out self, var error: Error):
        self._value = None
        self._error = Optional[Error](error^)

    def is_success(self) -> Bool:
        return Bool(self._value)

    def take_value(mut self) -> Self.T:
        return self._value.take()

    def take_error(mut self) -> Error:
        return self._error.take()

    def unwrap(deinit self) raises -> Self.T:
        if self._error:
            raise self._error.take()
        return self._value.take()


struct _RegExpCallbackRecord(ImplicitlyCopyable):
    var start: Int
    var end: Int
    var arguments: JsArray[JsValue]

    def __init__(out self, start: Int, end: Int, arguments: JsArray[JsValue]):
        self.start = start
        self.end = end
        self.arguments = arguments

    def matched(self) raises -> JsString:
        return self.argument(0).string_value()

    def argument(self, index: Int) -> JsValue:
        var value = self.arguments.get_index(Float64(index))
        return value.value() if value else JsValue.undefined()


struct _RegExpCallbackBatch(ImplicitlyCopyable):
    var input: JsString
    var records: JsArray[_RegExpCallbackRecord]

    def __init__(
        out self, input: JsString, records: JsArray[_RegExpCallbackRecord]
    ):
        self.input = input
        self.records = records


struct _NativeRegExpCallbackBatch(ImplicitlyCopyable):
    var exact: _RegExpCallbackBatch
    var matches: JsArray[String]

    def __init__(
        out self,
        exact: _RegExpCallbackBatch,
        matches: JsArray[String],
    ):
        self.exact = exact
        self.matches = matches


def _prepare_regexp_callback(
    expression: JsRegExp,
    input: JsString,
    replace_all: Bool,
) -> RegExpNativeResult[_RegExpCallbackBatch]:
    try:
        var command = expression._bridge.callback_replace_all(
            input
        ) if replace_all else expression._bridge.callback_replace(input)
        return RegExpNativeResult[_RegExpCallbackBatch](
            _parse_callback_batch(input, command)
        )
    except error:
        return RegExpNativeResult[_RegExpCallbackBatch](error^)


def _prepare_string_callback(
    input: JsString,
    search: JsString,
    replace_all: Bool,
) -> RegExpNativeResult[_RegExpCallbackBatch]:
    try:
        var bridge = _RegExpBridge()
        var command = bridge.string_callback_replace_all(
            input, search
        ) if replace_all else bridge.string_callback_replace(input, search)
        return RegExpNativeResult[_RegExpCallbackBatch](
            _parse_callback_batch(input, command)
        )
    except error:
        return RegExpNativeResult[_RegExpCallbackBatch](error^)


def _prepare_native_callback(
    var prepared: RegExpNativeResult[_RegExpCallbackBatch],
) -> RegExpNativeResult[_NativeRegExpCallbackBatch]:
    if not prepared.is_success():
        return RegExpNativeResult[_NativeRegExpCallbackBatch](
            prepared.take_error()
        )
    try:
        var exact = prepared.take_value()
        var matches = List[String]()
        for stored_record in exact.records._elements[]:
            var record = stored_record.value()
            matches.append(record.matched().to_native_strict())
        return RegExpNativeResult[_NativeRegExpCallbackBatch](
            _NativeRegExpCallbackBatch(exact, JsArray[String](matches^))
        )
    except error:
        return RegExpNativeResult[_NativeRegExpCallbackBatch](error^)


def _parse_callback_batch(
    input: JsString, command: JsValue
) raises -> _RegExpCallbackBatch:
    var value = _required_object_field(command, "value")
    var records = List[_RegExpCallbackRecord]()
    var previous_end = 0
    for index in range(value.array_length()):
        var encoded = value.array_at(index)
        var start = _callback_index(
            _required_object_field(encoded, "start"), len(input)
        )
        var end = _callback_index(
            _required_object_field(encoded, "end"), len(input)
        )
        if start < previous_end or end < start:
            raise Error("JavaScript RegExp callback spans are not ordered")
        var encoded_arguments = _required_object_field(encoded, "arguments")
        if encoded_arguments.array_length() < 3:
            raise Error(
                "JavaScript RegExp callback record has too few arguments"
            )
        var arguments = List[JsValue]()
        for argument_index in range(encoded_arguments.array_length()):
            arguments.append(
                _js_value_from_tagged_callback_argument(
                    encoded_arguments.array_at(argument_index)
                )
            )
        var record = _RegExpCallbackRecord(
            start, end, JsArray[JsValue](arguments^)
        )
        var matched = record.matched()
        if (
            end - start != len(matched)
            or input.slice(Float64(start), Float64(end)) != matched
        ):
            raise Error("JavaScript RegExp callback span does not match input")
        records.append(record)
        previous_end = end
    return _RegExpCallbackBatch(input, JsArray[_RegExpCallbackRecord](records^))


def _callback_index(value: JsValue, input_length: Int) raises -> Int:
    var number = value.number_value()
    if number < 0 or number > Float64(input_length):
        raise Error("JavaScript RegExp callback index is out of range")
    var index = Int(number)
    if number != Float64(index):
        raise Error("JavaScript RegExp callback index is not integral")
    return index


def _complete_exact_callback(
    batch: _RegExpCallbackBatch, var replacements: List[JsString]
) -> RegExpNativeResult[JsString]:
    return RegExpNativeResult[JsString](
        _reconstruct_callback_output(batch, replacements^)
    )


def _complete_native_callback(
    batch: _NativeRegExpCallbackBatch, var replacements: List[String]
) -> RegExpNativeResult[String]:
    var exact_replacements = List[JsString]()
    for replacement in replacements:
        exact_replacements.append(JsString(replacement))
    var exact = _reconstruct_callback_output(batch.exact, exact_replacements^)
    try:
        return RegExpNativeResult[String](exact.to_native_strict())
    except error:
        return RegExpNativeResult[String](error^)


def _reconstruct_callback_output(
    batch: _RegExpCallbackBatch, var replacements: List[JsString]
) -> JsString:
    var units = List[UInt16]()
    var cursor = 0
    for index in range(len(batch.records)):
        var record = batch.records.get_index(Float64(index)).value()
        _append_code_units(units, batch.input, cursor, record.start)
        _append_code_units(
            units, replacements[index], 0, len(replacements[index])
        )
        cursor = record.end
    _append_code_units(units, batch.input, cursor, len(batch.input))
    return JsString(code_units=units^)


def _append_code_units(
    mut destination: List[UInt16],
    value: JsString,
    start: Int,
    end: Int,
):
    for index in range(start, end):
        destination.append(value.code_unit_at(index).value())
