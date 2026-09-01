from std.collections import List
from std.collections.string import Codepoint
from std.memory import ArcPointer


struct JsString(Equatable, ImplicitlyCopyable, Sized, Writable):
    var _code_units: ArcPointer[List[UInt16]]

    def __init__(out self):
        self._code_units = ArcPointer(List[UInt16]())

    def __init__(out self, value: String):
        var units = List[UInt16]()
        for codepoint in value.codepoints():
            var scalar = codepoint.to_u32()
            if scalar <= 0xFFFF:
                units.append(UInt16(scalar))
            else:
                scalar -= 0x10000
                units.append(UInt16(0xD800 + (scalar >> 10)))
                units.append(UInt16(0xDC00 + (scalar & 0x3FF)))
        self._code_units = ArcPointer(units^)

    def __init__(out self, value: StringLiteral):
        self = Self(String(value))

    def __init__(out self, *, var code_units: List[UInt16]):
        self._code_units = ArcPointer(code_units^)

    def __init__(
        out self,
        *,
        code_unit_storage: ArcPointer[List[UInt16]],
    ):
        self._code_units = code_unit_storage

    def __len__(self) -> Int:
        return len(self._code_units[])

    def __eq__(self, other: Self) -> Bool:
        return self._code_units[] == other._code_units[]

    def __add__(self, other: Self) -> Self:
        return self.concat(other)

    def write_to(self, mut writer: Some[Writer]):
        writer.write(self.to_native_lossy())

    def js_length(self) -> Float64:
        return Float64(len(self))

    def code_unit_at(self, index: Int) -> Optional[UInt16]:
        if index < 0 or index >= len(self):
            return None
        return self._code_units[][index]

    def char_at(self, index: Float64) -> Self:
        var unit = self.code_unit_at(_string_integer(index))
        if not unit:
            return Self()
        var units = List[UInt16]()
        units.append(unit.value())
        return Self(code_units=units^)

    def at(self, index: Float64) -> Optional[Self]:
        var normalized = _string_integer(index)
        if normalized < 0:
            normalized += len(self)
        if normalized < 0 or normalized >= len(self):
            return None
        return Optional[Self](self.char_at(Float64(normalized)))

    def char_code_at(self, index: Float64) -> Float64:
        var unit = self.code_unit_at(_string_integer(index))
        return Float64(unit.value()) if unit else Float64(FloatLiteral.nan)

    def code_point_at(self, index: Float64) -> Optional[Float64]:
        var position = _string_integer(index)
        var first = self.code_unit_at(position)
        if not first:
            return None
        var first_value = UInt32(first.value())
        if first_value < 0xD800 or first_value > 0xDBFF:
            return Optional[Float64](Float64(first_value))
        var second = self.code_unit_at(position + 1)
        if not second:
            return Optional[Float64](Float64(first_value))
        var second_value = UInt32(second.value())
        if second_value < 0xDC00 or second_value > 0xDFFF:
            return Optional[Float64](Float64(first_value))
        return Optional[Float64](
            Float64(
                UInt32(0x10000)
                + ((first_value - 0xD800) << 10)
                + (second_value - 0xDC00)
            )
        )

    def concat(self, *others: Self) -> Self:
        var units = self._code_units[].copy()
        for other in others:
            for unit in other._code_units[]:
                units.append(unit)
        return Self(code_units=units^)

    def includes(self, value: Self, position: Float64 = 0) -> Bool:
        return self.index_of(value, position) >= 0

    def starts_with(self, value: Self, position: Float64 = 0) -> Bool:
        var start = _clamp_index(_string_integer(position), len(self))
        return self._matches_at(value, start)

    def ends_with(
        self,
        value: Self,
        end_position: Float64 = Float64(FloatLiteral.infinity),
    ) -> Bool:
        var end = len(self) if end_position == Float64(
            FloatLiteral.infinity
        ) else _clamp_index(_string_integer(end_position), len(self))
        return self._matches_at(value, end - len(value))

    def index_of(self, value: Self, position: Float64 = 0) -> Float64:
        var start = _clamp_index(_string_integer(position), len(self))
        if len(value) == 0:
            return Float64(start)
        for index in range(start, len(self) - len(value) + 1):
            if self._matches_at(value, index):
                return Float64(index)
        return -1

    def last_index_of(
        self, value: Self, position: Float64 = Float64(FloatLiteral.infinity)
    ) -> Float64:
        var start = len(self) if position == Float64(
            FloatLiteral.infinity
        ) else _clamp_index(_string_integer(position), len(self))
        if len(value) == 0:
            return Float64(start)
        var index = min(start, len(self) - len(value))
        while index >= 0:
            if self._matches_at(value, index):
                return Float64(index)
            index -= 1
        return -1

    def slice(
        self, start: Float64 = 0, end: Float64 = Float64(FloatLiteral.infinity)
    ) -> Self:
        var first = _relative_string_index(start, len(self))
        var last = len(self) if end == Float64(
            FloatLiteral.infinity
        ) else _relative_string_index(end, len(self))
        if last < first:
            last = first
        return self._range(first, last)

    def substring(
        self, start: Float64, end: Float64 = Float64(FloatLiteral.infinity)
    ) -> Self:
        var first = _clamp_index(_string_integer(start), len(self))
        var last = len(self) if end == Float64(
            FloatLiteral.infinity
        ) else _clamp_index(_string_integer(end), len(self))
        if first > last:
            var swap = first
            first = last
            last = swap
        return self._range(first, last)

    def substr(
        self, start: Float64, length: Float64 = Float64(FloatLiteral.infinity)
    ) -> Self:
        var first = _relative_string_index(start, len(self))
        var count = len(self) - first if length == Float64(
            FloatLiteral.infinity
        ) else max(_string_integer(length), 0)
        return self._range(first, min(first + count, len(self)))

    def trim(self) -> Self:
        var first = 0
        var last = len(self)
        while first < last and _is_js_whitespace(self._code_units[][first]):
            first += 1
        while last > first and _is_js_whitespace(self._code_units[][last - 1]):
            last -= 1
        return self._range(first, last)

    def trim_start(self) -> Self:
        var first = 0
        while first < len(self) and _is_js_whitespace(
            self._code_units[][first]
        ):
            first += 1
        return self._range(first, len(self))

    def trim_end(self) -> Self:
        var last = len(self)
        while last > 0 and _is_js_whitespace(self._code_units[][last - 1]):
            last -= 1
        return self._range(0, last)

    def trim_left(self) -> Self:
        return self.trim_start()

    def trim_right(self) -> Self:
        return self.trim_end()

    def repeat(self, count: Float64) raises -> Self:
        var repetitions = _string_integer(count)
        if repetitions < 0 or count == Float64(FloatLiteral.infinity):
            raise Error("invalid JavaScript string repeat count")
        var units = List[UInt16](capacity=len(self) * repetitions)
        for _ in range(repetitions):
            for unit in self._code_units[]:
                units.append(unit)
        return Self(code_units=units^)

    def replace(self, search: Self, replacement: Self) -> Self:
        var found = Int(self.index_of(search))
        if found < 0:
            return self
        return self._range(0, found).concat(
            _expand_replacement(
                replacement,
                self._range(found, found + len(search)),
                self._range(0, found),
                self._range(found + len(search), len(self)),
            ),
            self._range(found + len(search), len(self)),
        )

    def replace_all(self, search: Self, replacement: Self) raises -> Self:
        if len(search) == 0:
            var result = Self()
            for index in range(len(self) + 1):
                result = result.concat(
                    _expand_replacement(
                        replacement,
                        Self(),
                        self._range(0, index),
                        self._range(index, len(self)),
                    )
                )
                if index < len(self):
                    result = result.concat(self.char_at(Float64(index)))
            return result
        var result = Self()
        var start = 0
        while start <= len(self):
            var found = Int(self.index_of(search, Float64(start)))
            if found < 0:
                result = result.concat(self._range(start, len(self)))
                break
            result = result.concat(
                self._range(start, found),
                _expand_replacement(
                    replacement,
                    search,
                    self._range(0, found),
                    self._range(found + len(search), len(self)),
                ),
            )
            start = found + len(search)
        return result

    def pad_start(self, target_length: Float64, fill: Self = Self(" ")) -> Self:
        return self._pad(target_length, fill, True)

    def pad_end(self, target_length: Float64, fill: Self = Self(" ")) -> Self:
        return self._pad(target_length, fill, False)

    def to_lower_case(self) raises -> Self:
        return Self(self.to_native_strict().lower())

    def to_upper_case(self) raises -> Self:
        return Self(self.to_native_strict().upper())

    def to_string(self) -> Self:
        return self

    def value_of(self) -> Self:
        return self

    def is_well_formed(self) -> Bool:
        var index = 0
        while index < len(self):
            var first = UInt32(self._code_units[][index])
            if first >= 0xD800 and first <= 0xDBFF:
                if index + 1 >= len(self):
                    return False
                var second = UInt32(self._code_units[][index + 1])
                if second < 0xDC00 or second > 0xDFFF:
                    return False
                index += 2
            elif first >= 0xDC00 and first <= 0xDFFF:
                return False
            else:
                index += 1
        return True

    def to_well_formed(self) -> Self:
        var units = List[UInt16]()
        var index = 0
        while index < len(self):
            var first = UInt32(self._code_units[][index])
            if first >= 0xD800 and first <= 0xDBFF:
                if index + 1 < len(self):
                    var second = UInt32(self._code_units[][index + 1])
                    if second >= 0xDC00 and second <= 0xDFFF:
                        units.append(UInt16(first))
                        units.append(UInt16(second))
                        index += 2
                        continue
                units.append(UInt16(0xFFFD))
            elif first >= 0xDC00 and first <= 0xDFFF:
                units.append(UInt16(0xFFFD))
            else:
                units.append(UInt16(first))
            index += 1
        return Self(code_units=units^)

    def iter_values(self) -> List[Self]:
        var result = List[Self]()
        var index = 0
        while index < len(self):
            var width = 1
            var first = UInt32(self._code_units[][index])
            if first >= 0xD800 and first <= 0xDBFF and index + 1 < len(self):
                var second = UInt32(self._code_units[][index + 1])
                if second >= 0xDC00 and second <= 0xDFFF:
                    width = 2
            result.append(self._range(index, index + width))
            index += width
        return result^

    def _matches_at(self, value: Self, start: Int) -> Bool:
        if start < 0 or start + len(value) > len(self):
            return False
        for offset in range(len(value)):
            if (
                self._code_units[][start + offset]
                != value._code_units[][offset]
            ):
                return False
        return True

    def _range(self, start: Int, end: Int) -> Self:
        var units = List[UInt16](capacity=max(end - start, 0))
        for index in range(start, end):
            units.append(self._code_units[][index])
        return Self(code_units=units^)

    def _pad(self, target_length: Float64, fill: Self, at_start: Bool) -> Self:
        var target = max(_string_integer(target_length), 0)
        if target <= len(self) or len(fill) == 0:
            return self
        var needed = target - len(self)
        var padding = List[UInt16](capacity=needed)
        for index in range(needed):
            padding.append(fill._code_units[][index % len(fill)])
        var units = List[UInt16](capacity=target)
        if at_start:
            for unit in padding:
                units.append(unit)
        for unit in self._code_units[]:
            units.append(unit)
        if not at_start:
            for unit in padding:
                units.append(unit)
        return Self(code_units=units^)

    def to_native_strict(self) raises -> String:
        var result = String()
        var index = 0
        while index < len(self):
            var first = UInt32(self._code_units[][index])
            if first >= 0xD800 and first <= 0xDBFF:
                if index + 1 >= len(self):
                    raise Error("unpaired UTF-16 high surrogate")
                var second = UInt32(self._code_units[][index + 1])
                if second < 0xDC00 or second > 0xDFFF:
                    raise Error("unpaired UTF-16 high surrogate")
                var scalar = (
                    UInt32(0x10000)
                    + ((first - 0xD800) << 10)
                    + (second - 0xDC00)
                )
                result.append(Codepoint(unsafe_unchecked_codepoint=scalar))
                index += 2
            elif first >= 0xDC00 and first <= 0xDFFF:
                raise Error("unpaired UTF-16 low surrogate")
            else:
                result.append(Codepoint(unsafe_unchecked_codepoint=first))
                index += 1
        return result^

    def to_native_lossy(self) -> String:
        var result = String()
        var index = 0
        while index < len(self):
            var first = UInt32(self._code_units[][index])
            if first >= 0xD800 and first <= 0xDBFF:
                if index + 1 < len(self):
                    var second = UInt32(self._code_units[][index + 1])
                    if second >= 0xDC00 and second <= 0xDFFF:
                        var scalar = (
                            UInt32(0x10000)
                            + ((first - 0xD800) << 10)
                            + (second - 0xDC00)
                        )
                        result.append(
                            Codepoint(unsafe_unchecked_codepoint=scalar)
                        )
                        index += 2
                        continue
                result.append(Codepoint(unsafe_unchecked_codepoint=0xFFFD))
            elif first >= 0xDC00 and first <= 0xDFFF:
                result.append(Codepoint(unsafe_unchecked_codepoint=0xFFFD))
            else:
                result.append(Codepoint(unsafe_unchecked_codepoint=first))
            index += 1
        return result^


