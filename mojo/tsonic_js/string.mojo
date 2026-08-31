from std.collections import List
from std.collections.string import Codepoint
from std.memory import ArcPointer


struct JsString(Equatable, ImplicitlyCopyable, Sized):
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

    def __len__(self) -> Int:
        return len(self._code_units[])

    def __eq__(self, other: Self) -> Bool:
        return self._code_units[] == other._code_units[]

    def code_unit_at(self, index: Int) -> Optional[UInt16]:
        if index < 0 or index >= len(self):
            return None
        return self._code_units[][index]

    def char_at(self, index: Int) -> Self:
        var unit = self.code_unit_at(index)
        if not unit:
            return Self()
        var units = List[UInt16]()
        units.append(unit.value())
        return Self(code_units=units^)

    def concat(self, other: Self) -> Self:
        var units = self._code_units[].copy()
        for unit in other._code_units[]:
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
