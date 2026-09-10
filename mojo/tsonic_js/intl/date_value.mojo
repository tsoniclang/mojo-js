from std.utils import Variant
from tsonic_runtime import Undefined
from ..date.factories import date_now
from ..date.model import JsDate


def date_value(value: JsDate) -> Float64:
    return value.get_time()


def date_value[dtype: DType](value: Scalar[dtype]) -> Float64:
    return Float64(value)


def date_value(value: Int) -> Float64:
    return Float64(value)


def date_value(value: UInt) -> Float64:
    return Float64(value)


def date_value(value: Undefined) -> Float64:
    return date_now()


def date_value[Value: Movable](value: Optional[Value]) raises -> Float64:
    if value:
        return date_value(value.value())
    return date_now()


def date_value[*Members: Movable](value: Variant[*Members]) raises -> Float64:
    comptime for index in range(Members.length):
        if value.isa[Members[index]]():
            return date_value(value[Members[index]])
    raise Error("Date input has no active selected alternative")