def _string_integer(value: Float64) -> Int:
    if value != value or value == 0:
        return 0
    return Int(value)


def _clamp_index(value: Int, length: Int) -> Int:
    return min(max(value, 0), length)


def _relative_string_index(value: Float64, length: Int) -> Int:
    var integer = _string_integer(value)
    if integer < 0:
        return max(length + integer, 0)
    return min(integer, length)


def _is_js_whitespace(unit: UInt16) -> Bool:
    return (
        unit == 0x0009
        or unit == 0x000A
        or unit == 0x000B
        or unit == 0x000C
        or unit == 0x000D
        or unit == 0x0020
        or unit == 0x00A0
        or unit == 0x1680
        or unit == 0x2000
        or unit == 0x2001
        or unit == 0x2002
        or unit == 0x2003
        or unit == 0x2004
        or unit == 0x2005
        or unit == 0x2006
        or unit == 0x2007
        or unit == 0x2008
        or unit == 0x2009
        or unit == 0x200A
        or unit == 0x2028
        or unit == 0x2029
        or unit == 0x202F
        or unit == 0x205F
        or unit == 0x3000
        or unit == 0xFEFF
    )


def string_from_char_code(*codes: Float64) -> JsString:
    var units = List[UInt16](capacity=len(codes))
    for code in codes:
        units.append(UInt16(UInt32(Int64(code)) & 0xFFFF))
    return JsString(code_units=units^)


