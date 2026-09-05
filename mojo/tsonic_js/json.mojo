from std.collections import List
from std.collections.string import Codepoint
from std.memory import ArcPointer
from tsonic_runtime import RaisingCallable

from .number import number_to_string
from .object import _object_key_order
from .string import JsString
from .value import JsValue, _JsValueBuilder


comptime _MAX_JSON_INPUT_UNITS = 16777216
comptime _MAX_JSON_OUTPUT_UNITS = 67108864
comptime _MAX_JSON_DEPTH = 512


def json_parse(source: JsString) raises -> JsValue:
    var parser = _JsonParser(source)
    return parser.parse()


def json_stringify(value: JsValue) raises -> Optional[JsString]:
    var writer = _JsonWriter()
    if not writer.write_property(JsString(), value, 0):
        return None
    return Optional[JsString](writer.finish())


def json_stringify_with_space_number(
    value: JsValue, space: Float64
) raises -> Optional[JsString]:
    var writer = _JsonWriter(_number_indent(space))
    if not writer.write_property(JsString(), value, 0):
        return None
    return Optional[JsString](writer.finish())


def json_stringify_with_space_string(
    value: JsValue, space: JsString
) raises -> Optional[JsString]:
    var writer = _JsonWriter(_string_indent(space))
    if not writer.write_property(JsString(), value, 0):
        return None
    return Optional[JsString](writer.finish())


def json_stringify_with_replacer(
    value: JsValue,
    replacer: RaisingCallable[Tuple[String, JsValue], JsValue, Error],
) raises -> Optional[JsString]:
    var writer = _JsonWriter(replacer)
    if not writer.write_property(JsString(), value, 0):
        return None
    return Optional[JsString](writer.finish())


def json_stringify_with_replacer_and_space_number(
    value: JsValue,
    replacer: RaisingCallable[Tuple[String, JsValue], JsValue, Error],
    space: Float64,
) raises -> Optional[JsString]:
    var writer = _JsonWriter(replacer, _number_indent(space))
    if not writer.write_property(JsString(), value, 0):
        return None
    return Optional[JsString](writer.finish())


def json_stringify_with_replacer_and_space_string(
    value: JsValue,
    replacer: RaisingCallable[Tuple[String, JsValue], JsValue, Error],
    space: JsString,
) raises -> Optional[JsString]:
    var writer = _JsonWriter(replacer, _string_indent(space))
    if not writer.write_property(JsString(), value, 0):
        return None
    return Optional[JsString](writer.finish())


