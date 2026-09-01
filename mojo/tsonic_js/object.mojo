from tsonic_runtime import Null, Undefined

from .string import JsString
from .value import JsValue


fn object_is(left: JsValue, right: JsValue) -> Bool:
    if left.isa[Undefined]():
        return right.isa[Undefined]()
    if left.isa[Null]():
        return right.isa[Null]()
    if left.isa[Bool]():
        return right.isa[Bool]() and left[Bool] == right[Bool]
    if left.isa[Float64]():
        if not right.isa[Float64]():
            return False
        var left_number = left[Float64]
        var right_number = right[Float64]
        if left_number != left_number:
            return right_number != right_number
        if left_number == 0 and right_number == 0:
            return bitcast[.uint64](left_number) == bitcast[.uint64](right_number)
        return left_number == right_number
    if left.isa[JsString]():
        return right.isa[JsString]() and left[JsString] == right[JsString]
    return False
