from std.collections import List
from std.ffi import c_int, c_size_t, external_call
from .native import IntlResult


def convert_case_units(source: List[UInt16], locale: String, upper: Bool) raises -> List[UInt16]:
    var selected = String(locale)
    var result = IntlResult(external_call[
        "tsonic_js_intl_case", OptionalPointer[NoneType, MutUntrackedOrigin],
    ](source.unsafe_ptr(), c_size_t(len(source)), selected.as_c_string_slice().ptr(), c_int(upper)))
    return result.units()