struct _JsonParser:
    var _source: JsString
    var _position: Int
    var _builder: _JsValueBuilder

    def __init__(out self, source: JsString):
        self._source = source
        self._position = 0
        self._builder = _JsValueBuilder()

    def parse(mut self) raises -> JsValue:
        if len(self._source) > _MAX_JSON_INPUT_UNITS:
            raise Error("JSON input exceeds its source budget")
        self._skip_whitespace()
        var root = self._parse_value(0)
        self._skip_whitespace()
        if self._position != len(self._source):
            raise Error("unexpected data after JSON value")
        return self._builder.value(root)

    def _parse_value(mut self, depth: Int) raises -> Int:
        if depth > _MAX_JSON_DEPTH:
            raise Error("JSON input exceeds its nesting budget")
        self._skip_whitespace()
        var unit = self._current()
        if unit == 34:
            return self._builder.append_string(self._parse_string())
        if unit == 91:
            return self._parse_array(depth)
        if unit == 123:
            return self._parse_object(depth)
        if unit == 116:
            self._consume_literal(116, 114, 117, 101)
            return self._builder.append_bool(True)
        if unit == 102:
            self._consume_literal(102, 97, 108, 115, 101)
            return self._builder.append_bool(False)
        if unit == 110:
            self._consume_literal(110, 117, 108, 108)
            return self._builder.append_null()
        if unit == 45 or _is_digit(unit):
            return self._builder.append_number(self._parse_number())
        raise Error("invalid JSON value")

    def _parse_array(mut self, depth: Int) raises -> Int:
        self._expect(91)
        self._skip_whitespace()
        var children = List[Int]()
        if self._matches(93):
            self._position += 1
            return self._builder.append_array(children^)
        while True:
            children.append(self._parse_value(depth + 1))
            self._skip_whitespace()
            if self._matches(93):
                self._position += 1
                return self._builder.append_array(children^)
            self._expect(44)
            self._skip_whitespace()

    def _parse_object(mut self, depth: Int) raises -> Int:
        self._expect(123)
        self._skip_whitespace()
        var keys = List[JsString]()
        var children = List[Int]()
        if self._matches(125):
            self._position += 1
            return self._builder.append_object(keys^, children^)
        while True:
            if not self._matches(34):
                raise Error("JSON object key must be a string")
            var key = self._parse_string()
            self._skip_whitespace()
            self._expect(58)
            self._skip_whitespace()
            var child = self._parse_value(depth + 1)
            var existing = -1
            for index in range(len(keys)):
                if keys[index] == key:
                    existing = index
                    break
            if existing < 0:
                keys.append(key)
                children.append(child)
            else:
                children[existing] = child
            self._skip_whitespace()
            if self._matches(125):
                self._position += 1
                return self._builder.append_object(keys^, children^)
            self._expect(44)
            self._skip_whitespace()

    def _parse_string(mut self) raises -> JsString:
        self._expect(34)
        var units = List[UInt16]()
        while self._position < len(self._source):
            var unit = self._take()
            if unit == 34:
                return JsString(code_units=units^)
            if unit < 32:
                raise Error("unescaped control character in JSON string")
            if unit != 92:
                units.append(unit)
                continue
            var escape = self._take()
            if escape == 34 or escape == 47 or escape == 92:
                units.append(escape)
            elif escape == 98:
                units.append(8)
            elif escape == 102:
                units.append(12)
            elif escape == 110:
                units.append(10)
            elif escape == 114:
                units.append(13)
            elif escape == 116:
                units.append(9)
            elif escape == 117:
                units.append(self._parse_hex_quad())
            else:
                raise Error("invalid JSON string escape")
        raise Error("unterminated JSON string")

    def _parse_hex_quad(mut self) raises -> UInt16:
        var value = UInt32(0)
        for _ in range(4):
            var unit = self._take()
            var digit = _hex_digit(unit)
            if digit < 0:
                raise Error("invalid JSON Unicode escape")
            value = value * 16 + UInt32(digit)
        return UInt16(value)

    def _parse_number(mut self) raises -> Float64:
        var start = self._position
        if self._matches(45):
            self._position += 1
        if self._matches(48):
            self._position += 1
            if self._position < len(self._source) and _is_digit(
                self._current()
            ):
                raise Error("JSON number has a leading zero")
        else:
            self._require_digit()
            while self._position < len(self._source) and _is_digit(
                self._current()
            ):
                self._position += 1
        if self._matches(46):
            self._position += 1
            self._require_digit()
            while self._position < len(self._source) and _is_digit(
                self._current()
            ):
                self._position += 1
        if self._matches(69) or self._matches(101):
            self._position += 1
            if self._matches(43) or self._matches(45):
                self._position += 1
            self._require_digit()
            while self._position < len(self._source) and _is_digit(
                self._current()
            ):
                self._position += 1
        var text = String()
        for index in range(start, self._position):
            text.append(
                Codepoint(
                    unsafe_unchecked_codepoint=UInt32(
                        self._source.code_unit_at(index).value()
                    )
                )
            )
        return atof(text)

    def _require_digit(mut self) raises:
        if self._position >= len(self._source) or not _is_digit(
            self._current()
        ):
            raise Error("invalid JSON number")
        self._position += 1

    def _consume_literal(mut self, *units: UInt16) raises:
        for unit in units:
            self._expect(unit)

    def _skip_whitespace(mut self):
        while self._position < len(self._source):
            var unit = self._source.code_unit_at(self._position).value()
            if unit != 32 and unit != 9 and unit != 10 and unit != 13:
                return
            self._position += 1

    def _matches(self, unit: UInt16) -> Bool:
        return (
            self._position < len(self._source)
            and self._source.code_unit_at(self._position).value() == unit
        )

    def _expect(mut self, unit: UInt16) raises:
        if not self._matches(unit):
            raise Error("unexpected JSON token")
        self._position += 1

    def _current(self) raises -> UInt16:
        if self._position >= len(self._source):
            raise Error("unexpected end of JSON input")
        return self._source.code_unit_at(self._position).value()

    def _take(mut self) raises -> UInt16:
        var unit = self._current()
        self._position += 1
        return unit


