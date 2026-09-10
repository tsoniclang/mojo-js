from std.collections import List
from std.collections.string import Codepoint
from ..string import JsString
from ..value import JsValue, _JsValueBuilder
from .limits import _MAX_JSON_INPUT_UNITS, _MAX_JSON_DEPTH
from .characters import _is_digit, _hex_digit


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
            self._consume_literal([116, 114, 117, 101])
            return self._builder.append_bool(True)
        if unit == 102:
            self._consume_literal([102, 97, 108, 115, 101])
            return self._builder.append_bool(False)
        if unit == 110:
            self._consume_literal([110, 117, 108, 108])
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

    def _consume_literal(mut self, units: List[UInt16]) raises:
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
