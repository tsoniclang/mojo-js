from std.collections import List
from std.memory import ArcPointer
from tsonic_runtime import RaisingCallable
from ..number import number_to_string
from ..object import _object_key_order
from ..string import JsString
from ..value import JsValue
from .limits import _MAX_JSON_OUTPUT_UNITS, _MAX_JSON_DEPTH
from .characters import _hex_unit


struct _JsonWriter:
    var _units: ArcPointer[List[UInt16]]
    var _active: List[JsValue]
    var _indent: JsString
    var _property_list: Optional[List[JsString]]
    var _replacer: Optional[
        RaisingCallable[Tuple[String, JsValue], JsValue, Error]
    ]

    def __init__(out self):
        self._units = ArcPointer(List[UInt16]())
        self._active = List[JsValue]()
        self._indent = JsString()
        self._replacer = None
        self._property_list = None

    def __init__(out self, indent: JsString):
        self._units = ArcPointer(List[UInt16]())
        self._active = List[JsValue]()
        self._indent = indent
        self._replacer = None
        self._property_list = None

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
        self._property_list = None

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
        self._property_list = None

    def __init__(out self, var property_list: List[JsString], indent: JsString):
        self = Self(indent)
        self._property_list = Optional[List[JsString]](property_list^)

    def finish(self) -> JsString:
        return JsString(code_unit_storage=self._units)

    def write_property(
        mut self, key: JsString, value: JsValue, depth: Int
    ) raises -> Bool:
        var selected = value
        var projected = selected.has_selected_to_json()
        if projected:
            selected = selected._project_json(key.to_native_strict())
        if self._replacer:
            selected = self._replacer.value().call(
                (key.to_native_strict(), selected)
            )
        var written = self._write_value(selected, depth)
        return written

    def _write_value(mut self, value: JsValue, depth: Int) raises -> Bool:
        if depth > _MAX_JSON_DEPTH:
            raise Error("JSON output exceeds its nesting budget")
        if value.is_undefined() or value.is_symbol():
            return False
        if value.is_null():
            self._append_ascii("null")
            return True
        if value.is_bigint():
            raise Error("Bigint values cannot be serialized as JSON")
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
        if not value.is_array() and not value.is_object():
            return False
        self._enter(value)
        if value.is_array():
            self._append_unit(91)
            var length = value.array_length()
            for index in range(length):
                if index != 0:
                    self._append_unit(44)
                self._write_line_indent(depth + 1)
                if not self.write_property(
                    number_to_string(Float64(index)),
                    value.array_property(index),
                    depth + 1,
                ):
                    self._append_ascii("null")
            if length != 0:
                self._write_line_indent(depth)
            self._append_unit(93)
        else:
            self._append_unit(123)
            var first = True
            var keys = List[JsString]()
            if self._property_list:
                keys = self._property_list.value().copy()
            else:
                for index in _object_key_order(value):
                    keys.append(value.object_key(index))
            for key in keys:
                var child = value.property_get(key)
                var selected = child
                var projected = selected.has_selected_to_json()
                if projected:
                    selected = selected._project_json(key.to_native_strict())
                if self._replacer:
                    selected = self._replacer.value().call(
                        (key.to_native_strict(), selected)
                    )
                if selected.is_undefined() or selected.is_symbol():
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
