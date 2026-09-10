from std.memory import ArcPointer
from tsonic_runtime import WeakReferenceIdentity


@fieldwise_init
struct _FormatPart:
    var type: String
    var value: String


struct IntlFormatPart(Equatable, ImplicitlyCopyable):
    var _state: ArcPointer[_FormatPart]

    def __init__(out self, var type: String, var value: String):
        self._state = ArcPointer(_FormatPart(type^, value^))

    def __eq__(self, other: Self) -> Bool:
        return self._state is other._state

    def weak_identity(self) -> WeakReferenceIdentity:
        return WeakReferenceIdentity(self._state)

    def get_type(self) -> String:
        return self._state[].type

    def set_type(self, value: String):
        self._state[].type = value

    def get_value(self) -> String:
        return self._state[].value

    def set_value(self, value: String):
        self._state[].value = value
