from std.builtin.rebind import downcast, rebind_var
from std.collections import List
from std.memory import ArcPointer

from .iterator import JsIterator, make_iterator


struct _CollectionData[T: AnyType](
    Deinitable where conforms_to(T, Deinitable),
    Movable where conforms_to(T, Movable),
):
    var slots: List[Optional[Self.T]]
    var size: Int
    var readers: Int

    def __init__(out self) where conforms_to(Self.T, Copyable & Deinitable):
        self.slots = List[Optional[Self.T]]()
        self.size = 0
        self.readers = 0


struct CollectionStorage[T: AnyType](Equatable, ImplicitlyCopyable, Sized):
    comptime Data = downcast[_CollectionData[Self.T], Movable & Deinitable]
    var _data: ArcPointer[Self.Data]

    def __init__(out self) where conforms_to(Self.T, Copyable & Deinitable):
        self._data = ArcPointer(
            rebind_var[Self.Data](_CollectionData[Self.T]())
        )

    def __eq__(self, other: Self) -> Bool:
        return self._data is other._data

    def __len__(self) -> Int:
        return self._data[].size

    def slot_count(self) -> Int:
        return len(self._data[].slots)

    def present(self, index: Int) -> Bool:
        return Bool(self._data[].slots[index])

    def project_at[
        U: Copyable & Deinitable,
        project: def(Self.T) thin -> U,
    ](self, index: Int) -> U where conforms_to(Self.T, Copyable & Deinitable):
        return project(self._data[].slots[index].value())

    def find[
        Key: Copyable & Deinitable,
        matches: def(Self.T, Key) thin -> Bool,
    ](self, key: Key) -> Int where conforms_to(Self.T, Copyable & Deinitable):
        for index in range(self.slot_count()):
            if self.present(index) and matches(
                self._data[].slots[index].value(), key
            ):
                return index
        return -1

    def replace(
        self, index: Int, var value: Self.T
    ) where conforms_to(Self.T, Copyable & Deinitable):
        self._data[].slots[index] = Optional[Self.T](value^)

    def append(
        self, var value: Self.T
    ) where conforms_to(Self.T, Copyable & Deinitable):
        self._compact()
        self._data[].slots.append(Optional[Self.T](value^))
        self._data[].size += 1

    def delete_at(
        self, index: Int
    ) where conforms_to(Self.T, Copyable & Deinitable):
        if self._data[].slots[index]:
            self._data[].slots[index] = None
            self._data[].size -= 1
            self._compact()

    def clear(self) where conforms_to(Self.T, Copyable & Deinitable):
        if self._data[].readers == 0:
            self._data[].slots.clear()
        else:
            for index in range(self.slot_count()):
                self._data[].slots[index] = None
        self._data[].size = 0

    def _compact(self) where conforms_to(Self.T, Copyable & Deinitable):
        if self._data[].readers != 0:
            return
        if self.slot_count() - self._data[].size <= self._data[].size:
            return
        var slots = List[Optional[Self.T]](capacity=self._data[].size)
        for entry in self._data[].slots:
            if entry:
                slots.append(entry.copy())
        self._data[].slots = slots^

    def iterator[
        U: Copyable & Deinitable,
        project: def(Self.T) thin -> U,
    ](self) -> JsIterator[U] where conforms_to(Self.T, Copyable & Deinitable):
        comptime Cursor = _CollectionCursor[Self.T, U, project]
        return make_iterator[U, Cursor, Cursor.read_next](Cursor(self))


struct _CollectionCursor[
    T: Copyable & Deinitable,
    U: Copyable & Deinitable,
    project: def(T) thin -> U,
](Movable):
    var storage: Optional[CollectionStorage[Self.T]]
    var index: Int

    def __init__(out self, storage: CollectionStorage[Self.T]):
        self.storage = Optional(storage)
        self.index = 0
        storage._data[].readers += 1

    def __deinit__(deinit self):
        if self.storage:
            self.storage.value()._data[].readers -= 1

    @staticmethod
    def read_next(mut cursor: Self) -> Optional[Self.U]:
        if not cursor.storage:
            return None
        var storage = cursor.storage.value()
        while cursor.index < storage.slot_count():
            var index = cursor.index
            cursor.index += 1
            if storage.present(index):
                return Optional[Self.U](
                    storage.project_at[Self.U, Self.project](index)
                )
        storage._data[].readers -= 1
        cursor.storage = None
        return None
