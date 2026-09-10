from std import math
from std.collections import List
from std.ffi import c_int, external_call

from ..string import JsString


def zone_offset(milliseconds: Float64, local: Bool = False) raises -> Float64:
    if not math.isfinite(milliseconds):
        return milliseconds
    var offset = Int32(0)
    var status = external_call["tsonic_js_date_zone_offset", c_int](
        milliseconds, c_int(local), Pointer(to=offset)
    )
    if status != 0:
        raise Error("Date timezone lookup failed: " + String(status))
    return Float64(offset)


def local_time(milliseconds: Float64) raises -> Float64:
    return milliseconds + zone_offset(milliseconds)


def utc_time(milliseconds: Float64) raises -> Float64:
    return milliseconds - zone_offset(milliseconds, True)


def zone_name(milliseconds: Float64) raises -> String:
    var output = List[UInt16](capacity=256)
    for _ in range(256):
        output.append(0)
    var length = Int32(0)
    var status = external_call["tsonic_js_date_zone_name", c_int](
        milliseconds,
        output.unsafe_ptr(),
        Int32(len(output)),
        Pointer(to=length),
    )
    if status != 0:
        raise Error("Date timezone name lookup failed: " + String(status))
    if length < 0 or length > len(output):
        raise Error("Date timezone name returned an invalid length")
    output.shrink(Int(length))
    return JsString(code_units=output^).to_native_strict()
