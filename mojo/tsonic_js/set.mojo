from std.collections import List
from std.memory import ArcPointer

from .array import JsArray
from .equality import same_value_zero


struct JsSet[T: Copyable & Deinitable & Equatable](ImplicitlyCopyable, Sized):
    var _values: ArcPointer[List[Self.T]]

    def __init__(out self):
        self._values = ArcPointer(List[Self.T]())

    def __len__(self) -> Int:
        return len(self._values[])

    def js_size(self) -> Float64:
        return Float64(len(self))

    def has(self, value: Self.T) -> Bool:
        return self._find(value) >= 0

    def add(mut self, var value: Self.T) -> Self:
        if not self.has(value):
            self._values[].append(value^)
        return self

    def delete(mut self, value: Self.T) -> Bool:
        var index = self._find(value)
        if index < 0:
            return False
        var next = List[Self.T](capacity=len(self) - 1)
        for current in range(len(self)):
            if current != index:
                next.append(self._values[][current].copy())
        self._values[] = next^
        return True

    def clear(mut self):
        self._values[].clear()

    def keys(self) -> JsArray[Self.T]:
        return JsArray[Self.T](self._values[].copy())

    def values(self) -> JsArray[Self.T]:
        return self.keys()

    def iter_values(self) -> List[Self.T]:
        return self._values[].copy()

    def entries(self) -> JsArray[Tuple[Self.T, Self.T]]:
        var result = List[Tuple[Self.T, Self.T]](capacity=len(self))
        for value in self._values[]:
            result.append((value.copy(), value.copy()))
        return JsArray[Tuple[Self.T, Self.T]](result^)

    def for_each(self, callback: def(Self.T, Self.T, Self) capturing):
        for value in self._values[]:
            callback(value.copy(), value.copy(), self)

    def union(self, other: Self) -> Self:
        var result = Self()
        for value in self._values[]:
            _ = result.add(value.copy())
        for value in other._values[]:
            _ = result.add(value.copy())
        return result

    def intersection(self, other: Self) -> Self:
        var result = Self()
        for value in self._values[]:
            if other.has(value):
                _ = result.add(value.copy())
        return result

    def difference(self, other: Self) -> Self:
        var result = Self()
        for value in self._values[]:
            if not other.has(value):
                _ = result.add(value.copy())
        return result

    def symmetric_difference(self, other: Self) -> Self:
        return self.difference(other).union(other.difference(self))

    def is_subset_of(self, other: Self) -> Bool:
        for value in self._values[]:
            if not other.has(value):
                return False
        return True

    def is_superset_of(self, other: Self) -> Bool:
        return other.is_subset_of(self)

    def is_disjoint_from(self, other: Self) -> Bool:
        for value in self._values[]:
            if other.has(value):
                return False
        return True

    def _find(self, value: Self.T) -> Int:
        for index in range(len(self)):
            if same_value_zero(self._values[][index], value):
                return index
        return -1
