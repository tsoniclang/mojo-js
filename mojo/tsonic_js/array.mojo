from std.collections import List
from std.memory import ArcPointer

from .string import JsString


struct JsArray[T: Copyable & Deinitable](ImplicitlyCopyable, Sized):
    var _elements: ArcPointer[List[Optional[Self.T]]]

    def __init__(out self):
        self._elements = ArcPointer(List[Optional[Self.T]]())

    def __init__(out self, var values: List[Self.T]):
        var elements = List[Optional[Self.T]](capacity=len(values))
        for value in values^:
            elements.append(Optional[Self.T](value.copy()))
        self._elements = ArcPointer(elements^)

    def __len__(self) -> Int:
        return len(self._elements[])

    def js_length(self) -> Float64:
        return Float64(len(self))

    def push(mut self, *values: Self.T) -> Float64:
        for value in values:
            self._elements[].append(Optional[Self.T](value.copy()))
        return self.js_length()

    def get(self, index: Int) -> Optional[Self.T]:
        if index < 0 or index >= len(self):
            return None
        return self._elements[][index].copy()

    def __getitem__(self, index: Float64) raises -> Self.T:
        var value = self.get(_array_index(index))
        if not value:
            raise Error("JavaScript array index is absent")
        return value.value()

    def set(mut self, index: Int, var value: Self.T):
        if index < 0:
            return
        while len(self) <= index:
            self._elements[].append(Optional[Self.T]())
        self._elements[][index] = Optional[Self.T](value^)

    def __setitem__(mut self, index: Float64, var value: Self.T):
        self.set(_array_index(index), value^)

    def pop(mut self) -> Optional[Self.T]:
        if len(self) == 0:
            return None
        return self._elements[].pop()

    def shift(mut self) -> Optional[Self.T]:
        if len(self) == 0:
            return None
        var first = self._elements[][0].copy()
        var next = List[Optional[Self.T]](capacity=len(self) - 1)
        for index in range(1, len(self)):
            next.append(self._elements[][index].copy())
        self._elements[] = next^
        return first

    def unshift(mut self, *values: Self.T) -> Float64:
        var next = List[Optional[Self.T]](capacity=len(self) + len(values))
        for value in values:
            next.append(Optional[Self.T](value.copy()))
        for value in self._elements[]:
            next.append(value.copy())
        self._elements[] = next^
        return self.js_length()

    def reverse(mut self) -> Self:
        self._elements[].reverse()
        return self

    def at(self, index: Float64) -> Optional[Self.T]:
        var normalized = _relative_index(index, len(self))
        return self.get(normalized)

    def includes(self, value: Self.T, from_index: Float64 = 0) -> Bool where Self.T: Equatable:
        var start = _relative_start(from_index, len(self))
        for index in range(start, len(self)):
            var current = self._elements[][index]
            if current and current.value() == value:
                return True
        return False

    def index_of(self, value: Self.T, from_index: Float64 = 0) -> Float64 where Self.T: Equatable:
        var start = _relative_start(from_index, len(self))
        for index in range(start, len(self)):
            var current = self._elements[][index]
            if current and current.value() == value:
                return Float64(index)
        return -1

    def last_index_of(self, value: Self.T, from_index: Float64 = Float64(FloatLiteral.infinity)) -> Float64 where Self.T: Equatable:
        var index = len(self) - 1 if from_index == Float64(FloatLiteral.infinity) else min(Int(from_index), len(self) - 1)
        while index >= 0:
            var current = self._elements[][index]
            if current and current.value() == value:
                return Float64(index)
            index -= 1
        return -1

    def slice(self, start: Float64 = 0, end: Float64 = Float64(FloatLiteral.infinity)) -> Self:
        var first = _relative_start(start, len(self))
        var last = len(self) if end == Float64(FloatLiteral.infinity) else _relative_start(end, len(self))
        if last < first:
            last = first
        var values = List[Optional[Self.T]](capacity=last - first)
        for index in range(first, last):
            values.append(self._elements[][index].copy())
        return Self(elements=values^)

    def join(self, separator: JsString = JsString(",")) raises -> JsString where Self.T: Writable:
        var result = String()
        for index in range(len(self)):
            if index != 0:
                result += separator.to_native_strict()
            var value = self._elements[][index]
            if value:
                result += String(value.value())
        return JsString(result^)

    def delete(mut self, index: Int) -> Bool:
        if index < 0 or index >= len(self):
            return True
        self._elements[][index] = None
        return True

    def has(self, index: Int) -> Bool:
        return (
            index >= 0 and index < len(self) and Bool(self._elements[][index])
        )

    def same_storage(self, other: Self) -> Bool:
        return self._elements is other._elements

    def __init__(out self, *, var elements: List[Optional[Self.T]]):
        self._elements = ArcPointer(elements^)


fn _array_index(value: Float64) -> Int:
    if value != value or value < 0:
        return -1
    return Int(value)


fn _relative_index(value: Float64, length: Int) -> Int:
    var integer = Int(value)
    return integer if integer >= 0 else length + integer


fn _relative_start(value: Float64, length: Int) -> Int:
    var integer = Int(value)
    if integer < 0:
        return max(length + integer, 0)
    return min(integer, length)
