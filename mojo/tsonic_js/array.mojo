from std.collections import List
from std.builtin.rebind import downcast, rebind_var
from std.memory import ArcPointer

from .string import JsString
from .equality import same_value_zero
from .array_values import (
    array_present_value,
    array_value_is_nullish,
    array_value_is_undefined,
    array_value_string,
)


struct JsArray[T: AnyType](Equatable, ImplicitlyCopyable, Sized):
    comptime Storage = downcast[List[Optional[Self.T]], Movable & Deinitable]
    var _elements: ArcPointer[Self.Storage]

    def __init__(out self) where conforms_to(Self.T, Copyable & Deinitable):
        var elements = rebind_var[Self.Storage](List[Optional[Self.T]]())
        self._elements = ArcPointer(elements^)

    def __init__(
        out self, var values: List[Self.T]
    ) where conforms_to(Self.T, Copyable & Deinitable):
        var elements = List[Optional[Self.T]](capacity=len(values))
        for value in values^:
            elements.append(Optional[Self.T](value.copy()))
        var storage = rebind_var[Self.Storage](elements^)
        self._elements = ArcPointer(storage^)

    def __len__(self) -> Int:
        return len(self._elements[])

    def __eq__(self, other: Self) -> Bool:
        return self._elements is other._elements

    def js_length(self) -> Float64:
        return Float64(len(self))

    def push(
        self, values: List[Self.T]
    ) -> Float64 where conforms_to(Self.T, Copyable & Deinitable):
        for value in values:
            self._elements[].append(Optional[Self.T](value.copy()))
        return self.js_length()

    def get(
        self, index: Int
    ) -> Optional[Self.T] where conforms_to(Self.T, Copyable & Deinitable):
        if index < 0 or index >= len(self):
            return None
        return self._elements[][index].copy()

    def get_index(
        self, index: Float64
    ) -> Optional[Self.T] where conforms_to(Self.T, Copyable & Deinitable):
        return self.get(_array_index(index))

    def __getitem__(
        self, index: Float64
    ) raises -> Self.T where conforms_to(Self.T, Copyable & Deinitable):
        return array_present_value(self.get(_array_index(index)))

    def read_value(
        self, index: Int
    ) raises -> Self.T where conforms_to(Self.T, Copyable & Deinitable):
        return array_present_value(self.get(index))

    def set(
        self, index: Int, var value: Self.T
    ) where conforms_to(Self.T, Copyable & Deinitable):
        if index < 0:
            return
        while len(self) <= index:
            self._elements[].append(Optional[Self.T]())
        self._elements[][index] = Optional[Self.T](value^)

    def __setitem__(
        self, index: Float64, var value: Self.T
    ) where conforms_to(Self.T, Copyable & Deinitable):
        self.set(_array_index(index), value^)

    def pop(
        self,
    ) -> Optional[Self.T] where conforms_to(Self.T, Copyable & Deinitable):
        if len(self) == 0:
            return None
        return self._elements[].pop()

    def shift(
        self,
    ) -> Optional[Self.T] where conforms_to(Self.T, Copyable & Deinitable):
        if len(self) == 0:
            return None
        var first = self._elements[][0].copy()
        var next = List[Optional[Self.T]](capacity=len(self) - 1)
        for index in range(1, len(self)):
            next.append(self._elements[][index].copy())
        self._elements[] = rebind_var[Self.Storage](next^)
        return first^

    def unshift(
        self, values: List[Self.T]
    ) -> Float64 where conforms_to(Self.T, Copyable & Deinitable):
        var next = List[Optional[Self.T]](capacity=len(self) + len(values))
        for value in values:
            next.append(Optional[Self.T](value.copy()))
        for value in self._elements[]:
            next.append(value.copy())
        self._elements[] = rebind_var[Self.Storage](next^)
        return self.js_length()

    def reverse(
        self,
    ) -> Self where conforms_to(Self.T, Copyable & Deinitable):
        self._elements[].reverse()
        return self

    def copy_within(
        self,
        target: Float64,
        start: Float64,
        end: Float64 = Float64(FloatLiteral.infinity),
    ) -> Self where conforms_to(Self.T, Copyable & Deinitable):
        var destination = _relative_start(target, len(self))
        var first = _relative_start(start, len(self))
        var last = len(self) if end == Float64(
            FloatLiteral.infinity
        ) else _relative_start(end, len(self))
        var count = min(max(last - first, 0), len(self) - destination)
        var copied = List[Optional[Self.T]](capacity=count)
        for offset in range(count):
            copied.append(self._elements[][first + offset].copy())
        for offset in range(count):
            self._elements[][destination + offset] = copied[offset].copy()
        return self

    def fill(
        self,
        value: Self.T,
        start: Float64 = 0,
        end: Float64 = Float64(FloatLiteral.infinity),
    ) -> Self where conforms_to(Self.T, Copyable & Deinitable):
        var first = _relative_start(start, len(self))
        var last = len(self) if end == Float64(
            FloatLiteral.infinity
        ) else _relative_start(end, len(self))
        for index in range(first, last):
            self._elements[][index] = Optional[Self.T](value.copy())
        return self

    def splice(
        self,
        start: Float64,
        delete_count: Float64 = Float64(FloatLiteral.infinity),
        *,
        items: List[Self.T],
    ) -> Self where conforms_to(Self.T, Copyable & Deinitable):
        var first = _relative_start(start, len(self))
        var removed_count = _delete_count(delete_count, len(self) - first)
        var removed = List[Optional[Self.T]](capacity=removed_count)
        for index in range(first, first + removed_count):
            removed.append(self._elements[][index].copy())
        var next = List[Optional[Self.T]](
            capacity=len(self) - removed_count + len(items)
        )
        for index in range(first):
            next.append(self._elements[][index].copy())
        for item in items:
            next.append(Optional[Self.T](item.copy()))
        for index in range(first + removed_count, len(self)):
            next.append(self._elements[][index].copy())
        self._elements[] = rebind_var[Self.Storage](next^)
        return Self(elements=removed^)

    def at(
        self, index: Float64
    ) -> Optional[Self.T] where conforms_to(Self.T, Copyable & Deinitable):
        var normalized = _relative_index(index, len(self))
        return self.get(normalized)

    def includes(
        self, value: Self.T, from_index: Float64 = 0
    ) -> Bool where conforms_to(Self.T, Copyable & Deinitable & Equatable):
        var start = _relative_start(from_index, len(self))
        for index in range(start, len(self)):
            var current = self._elements[][index].copy()
            if current and same_value_zero(current.value(), value):
                return True
            if not current and array_value_is_undefined(value):
                return True
        return False

    def index_of(
        self, value: Self.T, from_index: Float64 = 0
    ) -> Float64 where conforms_to(Self.T, Copyable & Deinitable & Equatable):
        var start = _relative_start(from_index, len(self))
        for index in range(start, len(self)):
            var current = self._elements[][index].copy()
            if current and current.value() == value:
                return Float64(index)
        return -1

    def last_index_of(
        self,
        value: Self.T,
        from_index: Float64 = Float64(FloatLiteral.infinity),
    ) -> Float64 where conforms_to(Self.T, Copyable & Deinitable & Equatable):
        var index = _backward_start(from_index, len(self))
        while index >= 0:
            var current = self._elements[][index].copy()
            if current and current.value() == value:
                return Float64(index)
            index -= 1
        return -1

    def slice(
        self, start: Float64 = 0, end: Float64 = Float64(FloatLiteral.infinity)
    ) -> Self where conforms_to(Self.T, Copyable & Deinitable):
        var first = _relative_start(start, len(self))
        var last = len(self) if end == Float64(
            FloatLiteral.infinity
        ) else _relative_start(end, len(self))
        if last < first:
            last = first
        var values = List[Optional[Self.T]](capacity=last - first)
        for index in range(first, last):
            values.append(self._elements[][index].copy())
        return Self(elements=values^)

    def join(
        self, separator: JsString = JsString(",")
    ) raises -> JsString where conforms_to(
        Self.T, Copyable & Deinitable & Writable
    ):
        var result = JsString()
        for index in range(len(self)):
            if index != 0:
                result += separator
            var value = self._elements[][index].copy()
            if value and not array_value_is_nullish(value.value()):
                result += array_value_string(value.value())
        return result

    def sort(
        self,
    ) raises -> Self where conforms_to(
        Self.T, Copyable & Deinitable & Writable
    ):
        var defined = List[Self.T]()
        var undefined = List[Self.T]()
        var holes = 0
        for current in self._elements[]:
            if current:
                if array_value_is_undefined(current.value()):
                    undefined.append(current.value().copy())
                else:
                    defined.append(current.value().copy())
            else:
                holes += 1
        for index in range(1, len(defined)):
            var value = defined[index].copy()
            var value_text = array_value_string(value)
            var position = index
            while position > 0 and value_text < array_value_string(
                defined[position - 1]
            ):
                defined[position] = defined[position - 1].copy()
                position -= 1
            defined[position] = value^
        var sorted = List[Optional[Self.T]](capacity=len(self))
        for value in defined:
            sorted.append(Optional[Self.T](value.copy()))
        for value in undefined:
            sorted.append(Optional[Self.T](value.copy()))
        for _ in range(holes):
            sorted.append(None)
        self._elements[] = rebind_var[Self.Storage](sorted^)
        return self

    def delete(
        self, index: Float64
    ) -> Bool where conforms_to(Self.T, Copyable & Deinitable):
        var position = _array_index(index)
        if position < 0 or position >= len(self):
            return True
        self._elements[][position] = None
        return True

    def has(self, index: Int) -> Bool:
        return (
            index >= 0 and index < len(self) and Bool(self._elements[][index])
        )

    def same_storage(self, other: Self) -> Bool:
        return self._elements is other._elements

    def iter_values(
        self,
    ) raises -> List[Self.T] where conforms_to(Self.T, Copyable & Deinitable):
        var result = List[Self.T]()
        for current in self._elements[]:
            result.append(array_present_value(current))
        return result^

    def _first_present_index(self) -> Int:
        for index in range(len(self)):
            if self._elements[][index]:
                return index
        return -1

    def __init__(
        out self, *, var elements: List[Optional[Self.T]]
    ) where conforms_to(Self.T, Copyable & Deinitable):
        var storage = rebind_var[Self.Storage](elements^)
        self._elements = ArcPointer(storage^)


def _array_index(value: Float64) -> Int:
    if value != value or value < 0 or value >= 4294967295:
        return -1
    var index = Int(value)
    return index if Float64(index) == value else -1


def _relative_index(value: Float64, length: Int) -> Int:
    if value != value:
        return 0
    if value >= Float64(length) or value <= -Float64(length) - 1:
        return -1
    var integer = Int(value)
    return integer if integer >= 0 else length + integer


def _relative_start(value: Float64, length: Int) -> Int:
    if value != value:
        return 0
    if value >= Float64(length):
        return length
    if value <= -Float64(length):
        return 0
    var integer = Int(value)
    if integer < 0:
        return max(length + integer, 0)
    return min(integer, length)


def _backward_start(value: Float64, length: Int) -> Int:
    if length == 0 or value <= -Float64(length) - 1:
        return -1
    if value != value:
        return 0
    if value >= Float64(length - 1):
        return length - 1
    var integer = Int(value)
    return integer if integer >= 0 else length + integer


def _delete_count(value: Float64, remaining: Int) -> Int:
    if value != value or value <= 0:
        return 0
    if value >= Float64(remaining):
        return remaining
    return Int(value)
