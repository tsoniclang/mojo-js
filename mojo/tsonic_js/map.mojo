from .collection_storage import CollectionStorage
from .equality import canonical_collection_key, same_value_zero
from .iterator import JsIterator


struct _JsMapEntry[K: AnyType, V: AnyType](
    Copyable where conforms_to(K, Copyable) and conforms_to(V, Copyable),
    Deinitable where conforms_to(K, Deinitable) and conforms_to(V, Deinitable),
    Movable where conforms_to(K, Movable) and conforms_to(V, Movable),
):
    var key: Self.K
    var value: Self.V

    def __init__(
        out self, var key: Self.K, var value: Self.V
    ) where conforms_to(Self.K, Copyable & Deinitable) and conforms_to(
        Self.V, Copyable & Deinitable
    ):
        self.key = key^
        self.value = value^


struct JsMap[K: AnyType, V: AnyType](Equatable, ImplicitlyCopyable, Sized):
    var _entries: CollectionStorage[_JsMapEntry[Self.K, Self.V]]

    def __init__(
        out self,
    ) where conforms_to(Self.K, Copyable & Deinitable) and conforms_to(
        Self.V, Copyable & Deinitable
    ):
        self._entries = CollectionStorage[_JsMapEntry[Self.K, Self.V]]()

    def __len__(self) -> Int:
        return len(self._entries)

    def __eq__(self, other: Self) -> Bool:
        return self._entries == other._entries

    def js_size(self) -> Float64:
        return Float64(len(self))

    def get(
        self, key: Self.K
    ) -> Optional[Self.V] where conforms_to(
        Self.K, Copyable & Deinitable & Equatable
    ) and conforms_to(Self.V, Copyable & Deinitable):
        var index = self._find(key)
        if index < 0:
            return None
        return Optional[Self.V](
            self._entries.project_at[Self.V, _map_value[Self.K, Self.V]](index)
        )

    def has(
        self, key: Self.K
    ) -> Bool where conforms_to(
        Self.K, Copyable & Deinitable & Equatable
    ) and conforms_to(Self.V, Copyable & Deinitable):
        return self._find(key) >= 0

    def set(
        self, var key: Self.K, var value: Self.V
    ) -> Self where conforms_to(
        Self.K, Copyable & Deinitable & Equatable
    ) and conforms_to(Self.V, Copyable & Deinitable):
        var index = self._find(key)
        if index >= 0:
            var original_key = self._entries.project_at[
                Self.K, _map_key[Self.K, Self.V]
            ](index)
            self._entries.replace(
                index, _JsMapEntry[Self.K, Self.V](original_key^, value^)
            )
        else:
            self._entries.append(
                _JsMapEntry[Self.K, Self.V](
                    canonical_collection_key(key), value^
                )
            )
        return self

    def delete(
        self, key: Self.K
    ) -> Bool where conforms_to(
        Self.K, Copyable & Deinitable & Equatable
    ) and conforms_to(Self.V, Copyable & Deinitable):
        var index = self._find(key)
        if index < 0:
            return False
        self._entries.delete_at(index)
        return True

    def clear(
        self,
    ) where conforms_to(Self.K, Copyable & Deinitable) and conforms_to(
        Self.V, Copyable & Deinitable
    ):
        self._entries.clear()

    def keys(
        self,
    ) -> JsIterator[Self.K] where conforms_to(
        Self.K, Copyable & Deinitable
    ) and conforms_to(Self.V, Copyable & Deinitable):
        return self._entries.iterator[Self.K, _map_key[Self.K, Self.V]]()

    def values(
        self,
    ) -> JsIterator[Self.V] where conforms_to(
        Self.K, Copyable & Deinitable
    ) and conforms_to(Self.V, Copyable & Deinitable):
        return self._entries.iterator[Self.V, _map_value[Self.K, Self.V]]()

    def entries(
        self,
    ) -> JsIterator[Tuple[Self.K, Self.V]] where conforms_to(
        Self.K, Copyable & Deinitable
    ) and conforms_to(Self.V, Copyable & Deinitable):
        return self._entries.iterator[
            Tuple[Self.K, Self.V], _map_entry[Self.K, Self.V]
        ]()

    def iter_entries(
        self,
    ) -> JsIterator[Tuple[Self.K, Self.V]] where conforms_to(
        Self.K, Copyable & Deinitable
    ) and conforms_to(Self.V, Copyable & Deinitable):
        return self.entries()

    def _find(
        self, key: Self.K
    ) -> Int where conforms_to(
        Self.K, Copyable & Deinitable & Equatable
    ) and conforms_to(Self.V, Copyable & Deinitable):
        return self._entries.find[Self.K, _map_matches[Self.K, Self.V]](key)


def _map_key[
    K: Copyable & Deinitable, V: Copyable & Deinitable
](entry: _JsMapEntry[K, V]) -> K:
    return entry.key.copy()


def _map_value[
    K: Copyable & Deinitable, V: Copyable & Deinitable
](entry: _JsMapEntry[K, V]) -> V:
    return entry.value.copy()


def _map_entry[
    K: Copyable & Deinitable, V: Copyable & Deinitable
](entry: _JsMapEntry[K, V]) -> Tuple[K, V]:
    return (entry.key.copy(), entry.value.copy())


def _map_matches[
    K: Copyable & Deinitable & Equatable, V: Copyable & Deinitable
](entry: _JsMapEntry[K, V], key: K) -> Bool:
    return same_value_zero(entry.key, key)
