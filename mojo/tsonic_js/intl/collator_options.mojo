from std.ffi import c_int, external_call
from std.memory import ArcPointer
from tsonic_runtime import WeakReferenceIdentity
from .native import IntlResult


@fieldwise_init
struct _CollatorOptions:
    var locale: String
    var usage: String
    var sensitivity: String
    var ignore_punctuation: Bool
    var collation: String
    var numeric: Bool
    var case_first: String


def _text(owner: IntlResult, field: Int) raises -> String:
    var pointer = external_call[
        "tsonic_js_intl_collator_text",
        OptionalPointer[UInt8, ImmUntrackedOrigin],
    ](owner.pointer.value(), c_int(field))
    if not pointer:
        raise Error("A retained collator has no resolved text field")
    return String(unsafe_from_utf8_ptr=pointer.value())


def _option(owner: IntlResult, field: Int, maximum: Int) raises -> Int:
    var value = Int(
        external_call["tsonic_js_intl_collator_option", c_int](
            owner.pointer.value(), c_int(field)
        )
    )
    if value < 0 or value > maximum:
        raise Error("A retained collator has no resolved option field")
    return value


struct IntlResolvedCollatorOptions(Equatable, ImplicitlyCopyable):
    var _state: ArcPointer[_CollatorOptions]

    def __init__(out self, owner: IntlResult) raises:
        var search = _option(owner, 0, 1)
        var sensitivity = _option(owner, 1, 3)
        var punctuation = _option(owner, 2, 1)
        var numeric = _option(owner, 3, 1)
        var case_first = _option(owner, 4, 2)
        var sensitivity_names = String("base|accent|case|variant")
        var case_names = String("false|upper|lower")
        var sensitivities = sensitivity_names.split("|")
        var cases = case_names.split("|")
        self._state = ArcPointer(
            _CollatorOptions(
                _text(owner, 0),
                String("search" if search else "sort"),
                String(sensitivities[sensitivity]),
                Bool(punctuation),
                _text(owner, 1),
                Bool(numeric),
                String(cases[case_first]),
            )
        )

    def __eq__(self, other: Self) -> Bool:
        return self._state is other._state

    def weak_identity(self) -> WeakReferenceIdentity:
        return WeakReferenceIdentity(self._state)

    def get_locale(self) -> String:
        return self._state[].locale

    def set_locale(self, value: String):
        self._state[].locale = value

    def get_usage(self) -> String:
        return self._state[].usage

    def set_usage(self, value: String):
        self._state[].usage = value

    def get_sensitivity(self) -> String:
        return self._state[].sensitivity

    def set_sensitivity(self, value: String):
        self._state[].sensitivity = value

    def get_ignore_punctuation(self) -> Bool:
        return self._state[].ignore_punctuation

    def set_ignore_punctuation(self, value: Bool):
        self._state[].ignore_punctuation = value

    def get_collation(self) -> String:
        return self._state[].collation

    def set_collation(self, value: String):
        self._state[].collation = value

    def get_numeric(self) -> Bool:
        return self._state[].numeric

    def set_numeric(self, value: Bool):
        self._state[].numeric = value

    def get_case_first(self) -> String:
        return self._state[].case_first

    def set_case_first(self, value: String):
        self._state[].case_first = value
