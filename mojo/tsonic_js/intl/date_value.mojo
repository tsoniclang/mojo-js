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


def _date_leaf[Value: Copyable & Deinitable](value: Value) -> Float64:
    comptime if Value == JsDate:
        return rebind[JsDate](value).get_time()
    elif Value == Undefined:
        return date_now()
    elif Value == Float16:
        return Float64(rebind[Float16](value))
    elif Value == Float32:
        return Float64(rebind[Float32](value))
    elif Value == Float64:
        return Float64(rebind[Float64](value))
    elif Value == Int8:
        return Float64(rebind[Int8](value))
    elif Value == Int16:
        return Float64(rebind[Int16](value))
    elif Value == Int32:
        return Float64(rebind[Int32](value))
    elif Value == Int64:
        return Float64(rebind[Int64](value))
    elif Value == Int128:
        return Float64(rebind[Int128](value))
    elif Value == UInt8:
        return Float64(rebind[UInt8](value))
    elif Value == UInt16:
        return Float64(rebind[UInt16](value))
    elif Value == UInt32:
        return Float64(rebind[UInt32](value))
    elif Value == UInt64:
        return Float64(rebind[UInt64](value))
    elif Value == UInt128:
        return Float64(rebind[UInt128](value))
    elif conforms_to(Value, Floatable):
        return Float64(value)
    else:
        comptime assert (
            False
        ), "Date input must be an exact date, numeric or undefined value"


def date_value[
    Value: Copyable & Deinitable
](value: Optional[Value]) raises -> Float64:
    if value:
        return _date_leaf(value.value())
    return date_now()


def date_value[
    *Members: Copyable & Deinitable
](value: Variant[*Members]) raises -> Float64:
    comptime for index in range(Members.length):
        if value.isa[Members[index]]():
            return _date_leaf(value[Members[index]])
    raise Error("Date input has no active selected alternative")
