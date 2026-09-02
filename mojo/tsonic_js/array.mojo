from std.collections import List
from std.builtin.rebind import downcast, rebind_var
from std.memory import ArcPointer

from .string import JsString
from .equality import same_value_zero


struct JsArray[T: AnyType](ImplicitlyCopyable, Sized):
    comptime Storage = downcast[
        List[Optional[Self.T]], Movable & Deinitable
    ]
    var _elements: ArcPointer[Self.Storage]

    def __init__(out self) where conforms_to(
        Self.T, Copyable & Deinitable
    ):
        var elements = rebind_var[Self.Storage](List[Optional[Self.T]]())
        self._elements = ArcPointer(elements^)

    def __init__(out self, var values: List[Self.T]) where conforms_to(
        Self.T, Copyable & Deinitable
    ):
        var elements = List[Optional[Self.T]](capacity=len(values))
        for value in values^:
            elements.append(Optional[Self.T](value.copy()))
        var storage = rebind_var[Self.Storage](elements^)
        self._elements = ArcPointer(storage^)

    def __len__(self) -> Int:
        return len(self._elements[])

    def js_length(self) -> Float64:
        return Float64(len(self))

    def push(mut self, *values: Self.T) -> Float64 where conforms_to(
        Self.T, Copyable & Deinitable
    ):
        for value in values:
            self._elements[].append(Optional[Self.T](value.copy()))
        return self.js_length()

    def get(self, index: Int) -> Optional[Self.T] where conforms_to(
        Self.T, Copyable & Deinitable
    ):
        if index < 0 or index >= len(self):
            return None
        return self._elements[][index].copy()

    def get_index(self, index: Float64) -> Optional[Self.T] where conforms_to(
        Self.T, Copyable & Deinitable
    ):
        return self.get(_array_index(index))

    def __getitem__(self, index: Float64) raises -> Self.T where conforms_to(
        Self.T, Copyable & Deinitable
    ):
        var value = self.get(_array_index(index))
        if not value:
            raise Error("JavaScript array index is absent")
        return value.value().copy()

    def set(mut self, index: Int, var value: Self.T) where conforms_to(
        Self.T, Copyable & Deinitable
    ):
        if index < 0:
            return
        while len(self) <= index:
            self._elements[].append(Optional[Self.T]())
        self._elements[][index] = Optional[Self.T](value^)

    def __setitem__(
        mut self, index: Float64, var value: Self.T
    ) where conforms_to(Self.T, Copyable & Deinitable):
        self.set(_array_index(index), value^)

    def pop(mut self) -> Optional[Self.T] where conforms_to(
        Self.T, Copyable & Deinitable
    ):
        if len(self) == 0:
            return None
        return self._elements[].pop()

    def shift(mut self) -> Optional[Self.T] where conforms_to(
        Self.T, Copyable & Deinitable
    ):
        if len(self) == 0:
            return None
        var first = self._elements[][0].copy()
        var next = List[Optional[Self.T]](capacity=len(self) - 1)
        for index in range(1, len(self)):
            next.append(self._elements[][index].copy())
        self._elements[] = rebind_var[Self.Storage](next^)
        return first^

    def unshift(mut self, *values: Self.T) -> Float64 where conforms_to(
        Self.T, Copyable & Deinitable
    ):
        var next = List[Optional[Self.T]](capacity=len(self) + len(values))
        for value in values:
            next.append(Optional[Self.T](value.copy()))
        for value in self._elements[]:
            next.append(value.copy())
        self._elements[] = rebind_var[Self.Storage](next^)
        return self.js_length()

    def reverse(mut self) -> Self where conforms_to(
        Self.T, Copyable & Deinitable
    ):
        self._elements[].reverse()
        return self

    def copy_within(
        mut self,
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
        mut self,
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
        mut self,
        start: Float64,
        delete_count: Float64 = Float64(FloatLiteral.infinity),
        *items: Self.T,
    ) -> Self where conforms_to(Self.T, Copyable & Deinitable):
        var first = _relative_start(start, len(self))
        var removed_count = len(self) - first if delete_count == Float64(
            FloatLiteral.infinity
        ) else min(max(Int(delete_count), 0), len(self) - first)
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

    def at(self, index: Float64) -> Optional[Self.T] where conforms_to(
        Self.T, Copyable & Deinitable
    ):
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
        return False

    def index_of(
        self, value: Self.T, from_index: Float64 = 0
    ) -> Float64 where conforms_to(
        Self.T, Copyable & Deinitable & Equatable
    ):
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
    ) -> Float64 where conforms_to(
        Self.T, Copyable & Deinitable & Equatable
    ):
        var index = len(self) - 1 if from_index == Float64(
            FloatLiteral.infinity
        ) else min(Int(from_index), len(self) - 1)
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
    ) -> JsString where conforms_to(
        Self.T, Copyable & Deinitable & Writable
    ):
        var result = JsString()
        for index in range(len(self)):
            if index != 0:
                result += separator
            var value = self._elements[][index].copy()
            if value:
                result += JsString(String(value.value()))
        return result

    def sort(mut self) -> Self where conforms_to(
        Self.T, Copyable & Deinitable & Writable
    ):
        var defined = List[Self.T]()
        var holes = 0
        for current in self._elements[]:
            if current:
                defined.append(current.value().copy())
            else:
                holes += 1
        for index in range(1, len(defined)):
            var value = defined[index].copy()
            var value_text = String(value)
            var position = index
            while position > 0 and String(defined[position - 1]) > value_text:
                defined[position] = defined[position - 1].copy()
                position -= 1
            defined[position] = value^
        var sorted = List[Optional[Self.T]](capacity=len(self))
        for value in defined:
            sorted.append(Optional[Self.T](value.copy()))
        for _ in range(holes):
            sorted.append(None)
        self._elements[] = rebind_var[Self.Storage](sorted^)
        return self

    def delete(mut self, index: Int) -> Bool where conforms_to(
        Self.T, Copyable & Deinitable
    ):
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

    def iter_values(self) -> List[Self.T] where conforms_to(
        Self.T, Copyable & Deinitable
    ):
        var result = List[Self.T]()
        for current in self._elements[]:
            if current:
                result.append(current.value())
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
    if value != value or value < 0:
        return -1
    return Int(value)


def _relative_index(value: Float64, length: Int) -> Int:
    var integer = Int(value)
    return integer if integer >= 0 else length + integer


def _relative_start(value: Float64, length: Int) -> Int:
    var integer = Int(value)
    if integer < 0:
        return max(length + integer, 0)
    return min(integer, length)
