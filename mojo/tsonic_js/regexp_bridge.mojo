from std.collections import List
from std.ffi import c_int, c_size_t, external_call
from std.memory import ArcPointer

from .json import json_parse
from .string import JsString
from .value import JsValue


comptime _REGEXP_EXEC = 1
comptime _REGEXP_TEST = 2
comptime _REGEXP_MATCH = 3
comptime _REGEXP_MATCH_ALL = 4
comptime _REGEXP_SEARCH = 5
comptime _REGEXP_SPLIT = 6
comptime _REGEXP_REPLACE = 7
comptime _REGEXP_REPLACE_ALL = 8
comptime _REGEXP_DESCRIBE = 9
comptime _REGEXP_ESCAPE = 10
comptime _REGEXP_CALLBACK_REPLACE = 11
comptime _REGEXP_CALLBACK_REPLACE_ALL = 12
comptime _STRING_CALLBACK_REPLACE = 13
comptime _STRING_CALLBACK_REPLACE_ALL = 14


struct _RegExpNativeState(Movable):
    var handle: OptionalPointer[NoneType, MutUntrackedOrigin]

    def __init__(out self, handle: OptionalPointer[NoneType, MutUntrackedOrigin]):
        self.handle = handle

    def __del__(deinit self):
        if self.handle:
            external_call["tsonic_js_regexp_free", NoneType](
                self.handle.value()
            )


struct _RegExpBridge(ImplicitlyCopyable):
    var _state: ArcPointer[_RegExpNativeState]

    def __init__(out self) raises:
        self = Self._create(JsString(), False, JsString(), False)

    def __init__(out self, pattern: JsString) raises:
        self = Self._create(pattern, True, JsString(), False)

    def __init__(out self, pattern: JsString, flags: JsString) raises:
        self = Self._create(pattern, True, flags, True)

    @staticmethod
    def _create(
        pattern: JsString,
        has_pattern: Bool,
        flags: JsString,
        has_flags: Bool,
    ) raises -> Self:
        var pattern_units = pattern._copy_code_units()
        var flag_units = flags._copy_code_units()
        var result = external_call[
            "tsonic_js_regexp_create",
            OptionalPointer[NoneType, MutUntrackedOrigin],
        ](
            pattern_units.unsafe_ptr(),
            c_size_t(len(pattern_units)),
            c_int(has_pattern),
            flag_units.unsafe_ptr(),
            c_size_t(len(flag_units)),
            c_int(has_flags),
        )
        if not result:
            raise Error("Unable to allocate JavaScript RegExp result")
        var result_pointer = result.value()
        var handle = external_call[
            "tsonic_js_regexp_create_value",
            OptionalPointer[NoneType, MutUntrackedOrigin],
        ](result_pointer)
        if not handle:
            var message = _create_error(result_pointer)
            external_call["tsonic_js_regexp_create_result_free", NoneType](
                result_pointer
            )
            raise Error(message)
        external_call["tsonic_js_regexp_create_result_free", NoneType](
            result_pointer
        )
        return Self(ArcPointer(_RegExpNativeState(handle)))

    def __init__(out self, state: ArcPointer[_RegExpNativeState]):
        self._state = state

    def exec(self, input: JsString) raises -> JsValue:
        return self._command(_REGEXP_EXEC, input)

    def test(self, input: JsString) raises -> JsValue:
        return self._command(_REGEXP_TEST, input)

    def match(self, input: JsString) raises -> JsValue:
        return self._command(_REGEXP_MATCH, input)

    def match_all(self, input: JsString) raises -> JsValue:
        return self._command(_REGEXP_MATCH_ALL, input)

    def search(self, input: JsString) raises -> JsValue:
        return self._command(_REGEXP_SEARCH, input)

    def split(self, input: JsString) raises -> JsValue:
        return self._command(_REGEXP_SPLIT, input)

    def split(self, input: JsString, limit: Float64) raises -> JsValue:
        return self._command(_REGEXP_SPLIT, input, number=limit)

    def replace(
        self, input: JsString, replacement: JsString
    ) raises -> JsValue:
        return self._command(
            _REGEXP_REPLACE, input, argument=replacement
        )

    def replace_all(
        self, input: JsString, replacement: JsString
    ) raises -> JsValue:
        return self._command(
            _REGEXP_REPLACE_ALL, input, argument=replacement
        )

    def describe(self) raises -> JsValue:
        return self._command(_REGEXP_DESCRIBE, JsString())

    def escape(self, input: JsString) raises -> JsValue:
        return self._command(_REGEXP_ESCAPE, input)

    def callback_replace(self, input: JsString) raises -> JsValue:
        return self._command(_REGEXP_CALLBACK_REPLACE, input)

    def callback_replace_all(self, input: JsString) raises -> JsValue:
        return self._command(_REGEXP_CALLBACK_REPLACE_ALL, input)

    def string_callback_replace(
        self, input: JsString, search: JsString
    ) raises -> JsValue:
        return self._command(
            _STRING_CALLBACK_REPLACE, input, argument=search
        )

    def string_callback_replace_all(
        self, input: JsString, search: JsString
    ) raises -> JsValue:
        return self._command(
            _STRING_CALLBACK_REPLACE_ALL, input, argument=search
        )

    def set_last_index(self, value: Float64) raises:
        if not external_call["tsonic_js_regexp_set_last_index", c_int](
            self._handle(), value
        ):
            raise Error("Unable to set JavaScript RegExp lastIndex")

    def _command(
        self,
        operation: Int,
        input: JsString,
        argument: JsString = JsString(),
        number: Optional[Float64] = None,
    ) raises -> JsValue:
        var input_units = input._copy_code_units()
        var argument_units = argument._copy_code_units()
        var has_number = Bool(number)
        var numeric_value = number.value() if number else 0
        var result = external_call[
            "tsonic_js_regexp_command",
            OptionalPointer[NoneType, MutUntrackedOrigin],
        ](
            self._handle(),
            c_int(operation),
            input_units.unsafe_ptr(),
            c_size_t(len(input_units)),
            argument_units.unsafe_ptr(),
            c_size_t(len(argument_units)),
            numeric_value,
            c_int(has_number),
        )
        if not result:
            raise Error("Unable to allocate JavaScript RegExp command result")
        var result_pointer = result.value()
        var error = external_call[
            "tsonic_js_regexp_command_error",
            OptionalPointer[UInt8, ImmUntrackedOrigin],
        ](result_pointer)
        if error:
            var message = String(unsafe_from_utf8_ptr=error.value())
            external_call[
                "tsonic_js_regexp_command_result_free", NoneType
            ](result_pointer)
            raise Error(message)
        var json = external_call[
            "tsonic_js_regexp_command_json",
            OptionalPointer[UInt8, ImmUntrackedOrigin],
        ](result_pointer)
        if not json:
            external_call[
                "tsonic_js_regexp_command_result_free", NoneType
            ](result_pointer)
            raise Error("JavaScript RegExp command produced no result")
        var text = String(unsafe_from_utf8_ptr=json.value())
        external_call["tsonic_js_regexp_command_result_free", NoneType](
            result_pointer
        )
        return json_parse(JsString(text^))

    def _handle(self) -> Pointer[NoneType, MutUntrackedOrigin]:
        return self._state[].handle.value()


def _create_error(
    result: Pointer[NoneType, MutUntrackedOrigin]
) -> String:
    var error = external_call[
        "tsonic_js_regexp_create_error",
        OptionalPointer[UInt8, ImmUntrackedOrigin],
    ](result)
    return (
        String(unsafe_from_utf8_ptr=error.value())
        if error
        else String("JavaScript RegExp construction failed")
    )
