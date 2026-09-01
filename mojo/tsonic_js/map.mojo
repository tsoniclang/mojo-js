from std.collections import List
from std.memory import ArcPointer

from .array import JsArray


struct _JsMapEntry[K: Copyable & Deinitable, V: Copyable & Deinitable](Copyable):
    var key: Self.K
    var value: Self.V

    def __init__(out self, var key: Self.K, var value: Self.V):
        self.key = key^
        self.value = value^


struct JsMap[
    K: Copyable & Deinitable & Equatable,
    V: Copyable & Deinitable,
](ImplicitlyCopyable, Sized):
    var _entries: ArcPointer[List[_JsMapEntry[Self.K, Self.V]]]

    def __init__(out self):
        self._entries = ArcPointer(List[_JsMapEntry[Self.K, Self.V]]())

    def __len__(self) -> Int:
        return len(self._entries[])

    def js_size(self) -> Float64:
        return Float64(len(self))

    def get(self, key: Self.K) -> Optional[Self.V]:
        var index = self._find(key)
        return None if index < 0 else Optional[Self.V](self._entries[][index].value.copy())

    def has(self, key: Self.K) -> Bool:
        return self._find(key) >= 0

    def set(mut self, var key: Self.K, var value: Self.V) -> Self:
        var index = self._find(key)
        if index >= 0:
            self._entries[][index].value = value^
        else:
            self._entries[].append(_JsMapEntry[Self.K, Self.V](key^, value^))
        return self

    def delete(mut self, key: Self.K) -> Bool:
        var index = self._find(key)
        if index < 0:
            return False
        var next = List[_JsMapEntry[Self.K, Self.V]](capacity=len(self) - 1)
        for current in range(len(self)):
            if current != index:
                next.append(self._entries[][current].copy())
        self._entries[] = next^
        return True

    def clear(mut self):
        self._entries[].clear()

    def keys(self) -> JsArray[Self.K]:
        var result = List[Self.K](capacity=len(self))
        for entry in self._entries[]:
            result.append(entry.key.copy())
        return JsArray[Self.K](result^)

    def values(self) -> JsArray[Self.V]:
        var result = List[Self.V](capacity=len(self))
        for entry in self._entries[]:
            result.append(entry.value.copy())
        return JsArray[Self.V](result^)

    def entries(self) -> JsArray[Tuple[Self.K, Self.V]]:
        var result = List[Tuple[Self.K, Self.V]](capacity=len(self))
        for entry in self._entries[]:
            result.append((entry.key.copy(), entry.value.copy()))
        return JsArray[Tuple[Self.K, Self.V]](result^)

    def for_each(self, callback: def(Self.V, Self.K, Self) capturing):
        for entry in self._entries[]:
            callback(entry.value.copy(), entry.key.copy(), self)

    def _find(self, key: Self.K) -> Int:
        for index in range(len(self)):
            if self._entries[][index].key == key:
                return index
        return -1
