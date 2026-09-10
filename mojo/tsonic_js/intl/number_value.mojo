from std.ffi import c_int, external_call
from .native import IntlResult


def _result[
    origin: Origin
](
    owner: IntlResult,
    value: Float64,
    decimal: OptionalPointer[Int8, origin],
    parts: Bool,
) raises -> IntlResult:
    var result = IntlResult(
        external_call[
            "tsonic_js_intl_number_formatter_format",
            OptionalPointer[NoneType, MutUntrackedOrigin],
        ](owner.pointer.value(), value, decimal, c_int(parts))
    )
    result.check()
    return result^


def number_result[
    dtype: DType
](owner: IntlResult, value: Scalar[dtype], parts: Bool) raises -> IntlResult:
    comptime if dtype.is_integral():
        var decimal = String(value)
        return _result(owner, 0.0, decimal.as_c_string_slice().ptr(), parts)
    else:
        return _result(
            owner,
            Float64(value),
            OptionalPointer[Int8, ImmUntrackedOrigin](),
            parts,
        )


def number_result(
    owner: IntlResult, value: Int, parts: Bool
) raises -> IntlResult:
    var decimal = String(value)
    return _result(owner, 0.0, decimal.as_c_string_slice().ptr(), parts)


def number_result(
    owner: IntlResult, value: UInt, parts: Bool
) raises -> IntlResult:
    var decimal = String(value)
    return _result(owner, 0.0, decimal.as_c_string_slice().ptr(), parts)
