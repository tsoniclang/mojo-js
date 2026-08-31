from std.collections import List
from std.memory import ArcPointer


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

    def push(mut self, var value: Self.T) -> Int:
        self._elements[].append(Optional[Self.T](value^))
        return len(self)

    def get(self, index: Int) -> Optional[Self.T]:
        if index < 0 or index >= len(self):
            return None
        return self._elements[][index].copy()

    def set(mut self, index: Int, var value: Self.T):
        if index < 0:
            return
        while len(self) <= index:
            self._elements[].append(Optional[Self.T]())
        self._elements[][index] = Optional[Self.T](value^)

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
