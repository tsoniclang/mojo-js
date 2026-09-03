from std.collections import List

from tsonic_runtime import Undefined

from .array import JsArray
from .regexp_bridge import _RegExpBridge
from .regexp_results import (
    JsRegExpExecArray,
    JsRegExpMatchArray,
    JsRegExpStringIterator,
    RegExpExecArray,
    RegExpMatchArray,
    RegExpStringIterator,
    _parse_exact_exec,
    _parse_exact_match,
    _parse_exact_match_all,
    _required_object_field,
)
from .string import JsString
from .string_array import string_split
from .value import JsValue


struct JsRegExp(ImplicitlyCopyable, Sized, Writable):
    var _bridge: _RegExpBridge

    def __init__(out self) raises:
        self._bridge = _RegExpBridge()

    def __init__(out self, pattern: JsString) raises:
        self._bridge = _RegExpBridge(pattern)

    def __init__(out self, pattern: JsString, flags: JsString) raises:
        self._bridge = _RegExpBridge(pattern, flags)

    def write_to(self, mut writer: Some[Writer]) raises:
        writer.write(self.to_string())

    def exec(self, input: JsString) raises -> Optional[JsRegExpExecArray]:
        return _parse_exact_exec(_result(self._bridge.exec(input)))

    def exec_native(self, input: String) raises -> Optional[RegExpExecArray]:
        var result = self.exec(JsString(input))
        return (
            Optional[RegExpExecArray](result.value()._native())
            if result
            else None
        )

    def test(self, input: JsString) raises -> Bool:
        return _result(self._bridge.test(input)).bool_value()

    def test_native(self, input: String) raises -> Bool:
        return self.test(JsString(input))

    def match(self, input: JsString) raises -> Optional[JsRegExpMatchArray]:
        return _parse_exact_match(_result(self._bridge.match(input)))

    def match_native(self, input: String) raises -> Optional[RegExpMatchArray]:
        var result = self.match(JsString(input))
        return (
            Optional[RegExpMatchArray](result.value()._native())
            if result
            else None
        )

    def match_all(self, input: JsString) raises -> JsRegExpStringIterator:
        return _parse_exact_match_all(_result(self._bridge.match_all(input)))

    def match_all_native(self, input: String) raises -> RegExpStringIterator:
        var exact = self.match_all(JsString(input)).iter_values()
        var native = List[RegExpExecArray]()
        for value in exact:
            native.append(value._native())
        return RegExpStringIterator(JsArray[RegExpExecArray](native^))

    def search(self, input: JsString) raises -> Float64:
        return _result(self._bridge.search(input)).number_value()

    def search_native(self, input: String) raises -> Float64:
        return self.search(JsString(input))

    def split(self, input: JsString) raises -> JsArray[JsString]:
        return _string_array(_result(self._bridge.split(input)))

    def split(self, input: JsString, limit: Float64) raises -> JsArray[JsString]:
        return _string_array(_result(self._bridge.split(input, limit)))

    def split_native(self, input: String) raises -> JsArray[String]:
        return _native_string_array(self.split(JsString(input)))

    def split_native(
        self, input: String, limit: Float64
    ) raises -> JsArray[String]:
        return _native_string_array(self.split(JsString(input), limit))

    def replace(
        self, input: JsString, replacement: JsString
    ) raises -> JsString:
        return _result(self._bridge.replace(input, replacement)).string_value()

    def replace_native(
        self, input: String, replacement: String
    ) raises -> String:
        return self.replace(
            JsString(input), JsString(replacement)
        ).to_native_strict()

    def replace_all(
        self, input: JsString, replacement: JsString
    ) raises -> JsString:
        return _result(
            self._bridge.replace_all(input, replacement)
        ).string_value()

    def replace_all_native(
        self, input: String, replacement: String
    ) raises -> String:
        return self.replace_all(
            JsString(input), JsString(replacement)
        ).to_native_strict()

    def source(self) raises -> String:
        return _description(self._bridge, "source").string_value().to_native_strict()

    def flags(self) raises -> String:
        return _description(self._bridge, "flags").string_value().to_native_strict()

    def global_(self) raises -> Bool:
        return _description(self._bridge, "global").bool_value()

    def ignore_case(self) raises -> Bool:
        return _description(self._bridge, "ignoreCase").bool_value()

    def multiline(self) raises -> Bool:
        return _description(self._bridge, "multiline").bool_value()

    def dot_all(self) raises -> Bool:
        return _description(self._bridge, "dotAll").bool_value()

    def has_indices(self) raises -> Bool:
        return _description(self._bridge, "hasIndices").bool_value()

    def sticky(self) raises -> Bool:
        return _description(self._bridge, "sticky").bool_value()

    def unicode(self) raises -> Bool:
        return _description(self._bridge, "unicode").bool_value()

    def unicode_sets(self) raises -> Bool:
        return _description(self._bridge, "unicodeSets").bool_value()

    def last_index(self) raises -> Float64:
        return _description(self._bridge, "lastIndex").number_value()

    def set_last_index(mut self, value: Float64) raises:
        self._bridge.set_last_index(value)

    def to_string(self) raises -> String:
        return _description(self._bridge, "text").string_value().to_native_strict()


