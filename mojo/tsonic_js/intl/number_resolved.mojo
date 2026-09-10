from std.ffi import c_int, external_call
from std.memory import ArcPointer
from std.utils import Variant
from tsonic_runtime import WeakReferenceIdentity
from .native import IntlResult
from .number_options import NumberOptions


@fieldwise_init
struct _NumberResolvedOptions:
    var locale: String
    var numbering_system: String
    var options: NumberOptions
    var grouping: Variant[Bool, String]


def _text(owner: IntlResult, field: Int) raises -> String:
    var pointer = external_call[
        "tsonic_js_intl_number_formatter_text", OptionalPointer[UInt8, ImmUntrackedOrigin],
    ](owner.pointer.value(), c_int(field))
    if not pointer:
        raise Error("A retained number formatter has no resolved text field")
    return String(unsafe_from_utf8_ptr=pointer.value())


struct IntlResolvedNumberFormatOptions(Equatable, ImplicitlyCopyable):
    var _state: ArcPointer[_NumberResolvedOptions]

    def __init__(out self, owner: IntlResult, options: NumberOptions) raises:
        var grouping = Variant[Bool, String](False)
        if options.grouping:
            grouping = Variant[Bool, String](options.grouping.value())
        self._state = ArcPointer(_NumberResolvedOptions(_text(owner, 0), _text(owner, 1), options, grouping^))

    def __eq__(self, other: Self) -> Bool:
        return self._state is other._state

    def weak_identity(self) -> WeakReferenceIdentity:
        return WeakReferenceIdentity(self._state)

    def get_locale(self) -> String:
        return self._state[].locale

    def set_locale(self, value: String):
        self._state[].locale = value

    def get_numbering_system(self) -> String:
        return self._state[].numbering_system

    def set_numbering_system(self, value: String):
        self._state[].numbering_system = value

    def get_style(self) -> String:
        return self._state[].options.style

    def set_style(self, value: String):
        self._state[].options.style = value

    def get_currency(self) -> Optional[String]:
        return self._state[].options.currency

    def set_currency(self, value: Optional[String]):
        self._state[].options.currency = value

    def get_currency_display(self) -> Optional[String]:
        return self._state[].options.currency_display

    def set_currency_display(self, value: Optional[String]):
        self._state[].options.currency_display = value

    def get_currency_sign(self) -> Optional[String]:
        return self._state[].options.currency_sign

    def set_currency_sign(self, value: Optional[String]):
        self._state[].options.currency_sign = value

    def get_use_grouping(self) -> Variant[Bool, String]:
        return self._state[].grouping

    def set_use_grouping(self, var value: Variant[Bool, String]):
        self._state[].grouping = value^

    def get_minimum_integer_digits(self) -> Float64:
        return self._state[].options.precision.minimum_integer

    def set_minimum_integer_digits(self, value: Float64):
        self._state[].options.precision.minimum_integer = value

    def get_minimum_fraction_digits(self) -> Optional[Float64]:
        return self._state[].options.precision.minimum_fraction

    def set_minimum_fraction_digits(self, value: Optional[Float64]):
        self._state[].options.precision.minimum_fraction = value

    def get_maximum_fraction_digits(self) -> Optional[Float64]:
        return self._state[].options.precision.maximum_fraction

    def set_maximum_fraction_digits(self, value: Optional[Float64]):
        self._state[].options.precision.maximum_fraction = value

    def get_minimum_significant_digits(self) -> Optional[Float64]:
        return self._state[].options.precision.minimum_significant

    def set_minimum_significant_digits(self, value: Optional[Float64]):
        self._state[].options.precision.minimum_significant = value

    def get_maximum_significant_digits(self) -> Optional[Float64]:
        return self._state[].options.precision.maximum_significant

    def set_maximum_significant_digits(self, value: Optional[Float64]):
        self._state[].options.precision.maximum_significant = value

    def get_notation(self) -> String:
        return self._state[].options.notation

    def set_notation(self, value: String):
        self._state[].options.notation = value

    def get_compact_display(self) -> Optional[String]:
        return self._state[].options.compact_display

    def set_compact_display(self, value: Optional[String]):
        self._state[].options.compact_display = value

    def get_sign_display(self) -> String:
        return self._state[].options.sign_display

    def set_sign_display(self, value: String):
        self._state[].options.sign_display = value

    def get_rounding_increment(self) -> Float64:
        return self._state[].options.precision.rounding_increment

    def set_rounding_increment(self, value: Float64):
        self._state[].options.precision.rounding_increment = value

    def get_rounding_mode(self) -> String:
        return self._state[].options.precision.rounding_mode

    def set_rounding_mode(self, value: String):
        self._state[].options.precision.rounding_mode = value

    def get_rounding_priority(self) -> String:
        return self._state[].options.precision.rounding_priority

    def set_rounding_priority(self, value: String):
        self._state[].options.precision.rounding_priority = value

    def get_trailing_zero_display(self) -> String:
        return self._state[].options.precision.trailing_zero_display

    def set_trailing_zero_display(self, value: String):
        self._state[].options.precision.trailing_zero_display = value
