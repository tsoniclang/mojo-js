from .collection_storage import CollectionStorage
from .equality import canonical_collection_key, same_value_zero
from .iterator import JsIterator


struct JsSet[T: AnyType](Equatable, ImplicitlyCopyable, Sized):
    var _values: CollectionStorage[Self.T]

    def __init__(out self) where conforms_to(Self.T, Copyable & Deinitable):
        self._values = CollectionStorage[Self.T]()

    def __len__(self) -> Int:
        return len(self._values)

    def __eq__(self, other: Self) -> Bool:
        return self._values == other._values

    def js_size(self) -> Float64:
        return Float64(len(self))

    def has(
        self, value: Self.T
    ) -> Bool where conforms_to(Self.T, Copyable & Deinitable & Equatable):
        return self._find(value) >= 0

    def add(
        self, var value: Self.T
    ) -> Self where conforms_to(Self.T, Copyable & Deinitable & Equatable):
        if not self.has(value):
            self._values.append(canonical_collection_key(value))
        return self

    def delete(
        self, value: Self.T
    ) -> Bool where conforms_to(Self.T, Copyable & Deinitable & Equatable):
        var index = self._find(value)
        if index < 0:
            return False
        self._values.delete_at(index)
        return True

    def clear(self) where conforms_to(Self.T, Copyable & Deinitable):
        self._values.clear()

    def keys(
        self,
    ) -> JsIterator[Self.T] where conforms_to(Self.T, Copyable & Deinitable):
        return self.values()

    def values(
        self,
    ) -> JsIterator[Self.T] where conforms_to(Self.T, Copyable & Deinitable):
        return self._values.iterator[Self.T, _set_value[Self.T]]()

    def iter_values(
        self,
    ) -> JsIterator[Self.T] where conforms_to(Self.T, Copyable & Deinitable):
        return self.values()

    def entries(
        self,
    ) -> JsIterator[Tuple[Self.T, Self.T]] where conforms_to(
        Self.T, Copyable & Deinitable
    ):
        return self._values.iterator[
            Tuple[Self.T, Self.T], _set_entry[Self.T]
        ]()

    def union(
        self, other: Self
    ) -> Self where conforms_to(Self.T, Copyable & Deinitable & Equatable):
        var result = Self()
        for value in self.values():
            _ = result.add(value.copy())
        for value in other.values():
            _ = result.add(value.copy())
        return result

    def intersection(
        self, other: Self
    ) -> Self where conforms_to(Self.T, Copyable & Deinitable & Equatable):
        var result = Self()
        if len(self) <= len(other):
            for value in self.values():
                if other.has(value):
                    _ = result.add(value.copy())
        else:
            for value in other.values():
                if self.has(value):
                    _ = result.add(value.copy())
        return result

    def difference(
        self, other: Self
    ) -> Self where conforms_to(Self.T, Copyable & Deinitable & Equatable):
        var result = Self()
        for value in self.values():
            if not other.has(value):
                _ = result.add(value.copy())
        return result

    def symmetric_difference(
        self, other: Self
    ) -> Self where conforms_to(Self.T, Copyable & Deinitable & Equatable):
        return self.difference(other).union(other.difference(self))

    def is_subset_of(
        self, other: Self
    ) -> Bool where conforms_to(Self.T, Copyable & Deinitable & Equatable):
        if len(self) > len(other):
            return False
        for value in self.values():
            if not other.has(value):
                return False
        return True

    def is_superset_of(
        self, other: Self
    ) -> Bool where conforms_to(Self.T, Copyable & Deinitable & Equatable):
        return other.is_subset_of(self)

    def is_disjoint_from(
        self, other: Self
    ) -> Bool where conforms_to(Self.T, Copyable & Deinitable & Equatable):
        if len(self) <= len(other):
            for value in self.values():
                if other.has(value):
                    return False
        else:
            for value in other.values():
                if self.has(value):
                    return False
        return True

    def _find(
        self, value: Self.T
    ) -> Int where conforms_to(Self.T, Copyable & Deinitable & Equatable):
        return self._values.find[Self.T, same_value_zero[Self.T]](value)


def _set_value[T: Copyable & Deinitable](value: T) -> T:
    return value.copy()


def _set_entry[T: Copyable & Deinitable](value: T) -> Tuple[T, T]:
    return (value.copy(), value.copy())