def regexp_construct() raises -> JsRegExp:
    return JsRegExp()


def regexp_construct(pattern: String) raises -> JsRegExp:
    return JsRegExp(JsString(pattern))


def regexp_construct(pattern: JsString) raises -> JsRegExp:
    return JsRegExp(pattern)


def regexp_construct(pattern: Undefined) raises -> JsRegExp:
    return JsRegExp()


def regexp_construct(pattern: JsRegExp) raises -> JsRegExp:
    return JsRegExp(JsString(pattern.source()), JsString(pattern.flags()))


def regexp_construct(pattern: String, flags: String) raises -> JsRegExp:
    return JsRegExp(JsString(pattern), JsString(flags))


def regexp_construct(pattern: JsString, flags: String) raises -> JsRegExp:
    return JsRegExp(pattern, JsString(flags))


def regexp_construct(pattern: Undefined, flags: String) raises -> JsRegExp:
    return JsRegExp(JsString(), JsString(flags))


def regexp_construct(pattern: JsRegExp, flags: String) raises -> JsRegExp:
    return JsRegExp(JsString(pattern.source()), JsString(flags))


def regexp_construct(pattern: String, flags: Undefined) raises -> JsRegExp:
    return regexp_construct(pattern)


def regexp_construct(pattern: JsString, flags: Undefined) raises -> JsRegExp:
    return regexp_construct(pattern)


def regexp_construct(pattern: Undefined, flags: Undefined) raises -> JsRegExp:
    return regexp_construct()


def regexp_construct(pattern: JsRegExp, flags: Undefined) raises -> JsRegExp:
    return regexp_construct(pattern)


def regexp_call() raises -> JsRegExp:
    return regexp_construct()


def regexp_call(pattern: String) raises -> JsRegExp:
    return regexp_construct(pattern)


def regexp_call(pattern: JsString) raises -> JsRegExp:
    return regexp_construct(pattern)


def regexp_call(pattern: Undefined) raises -> JsRegExp:
    return regexp_construct()


def regexp_call(pattern: JsRegExp) -> JsRegExp:
    return pattern


def regexp_call(pattern: String, flags: String) raises -> JsRegExp:
    return regexp_construct(pattern, flags)


def regexp_call(pattern: JsString, flags: String) raises -> JsRegExp:
    return regexp_construct(pattern, flags)


def regexp_call(pattern: Undefined, flags: String) raises -> JsRegExp:
    return regexp_construct(pattern, flags)


def regexp_call(pattern: JsRegExp, flags: String) raises -> JsRegExp:
    return regexp_construct(pattern, flags)


def regexp_call(pattern: String, flags: Undefined) raises -> JsRegExp:
    return regexp_construct(pattern)


def regexp_call(pattern: JsString, flags: Undefined) raises -> JsRegExp:
    return regexp_construct(pattern)


def regexp_call(pattern: Undefined, flags: Undefined) raises -> JsRegExp:
    return regexp_construct()


def regexp_call(pattern: JsRegExp, flags: Undefined) -> JsRegExp:
    return pattern


def regexp_escape(value: String) raises -> String:
    return _regexp_escape_exact(JsString(value)).to_native_strict()


def regexp_escape(value: JsString) raises -> String:
    return _regexp_escape_exact(value).to_native_strict()


def _regexp_escape_exact(value: JsString) raises -> JsString:
    return _result(_RegExpBridge().escape(value)).string_value()


def _result(command: JsValue) raises -> JsValue:
    return _required_object_field(command, "value")


def _description(bridge: _RegExpBridge, name: String) raises -> JsValue:
    return _required_object_field(bridge.describe(), name)


def _string_array(value: JsValue) raises -> JsArray[JsString]:
    var result = List[JsString]()
    for index in range(value.array_length()):
        result.append(value.array_at(index).string_value())
    return JsArray[JsString](result^)


def _native_string_array(value: JsArray[JsString]) raises -> JsArray[String]:
    var result = List[String]()
    for item in value.iter_values():
        result.append(item.to_native_strict())
    return JsArray[String](result^)


def exec_value(expression: JsRegExp, input: String) raises -> Optional[RegExpExecArray]:
    return expression.exec_native(input)


def exec_value(expression: JsRegExp, input: JsString) raises -> Optional[JsRegExpExecArray]:
    return expression.exec(input)


def test_value(expression: JsRegExp, input: String) raises -> Bool:
    return expression.test_native(input)


def test_value(expression: JsRegExp, input: JsString) raises -> Bool:
    return expression.test(input)


def match_value(expression: JsRegExp, input: String) raises -> Optional[RegExpMatchArray]:
    return expression.match_native(input)


def match_value(expression: JsRegExp, input: JsString) raises -> Optional[JsRegExpMatchArray]:
    return expression.match(input)


