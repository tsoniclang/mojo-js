from std.builtin.rebind import downcast
from std.memory import ArcPointer


@fieldwise_init
struct _IteratorYieldState[T: AnyType]:
    var done: Optional[Bool]
    var value: downcast[Self.T, Copyable & Deinitable]


@fieldwise_init
struct _IteratorReturnState[T: AnyType]:
    var done: Bool
    var value: downcast[Self.T, Copyable & Deinitable]


struct JsIteratorYield[T: AnyType](Equatable, ImplicitlyCopyable):
    comptime Value = downcast[Self.T, Copyable & Deinitable]
    var _state: ArcPointer[_IteratorYieldState[Self.T]]

    def __init__(out self, var value: Self.Value):
        self._state = ArcPointer(_IteratorYieldState[Self.T](Optional(False), value^))

    def __eq__(self, other: Self) -> Bool:
        return self._state is other._state

    def get_done(self) -> Optional[Bool]:
        return self._state[].done

    def set_done(self, value: Optional[Bool]):
        self._state[].done = value

    def get_value(self) -> Self.Value:
        return self._state[].value.copy()

    def set_value(self, var value: Self.Value):
        self._state[].value = value^


struct JsIteratorReturn[T: AnyType](Equatable, ImplicitlyCopyable):
    comptime Value = downcast[Self.T, Copyable & Deinitable]
    var _state: ArcPointer[_IteratorReturnState[Self.T]]

    def __init__(out self, var value: Self.Value):
        self._state = ArcPointer(_IteratorReturnState[Self.T](True, value^))

    def __eq__(self, other: Self) -> Bool:
        return self._state is other._state

    def get_done(self) -> Bool:
        return self._state[].done

    def set_done(self, value: Bool):
        self._state[].done = value

    def get_value(self) -> Self.Value:
        return self._state[].value.copy()

    def set_value(self, var value: Self.Value):
        self._state[].value = value^