def string_from_code_point(*codes: Float64) raises -> JsString:
    var units = List[UInt16]()
    for code in codes:
        var scalar = Int64(code)
        if code != Float64(scalar) or scalar < 0 or scalar > 0x10FFFF:
            raise Error("invalid JavaScript Unicode code point")
        if scalar <= 0xFFFF:
            units.append(UInt16(scalar))
        else:
            scalar -= 0x10000
            units.append(UInt16(0xD800 + (scalar >> 10)))
            units.append(UInt16(0xDC00 + (scalar & 0x3FF)))
    return JsString(code_units=units^)


def _expand_replacement(
    replacement: JsString,
    matched: JsString,
    prefix: JsString,
    suffix: JsString,
) -> JsString:
    var result = JsString()
    var index = 0
    while index < len(replacement):
        if replacement.code_unit_at(index).value() != 0x24 or index + 1 >= len(
            replacement
        ):
            result = result.concat(replacement.char_at(Float64(index)))
            index += 1
            continue
        var marker = replacement.code_unit_at(index + 1).value()
        if marker == 0x24:
            result = result.concat(JsString("$"))
        elif marker == 0x26:
            result = result.concat(matched)
        elif marker == 0x60:
            result = result.concat(prefix)
        elif marker == 0x27:
            result = result.concat(suffix)
        else:
            result = result.concat(
                JsString("$"), replacement.char_at(Float64(index + 1))
            )
        index += 2
    return result
