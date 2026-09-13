from std.ffi import c_int, c_size_t, external_call
from std.memory import ArcPointer
from tsonic_runtime import WeakReferenceIdentity
from ..string import JsString
from ..value import JsValue
from .locales import collation_locale, requested_locales
from .native import IntlResult
from .options import CollationOptions
from .collator_options import IntlResolvedCollatorOptions


struct IntlCollator(Equatable, ImplicitlyCopyable):
    var _owner: ArcPointer[IntlResult]

    def __init__(
        out self, locales: JsValue = JsValue(), options: JsValue = JsValue()
    ) raises:
        var requested = requested_locales(locales)
        var settings = CollationOptions(options)
        var locale = collation_locale(requested)
        var owner = IntlResult(
            external_call[
                "tsonic_js_intl_collator_open",
                OptionalPointer[NoneType, MutUntrackedOrigin],
            ](
                locale.as_c_string_slice().unsafe_ptr(),
                settings.collation.as_c_string_slice().unsafe_ptr(),
                c_int(settings.search),
                settings.numeric,
                settings.case_first,
                settings.sensitivity,
                settings.punctuation,
            )
        )
        owner.check()
        self._owner = ArcPointer(owner^)

    def __eq__(self, other: Self) -> Bool:
        return self._owner is other._owner

    def weak_identity(self) -> WeakReferenceIdentity:
        return WeakReferenceIdentity(self._owner)

    def compare(self, left: String, right: String) raises -> Float64:
        return self.compare_units(JsString(left), JsString(right))

    def compare_units(self, left: JsString, right: JsString) raises -> Float64:
        var first = left._copy_code_units()
        var second = right._copy_code_units()
        var result = IntlResult(
            external_call[
                "tsonic_js_intl_collator_compare",
                OptionalPointer[NoneType, MutUntrackedOrigin],
            ](
                self._owner[].pointer.value(),
                first.unsafe_ptr(),
                c_size_t(len(first)),
                second.unsafe_ptr(),
                c_size_t(len(second)),
            )
        )
        return result.order()

    def resolved_options(self) raises -> IntlResolvedCollatorOptions:
        return IntlResolvedCollatorOptions(self._owner[])


def intl_collator_new(
    locales: JsValue = JsValue(), options: JsValue = JsValue()
) raises -> IntlCollator:
    return IntlCollator(locales, options)
