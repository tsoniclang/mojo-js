from std.collections import List
from std.builtin.rebind import downcast, rebind_var
from std.memory import ArcPointer

from .array import JsArray
from .equality import same_value_zero


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


struct JsMap[
    K: AnyType,
    V: AnyType,
](ImplicitlyCopyable, Sized):
    comptime Storage = downcast[
        List[_JsMapEntry[Self.K, Self.V]], Movable & Deinitable
    ]
    var _entries: ArcPointer[Self.Storage]

    def __init__(
        out self,
    ) where conforms_to(Self.K, Copyable & Deinitable) and conforms_to(
        Self.V, Copyable & Deinitable
    ):
        var entries = rebind_var[Self.Storage](
            List[_JsMapEntry[Self.K, Self.V]]()
        )
        self._entries = ArcPointer(entries^)

    def __len__(self) -> Int:
        return len(self._entries[])

    def js_size(self) -> Float64:
        return Float64(len(self))

    def get(
        self, key: Self.K
    ) -> Optional[Self.V] where conforms_to(
        Self.K, Copyable & Deinitable & Equatable
    ) and conforms_to(Self.V, Copyable & Deinitable):
        var index = self._find(key)
        return None if index < 0 else Optional[Self.V](
            self._entries[][index].value.copy()
        )

    def has(
        self, key: Self.K
    ) -> Bool where conforms_to(
        Self.K, Copyable & Deinitable & Equatable
    ) and conforms_to(Self.V, Copyable & Deinitable):
        return self._find(key) >= 0

    def set(
        mut self, var key: Self.K, var value: Self.V
    ) -> Self where conforms_to(
        Self.K, Copyable & Deinitable & Equatable
    ) and conforms_to(Self.V, Copyable & Deinitable):
        var index = self._find(key)
        if index >= 0:
            self._entries[][index].value = value^
        else:
            self._entries[].append(_JsMapEntry[Self.K, Self.V](key^, value^))
        return self

    def delete(
        mut self, key: Self.K
    ) -> Bool where conforms_to(
        Self.K, Copyable & Deinitable & Equatable
    ) and conforms_to(Self.V, Copyable & Deinitable):
        var index = self._find(key)
        if index < 0:
            return False
        var next = List[_JsMapEntry[Self.K, Self.V]](capacity=len(self) - 1)
        for current in range(len(self)):
            if current != index:
                next.append(self._entries[][current].copy())
        self._entries[] = rebind_var[Self.Storage](next^)
        return True

    def clear(
        mut self,
    ) where conforms_to(Self.K, Copyable & Deinitable) and conforms_to(
        Self.V, Copyable & Deinitable
    ):
        self._entries[].clear()

    def keys(
        self,
    ) -> JsArray[Self.K] where conforms_to(
        Self.K, Copyable & Deinitable
    ) and conforms_to(Self.V, Copyable & Deinitable):
        var result = List[Self.K](capacity=len(self))
        for entry in self._entries[]:
            result.append(entry.key.copy())
        return JsArray[Self.K](result^)

    def values(
        self,
    ) -> JsArray[Self.V] where conforms_to(
        Self.K, Copyable & Deinitable
    ) and conforms_to(Self.V, Copyable & Deinitable):
        var result = List[Self.V](capacity=len(self))
        for entry in self._entries[]:
            result.append(entry.value.copy())
        return JsArray[Self.V](result^)

    def entries(
        self,
    ) -> JsArray[Tuple[Self.K, Self.V]] where conforms_to(
        Self.K, Copyable & Deinitable
    ) and conforms_to(Self.V, Copyable & Deinitable):
        var result = List[Tuple[Self.K, Self.V]](capacity=len(self))
        for entry in self._entries[]:
            result.append((entry.key.copy(), entry.value.copy()))
        return JsArray[Tuple[Self.K, Self.V]](result^)

    def iter_entries(
        self,
    ) -> List[Tuple[Self.K, Self.V]] where conforms_to(
        Self.K, Copyable & Deinitable
    ) and conforms_to(Self.V, Copyable & Deinitable):
        var result = List[Tuple[Self.K, Self.V]](capacity=len(self))
        for entry in self._entries[]:
            result.append((entry.key.copy(), entry.value.copy()))
        return result^

    def _find(
        self, key: Self.K
    ) -> Int where conforms_to(
        Self.K, Copyable & Deinitable & Equatable
    ) and conforms_to(Self.V, Copyable & Deinitable):
        for index in range(len(self)):
            if same_value_zero(self._entries[][index].key, key):
                return index
        return -1