def match_all_value(expression: JsRegExp, input: String) raises -> RegExpStringIterator:
    return expression.match_all_native(input)


def match_all_value(expression: JsRegExp, input: JsString) raises -> JsRegExpStringIterator:
    return expression.match_all(input)


def replace_value(expression: JsRegExp, input: String, replacement: String) raises -> String:
    return expression.replace_native(input, replacement)


def replace_value(expression: JsRegExp, input: JsString, replacement: JsString) raises -> JsString:
    return expression.replace(input, replacement)


def search_value(expression: JsRegExp, input: String) raises -> Float64:
    return expression.search_native(input)


def search_value(expression: JsRegExp, input: JsString) raises -> Float64:
    return expression.search(input)


def split_value(expression: JsRegExp, input: String) raises -> JsArray[String]:
    return expression.split_native(input)


def split_value(expression: JsRegExp, input: String, limit: Float64) raises -> JsArray[String]:
    return expression.split_native(input, limit)


def split_value(expression: JsRegExp, input: JsString) raises -> JsArray[JsString]:
    return expression.split(input)


def split_value(expression: JsRegExp, input: JsString, limit: Float64) raises -> JsArray[JsString]:
    return expression.split(input, limit)


def string_match_pattern(value: String, pattern: String) raises -> Optional[RegExpMatchArray]:
    return JsRegExp(JsString(pattern)).match_native(value)


def string_match_pattern(value: String, pattern: JsRegExp) raises -> Optional[RegExpMatchArray]:
    return pattern.match_native(value)


def js_string_match_pattern(value: JsString, pattern: JsString) raises -> Optional[JsRegExpMatchArray]:
    return JsRegExp(pattern).match(value)


def js_string_match_pattern(value: JsString, pattern: JsRegExp) raises -> Optional[JsRegExpMatchArray]:
    return pattern.match(value)


def string_match_all_pattern(value: String, pattern: JsRegExp) raises -> RegExpStringIterator:
    return pattern.match_all_native(value)


def js_string_match_all_pattern(value: JsString, pattern: JsRegExp) raises -> JsRegExpStringIterator:
    return pattern.match_all(value)


def string_replace_pattern(value: String, search: String, replacement: String) raises -> String:
    return JsString(value).replace(JsString(search), JsString(replacement)).to_native_strict()


def string_replace_pattern(value: String, search: JsRegExp, replacement: String) raises -> String:
    return search.replace_native(value, replacement)


def js_string_replace_pattern(value: JsString, search: JsString, replacement: JsString) raises -> JsString:
    return value.replace(search, replacement)


def js_string_replace_pattern(value: JsString, search: JsRegExp, replacement: JsString) raises -> JsString:
    return search.replace(value, replacement)


def string_replace_all_pattern(value: String, search: String, replacement: String) raises -> String:
    return JsString(value).replace_all(JsString(search), JsString(replacement)).to_native_strict()


def string_replace_all_pattern(value: String, search: JsRegExp, replacement: String) raises -> String:
    return search.replace_all_native(value, replacement)


def js_string_replace_all_pattern(value: JsString, search: JsString, replacement: JsString) raises -> JsString:
    return value.replace_all(search, replacement)


def js_string_replace_all_pattern(value: JsString, search: JsRegExp, replacement: JsString) raises -> JsString:
    return search.replace_all(value, replacement)


def string_search_pattern(value: String, pattern: String) raises -> Float64:
    return JsRegExp(JsString(pattern)).search_native(value)


def string_search_pattern(value: String, pattern: JsRegExp) raises -> Float64:
    return pattern.search_native(value)


def js_string_search_pattern(value: JsString, pattern: JsString) raises -> Float64:
    return JsRegExp(pattern).search(value)


def js_string_search_pattern(value: JsString, pattern: JsRegExp) raises -> Float64:
    return pattern.search(value)


def string_split_pattern(value: String, separator: String) raises -> JsArray[String]:
    return _native_string_array(string_split(JsString(value), JsString(separator)))


def string_split_pattern(value: String, separator: String, limit: Float64) raises -> JsArray[String]:
    return _native_string_array(string_split(JsString(value), JsString(separator), limit))


def string_split_pattern(value: String, separator: JsRegExp) raises -> JsArray[String]:
    return separator.split_native(value)


def string_split_pattern(value: String, separator: JsRegExp, limit: Float64) raises -> JsArray[String]:
    return separator.split_native(value, limit)


def js_string_split_pattern(value: JsString, separator: JsString) -> JsArray[JsString]:
    return string_split(value, separator)


def js_string_split_pattern(value: JsString, separator: JsString, limit: Float64) -> JsArray[JsString]:
    return string_split(value, separator, limit)


def js_string_split_pattern(value: JsString, separator: JsRegExp) raises -> JsArray[JsString]:
    return separator.split(value)


def js_string_split_pattern(value: JsString, separator: JsRegExp, limit: Float64) raises -> JsArray[JsString]:
    return separator.split(value, limit)
