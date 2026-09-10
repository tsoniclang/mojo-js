from std import math
from std.ffi import c_int, c_long, external_call
from std.utils import Variant
from tsonic_runtime import Null

from ..string import JsString
from .arithmetic import constructor_year, from_components, invalid_time, supplied_number, time_clip
from .formatting import iso_string, local_date_string, local_string, local_time_string, utc_string
from .model import JsDate
from .parsing import parse_date
from .timezone import utc_time


@fieldwise_init
struct _RealtimeSpec(RegisterPassable):
    var seconds: c_long
    var nanoseconds: c_long


def date_now() -> Float64:
    var value = _RealtimeSpec(0, 0)
    if external_call["clock_gettime", c_int](c_int(0), Pointer(to=value)) != 0:
        return invalid_time()
    return Float64(value.seconds) * 1000.0 + Float64(value.nanoseconds / 1000000)


def date_new() -> JsDate:
    return JsDate(date_now())


def date_new(value: Float64) -> JsDate:
    return JsDate(value)


def date_new(value: JsDate) -> JsDate:
    return JsDate(value.get_time())


def date_new(value: JsString) raises -> JsDate:
    return JsDate(date_parse(value))


def date_new(value: String) raises -> JsDate:
    return JsDate(date_parse_native(value))


def date_new(
    year: Float64,
    month: Float64,
    day: Optional[Float64] = Optional[Float64](1),
    hour: Optional[Float64] = Optional[Float64](0),
    minute: Optional[Float64] = Optional[Float64](0),
    second: Optional[Float64] = Optional[Float64](0),
    millisecond: Optional[Float64] = Optional[Float64](0),
) raises -> JsDate:
    return JsDate(utc_time(from_components(
        constructor_year(year), month, supplied_number(day), supplied_number(hour),
        supplied_number(minute), supplied_number(second), supplied_number(millisecond),
    )))


def date_utc(
    year: Float64,
    month: Optional[Float64] = Optional[Float64](0),
    day: Optional[Float64] = Optional[Float64](1),
    hour: Optional[Float64] = Optional[Float64](0),
    minute: Optional[Float64] = Optional[Float64](0),
    second: Optional[Float64] = Optional[Float64](0),
    millisecond: Optional[Float64] = Optional[Float64](0),
) -> Float64:
    return time_clip(from_components(
        constructor_year(year), supplied_number(month), supplied_number(day),
        supplied_number(hour), supplied_number(minute), supplied_number(second),
        supplied_number(millisecond),
    ))


def date_parse(value: JsString) raises -> Float64:
    var native = String()
    try:
        native = value.to_native_strict()
    except:
        return invalid_time()
    return parse_date(native)


def date_parse_native(value: String) raises -> Float64:
    return parse_date(value)


def date_to_iso_string_native(value: JsDate) raises -> String:
    return iso_string(value.get_time())


def date_to_json_native(value: JsDate) raises -> Variant[String, Null]:
    if not math.isfinite(value.get_time()):
        return Variant[String, Null](Null())
    return Variant[String, Null](iso_string(value.get_time()))


def date_to_utc_string_native(value: JsDate) -> String:
    return utc_string(value.get_time())


def date_to_string_native(value: JsDate) raises -> String:
    return local_string(value.get_time())


def date_to_date_string_native(value: JsDate) raises -> String:
    return local_date_string(value.get_time())


def date_to_time_string_native(value: JsDate) raises -> String:
    return local_time_string(value.get_time())
