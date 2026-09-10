from std.ffi import c_int, external_call
from std.memory import ArcPointer
from tsonic_runtime import WeakReferenceIdentity
from .native import IntlResult


@fieldwise_init
struct _DateTimeOptions:
    var locale: String
    var calendar: String
    var numbering_system: String
    var time_zone: String


def _text(owner: IntlResult, field: Int) raises -> String:
    var pointer = external_call[
        "tsonic_js_intl_datetime_text", OptionalPointer[UInt8, ImmUntrackedOrigin],
    ](owner.pointer.value(), c_int(field))
    if not pointer:
        raise Error("A retained date formatter has no resolved text field")
    return String(unsafe_from_utf8_ptr=pointer.value())


struct IntlResolvedDateTimeFormatOptions(Equatable, ImplicitlyCopyable):
    var _state: ArcPointer[_DateTimeOptions]

    def __init__(out self, owner: IntlResult) raises:
        self._state = ArcPointer(_DateTimeOptions(_text(owner, 0), _text(owner, 1), _text(owner, 2), _text(owner, 3)))

    def __eq__(self, other: Self) -> Bool:
        return self._state is other._state

    def weak_identity(self) -> WeakReferenceIdentity:
        return WeakReferenceIdentity(self._state)

    def get_locale(self) -> String:
        return self._state[].locale

    def set_locale(self, value: String):
        self._state[].locale = value

    def get_calendar(self) -> String:
        return self._state[].calendar

    def set_calendar(self, value: String):
        self._state[].calendar = value

    def get_numbering_system(self) -> String:
        return self._state[].numbering_system

    def set_numbering_system(self, value: String):
        self._state[].numbering_system = value

    def get_time_zone(self) -> String:
        return self._state[].time_zone

    def set_time_zone(self, value: String):
        self._state[].time_zone = value