struct _JsonWriter:
    var _units: ArcPointer[List[UInt16]]
    var _active: List[JsValue]
    var _indent: JsString
    var _replacer: Optional[
        RaisingCallable[Tuple[String, JsValue], JsValue, Error]
    ]

    def __init__(out self):
        self._units = ArcPointer(List[UInt16]())
        self._active = List[JsValue]()
        self._indent = JsString()
        self._replacer = None

    def __init__(out self, indent: JsString):
        self._units = ArcPointer(List[UInt16]())
        self._active = List[JsValue]()
        self._indent = indent
        self._replacer = None

    def __init__(
        out self,
        replacer: RaisingCallable[Tuple[String, JsValue], JsValue, Error],
    ):
        self._units = ArcPointer(List[UInt16]())
        self._active = List[JsValue]()
        self._indent = JsString()
        self._replacer = Optional[
            RaisingCallable[Tuple[String, JsValue], JsValue, Error]
        ](replacer)

    def __init__(
        out self,
        replacer: RaisingCallable[Tuple[String, JsValue], JsValue, Error],
        indent: JsString,
    ):
        self._units = ArcPointer(List[UInt16]())
        self._active = List[JsValue]()
        self._indent = indent
        self._replacer = Optional[
            RaisingCallable[Tuple[String, JsValue], JsValue, Error]
        ](replacer)

    def finish(self) -> JsString:
        return JsString(code_unit_storage=self._units)

    def write_property(
        mut self, key: JsString, value: JsValue, depth: Int
    ) raises -> Bool:
        var selected = value
        var projected = selected.is_json_projection()
        if projected:
            self._enter(selected)
            selected = selected._project_json(key.to_native_strict())
        if self._replacer:
            selected = self._replacer.value().call(
                (key.to_native_strict(), selected)
            )
        var written = self._write_value(selected, depth)
        if projected:
            _ = self._active.pop()
        return written

    def _write_value(mut self, value: JsValue, depth: Int) raises -> Bool:
        if depth > _MAX_JSON_DEPTH:
            raise Error("JSON output exceeds its nesting budget")
        if value.is_undefined() or value.is_symbol():
            return False
        if value.is_null():
            self._append_ascii("null")
            return True
        if value.is_bool():
            if value._bool_value():
                self._append_ascii("true")
            else:
                self._append_ascii("false")
            return True
        if value.is_number():
            var number = value._number_value()
            if (
                number != number
                or number == Float64(FloatLiteral.infinity)
                or number == Float64(FloatLiteral.negative_infinity)
            ):
                self._append_ascii("null")
            else:
                self._append_string(number_to_string(number))
            return True
        if value.is_string():
            self._write_string(value._string_value())
            return True
        if value.is_json_projection():
            raise Error(
                "A selected toJSON projection returned another unresolved JSON"
                " projection"
            )
        if not value.is_array() and not value.is_object():
            return False
        self._enter(value)
        if value.is_array():
            self._append_unit(91)
            for index in range(value.array_length()):
                if index != 0:
                    self._append_unit(44)
                self._write_line_indent(depth + 1)
                if not self.write_property(
                    number_to_string(Float64(index)),
                    value.array_at(index),
                    depth + 1,
                ):
                    self._append_ascii("null")
            if value.array_length() != 0:
                self._write_line_indent(depth)
            self._append_unit(93)
        else:
            self._append_unit(123)
            var first = True
            for index in _object_key_order(value):
                var child = value.object_value(index)
                var key = value.object_key(index)
                var selected = child
                var projected = selected.is_json_projection()
                if projected:
                    self._enter(selected)
                    selected = selected._project_json(key.to_native_strict())
                if self._replacer:
                    selected = self._replacer.value().call(
                        (key.to_native_strict(), selected)
                    )
                if selected.is_undefined() or selected.is_symbol():
                    if projected:
                        _ = self._active.pop()
                    continue
                if not first:
                    self._append_unit(44)
                self._write_line_indent(depth + 1)
                first = False
                self._write_string(key)
                self._append_unit(58)
                if len(self._indent) != 0:
                    self._append_unit(32)
                _ = self._write_value(selected, depth + 1)
                if projected:
                    _ = self._active.pop()
            if not first:
                self._write_line_indent(depth)
            self._append_unit(125)
        _ = self._active.pop()
        return True

    def _enter(mut self, value: JsValue) raises:
        for active in self._active:
            if active.same_identity(value):
                raise Error("cyclic JavaScript value cannot be serialized")
        self._active.append(value)

    def _write_line_indent(mut self, depth: Int) raises:
        if len(self._indent) == 0:
            return
        self._append_unit(10)
        var indent = self._indent
        for _ in range(depth):
            self._append_string(indent)

    def _write_string(mut self, value: JsString) raises:
        self._append_unit(34)
        var index = 0
        while index < len(value):
            var unit = value.code_unit_at(index).value()
            if unit == 34 or unit == 92:
                self._append_unit(92)
                self._append_unit(unit)
            elif unit == 8:
                self._append_ascii("\\b")
            elif unit == 9:
                self._append_ascii("\\t")
            elif unit == 10:
                self._append_ascii("\\n")
            elif unit == 12:
                self._append_ascii("\\f")
            elif unit == 13:
                self._append_ascii("\\r")
            elif unit < 32:
                self._append_unicode_escape(unit)
            elif unit >= 0xD800 and unit <= 0xDBFF:
                if index + 1 < len(value):
                    var second = value.code_unit_at(index + 1).value()
                    if second >= 0xDC00 and second <= 0xDFFF:
                        self._append_unit(unit)
                        self._append_unit(second)
                        index += 1
                    else:
                        self._append_unicode_escape(unit)
                else:
                    self._append_unicode_escape(unit)
            elif unit >= 0xDC00 and unit <= 0xDFFF:
                self._append_unicode_escape(unit)
            else:
                self._append_unit(unit)
            index += 1
        self._append_unit(34)

    def _append_unicode_escape(mut self, unit: UInt16) raises:
        self._append_ascii("\\u")
        self._append_unit(_hex_unit(UInt32(unit) >> 12))
        self._append_unit(_hex_unit((UInt32(unit) >> 8) & 15))
        self._append_unit(_hex_unit((UInt32(unit) >> 4) & 15))
        self._append_unit(_hex_unit(UInt32(unit) & 15))

    def _append_string(mut self, value: JsString) raises:
        for index in range(len(value)):
            self._append_unit(value.code_unit_at(index).value())

    def _append_ascii(mut self, value: StringLiteral) raises:
        for byte in value.as_bytes():
            self._append_unit(UInt16(byte))

    def _append_unit(mut self, unit: UInt16) raises:
        if len(self._units[]) >= _MAX_JSON_OUTPUT_UNITS:
            raise Error("JSON output exceeds its source budget")
        self._units[].append(unit)


def _number_indent(space: Float64) -> JsString:
    var count = 0
    if space == space and space > 0:
        count = 10 if space >= 10 else Int(space)
    var units = List[UInt16](capacity=count)
    for _ in range(count):
        units.append(32)
    return JsString(code_units=units^)


def _string_indent(space: JsString) -> JsString:
    var count = min(len(space), 10)
    var units = List[UInt16](capacity=count)
    for index in range(count):
        units.append(space.code_unit_at(index).value())
    return JsString(code_units=units^)


def _is_digit(unit: UInt16) -> Bool:
    return unit >= 48 and unit <= 57


def _hex_digit(unit: UInt16) -> Int:
    if unit >= 48 and unit <= 57:
        return Int(unit - 48)
    if unit >= 65 and unit <= 70:
        return Int(unit - 65) + 10
    if unit >= 97 and unit <= 102:
        return Int(unit - 97) + 10
    return -1


def _hex_unit(value: UInt32) -> UInt16:
    return UInt16(value + 48) if value < 10 else UInt16(value + 87)
