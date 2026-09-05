from std import math
from std.ffi import c_int, c_long, external_call
from std.memory import ArcPointer
from std.utils import Variant
from tsonic_runtime import Null

from .string import JsString


@fieldwise_init
struct _RealtimeSpec(RegisterPassable):
    var seconds: c_long
    var nanoseconds: c_long


@fieldwise_init
struct _UtcParts(Copyable):
    var year: Int
    var month: Int
    var day: Int
    var weekday: Int
    var hour: Int
    var minute: Int
    var second: Int
    var millisecond: Int


struct JsDate(ImplicitlyCopyable):
    var _milliseconds: ArcPointer[Float64]

    def __init__(out self, milliseconds: Float64):
        self._milliseconds = ArcPointer(milliseconds)

    def get_time(self) -> Float64:
        return self._milliseconds[]

    def value_of(self) -> Float64:
        return self.get_time()

    def set_time(mut self, value: Float64) -> Float64:
        self._milliseconds[] = _time_clip(value)
        return self.get_time()

    def get_utc_full_year(self) -> Float64:
        return Float64(_parts(self.get_time()).year)

    def get_utc_month(self) -> Float64:
        return Float64(_parts(self.get_time()).month)

    def get_utc_date(self) -> Float64:
        return Float64(_parts(self.get_time()).day)

    def get_utc_day(self) -> Float64:
        return Float64(_parts(self.get_time()).weekday)

    def get_utc_hours(self) -> Float64:
        return Float64(_parts(self.get_time()).hour)

    def get_utc_minutes(self) -> Float64:
        return Float64(_parts(self.get_time()).minute)

    def get_utc_seconds(self) -> Float64:
        return Float64(_parts(self.get_time()).second)

    def get_utc_milliseconds(self) -> Float64:
        return Float64(_parts(self.get_time()).millisecond)

    def set_utc_milliseconds(mut self, millisecond: Float64) -> Float64:
        var parts = _parts(self.get_time())
        return self.set_time(
            _from_components(
                parts.year,
                parts.month,
                parts.day,
                parts.hour,
                parts.minute,
                parts.second,
                Int(millisecond),
            )
        )

    def set_utc_seconds(
        mut self,
        second: Float64,
        millisecond: Float64 = Float64(FloatLiteral.nan),
    ) -> Float64:
        var parts = _parts(self.get_time())
        var ms = parts.millisecond if millisecond != millisecond else Int(
            millisecond
        )
        return self.set_time(
            _from_components(
                parts.year,
                parts.month,
                parts.day,
                parts.hour,
                parts.minute,
                Int(second),
                ms,
            )
        )

    def set_utc_minutes(
        mut self,
        minute: Float64,
        second: Float64 = Float64(FloatLiteral.nan),
        millisecond: Float64 = Float64(FloatLiteral.nan),
    ) -> Float64:
        var parts = _parts(self.get_time())
        var sec = parts.second if second != second else Int(second)
        var ms = parts.millisecond if millisecond != millisecond else Int(
            millisecond
        )
        return self.set_time(
            _from_components(
                parts.year,
                parts.month,
                parts.day,
                parts.hour,
                Int(minute),
                sec,
                ms,
            )
        )

    def set_utc_hours(
        mut self,
        hour: Float64,
        minute: Float64 = Float64(FloatLiteral.nan),
        second: Float64 = Float64(FloatLiteral.nan),
        millisecond: Float64 = Float64(FloatLiteral.nan),
    ) -> Float64:
        var parts = _parts(self.get_time())
        var min_ = parts.minute if minute != minute else Int(minute)
        var sec = parts.second if second != second else Int(second)
        var ms = parts.millisecond if millisecond != millisecond else Int(
            millisecond
        )
        return self.set_time(
            _from_components(
                parts.year, parts.month, parts.day, Int(hour), min_, sec, ms
            )
        )

    def set_utc_date(mut self, day: Float64) -> Float64:
        var parts = _parts(self.get_time())
        return self.set_time(
            _from_components(
                parts.year,
                parts.month,
                Int(day),
                parts.hour,
                parts.minute,
                parts.second,
                parts.millisecond,
            )
        )

    def set_utc_month(
        mut self,
        month: Float64,
        day: Float64 = Float64(FloatLiteral.nan),
    ) -> Float64:
        var parts = _parts(self.get_time())
        var day_ = parts.day if day != day else Int(day)
        return self.set_time(
            _from_components(
                parts.year,
                Int(month),
                day_,
                parts.hour,
                parts.minute,
                parts.second,
                parts.millisecond,
            )
        )

    def set_utc_full_year(
        mut self,
        year: Float64,
        month: Float64 = Float64(FloatLiteral.nan),
        day: Float64 = Float64(FloatLiteral.nan),
    ) -> Float64:
        var parts = _parts(self.get_time())
        var month_ = parts.month if month != month else Int(month)
        var day_ = parts.day if day != day else Int(day)
        return self.set_time(
            _from_components(
                Int(year),
                month_,
                day_,
                parts.hour,
                parts.minute,
                parts.second,
                parts.millisecond,
            )
        )

    def to_iso_string(self) raises -> JsString:
        if not math.isfinite(self.get_time()):
            raise Error("Invalid JavaScript Date")
        var value = _parts(self.get_time())
        return JsString(
            _year_text(value.year)
            + "-"
            + _pad(value.month + 1, 2)
            + "-"
            + _pad(value.day, 2)
            + "T"
            + _pad(value.hour, 2)
            + ":"
            + _pad(value.minute, 2)
            + ":"
            + _pad(value.second, 2)
            + "."
            + _pad(value.millisecond, 3)
            + "Z"
        )

    def to_json(self) -> Variant[JsString, Null]:
        if not math.isfinite(self.get_time()):
            return Variant[JsString, Null](Null())
        try:
            return Variant[JsString, Null](self.to_iso_string())
        except:
            return Variant[JsString, Null](Null())

    def to_utc_string(self) -> JsString:
        if not math.isfinite(self.get_time()):
            return JsString("Invalid Date")
        var value = _parts(self.get_time())
        return JsString(
            _weekday_name(value.weekday)
            + ", "
            + _pad(value.day, 2)
            + " "
            + _month_name(value.month)
            + " "
            + _pad(value.year, 4)
            + " "
            + _pad(value.hour, 2)
            + ":"
            + _pad(value.minute, 2)
            + ":"
            + _pad(value.second, 2)
            + " GMT"
        )

    def to_string(self) -> JsString:
        return self.to_utc_string()


def date_new() -> JsDate:
    return JsDate(date_now())


def date_new(value: Float64) -> JsDate:
    return JsDate(_time_clip(value))


def date_new(value: JsString) -> JsDate:
    return JsDate(date_parse(value))


def date_new(value: String) -> JsDate:
    return JsDate(date_parse_native(value))


def date_now() -> Float64:
    var value = _RealtimeSpec(0, 0)
    if external_call["clock_gettime", c_int](c_int(0), Pointer(to=value)) != 0:
        return Float64(FloatLiteral.nan)
    return (
        Float64(value.seconds) * 1000.0 + Float64(value.nanoseconds) / 1000000.0
    )


def date_parse(value: JsString) -> Float64:
    try:
        return _parse_iso(value.to_native_strict())
    except:
        return Float64(FloatLiteral.nan)


def date_parse_native(value: String) -> Float64:
    return _parse_iso(value)


def date_to_iso_string_native(value: JsDate) raises -> String:
    return value.to_iso_string().to_native_lossy()


def date_to_json_native(value: JsDate) -> Variant[String, Null]:
    if not math.isfinite(value.get_time()):
        return Variant[String, Null](Null())
    try:
        return Variant[String, Null](value.to_iso_string().to_native_lossy())
    except:
        return Variant[String, Null](Null())


def date_to_utc_string_native(value: JsDate) -> String:
    return value.to_utc_string().to_native_lossy()


def date_to_string_native(value: JsDate) -> String:
    return value.to_string().to_native_lossy()


def date_utc(
    year: Float64,
    month: Float64,
    day: Float64 = 1,
    hour: Float64 = 0,
    minute: Float64 = 0,
    second: Float64 = 0,
    millisecond: Float64 = 0,
) -> Float64:
    var normalized_year = Int(year)
    if normalized_year >= 0 and normalized_year <= 99:
        normalized_year += 1900
    return _time_clip(
        _from_components(
            normalized_year,
            Int(month),
            Int(day),
            Int(hour),
            Int(minute),
            Int(second),
            Int(millisecond),
        )
    )


def _time_clip(value: Float64) -> Float64:
    if not math.isfinite(value) or math.abs(value) > 8640000000000000.0:
        return Float64(FloatLiteral.nan)
    return math.trunc(value)


def _from_components(
    year: Int,
    month: Int,
    day: Int,
    hour: Int,
    minute: Int,
    second: Int,
    millisecond: Int,
) -> Float64:
    var normalized_year = year + _floor_div(month, 12)
    var normalized_month = _floor_mod(month, 12)
    var days = (
        _days_from_civil(normalized_year, normalized_month + 1, 1) + day - 1
    )
    return Float64(
        (((days * 24 + hour) * 60 + minute) * 60 + second) * 1000 + millisecond
    )


def _parts(milliseconds: Float64) -> _UtcParts:
    if not math.isfinite(milliseconds):
        return _UtcParts(0, 0, 0, 0, 0, 0, 0, 0)
    var total = Int64(math.floor(milliseconds))
    var days = _floor_div64(total, 86400000)
    var within = total - days * 86400000
    var civil = _civil_from_days(Int(days))
    var hour = Int(within / 3600000)
    within -= Int64(hour) * 3600000
    var minute = Int(within / 60000)
    within -= Int64(minute) * 60000
    var second = Int(within / 1000)
    var millisecond = Int(within - Int64(second) * 1000)
    return _UtcParts(
        civil[0],
        civil[1] - 1,
        civil[2],
        _floor_mod(Int(days) + 4, 7),
        hour,
        minute,
        second,
        millisecond,
    )


def _days_from_civil(year: Int, month: Int, day: Int) -> Int:
    var adjusted_year = year - (1 if month <= 2 else 0)
    var era = _floor_div(adjusted_year, 400)
    var year_of_era = adjusted_year - era * 400
    var shifted_month = month + (-3 if month > 2 else 9)
    var day_of_year = (153 * shifted_month + 2) / 5 + day - 1
    var day_of_era = (
        year_of_era * 365 + year_of_era / 4 - year_of_era / 100 + day_of_year
    )
    return era * 146097 + day_of_era - 719468


def _civil_from_days(days: Int) -> Tuple[Int, Int, Int]:
    var shifted = days + 719468
    var era = _floor_div(shifted, 146097)
    var day_of_era = shifted - era * 146097
    var year_of_era = (
        day_of_era
        - day_of_era / 1460
        + day_of_era / 36524
        - day_of_era / 146096
    ) / 365
    var year = year_of_era + era * 400
    var day_of_year = day_of_era - (
        365 * year_of_era + year_of_era / 4 - year_of_era / 100
    )
    var month_prime = (5 * day_of_year + 2) / 153
    var day = day_of_year - (153 * month_prime + 2) / 5 + 1
    var month = month_prime + (3 if month_prime < 10 else -9)
    year += 1 if month <= 2 else 0
    return (year, month, day)


def _parse_iso(value: String) -> Float64:
    if (
        value.byte_length() < 10
        or UInt8(value.as_bytes()[4]) != 45
        or UInt8(value.as_bytes()[7]) != 45
    ):
        return Float64(FloatLiteral.nan)
    var year = _digits(value, 0, 4)
    var month = _digits(value, 5, 2)
    var day = _digits(value, 8, 2)
    if year < 0 or month < 1 or month > 12 or day < 1 or day > 31:
        return Float64(FloatLiteral.nan)
    if value.byte_length() == 10:
        return _time_clip(_from_components(year, month - 1, day, 0, 0, 0, 0))
    if (
        value.byte_length() < 20
        or UInt8(value.as_bytes()[10]) != 84
        or UInt8(value.as_bytes()[13]) != 58
        or UInt8(value.as_bytes()[16]) != 58
    ):
        return Float64(FloatLiteral.nan)
    var hour = _digits(value, 11, 2)
    var minute = _digits(value, 14, 2)
    var second = _digits(value, 17, 2)
    var millisecond = 0
    var offset = 19
    if offset < value.byte_length() and UInt8(value.as_bytes()[offset]) == 46:
        offset += 1
        var multiplier = 100
        while offset < value.byte_length() and multiplier > 0:
            var digit = _digit(UInt8(value.as_bytes()[offset]))
            if digit < 0:
                break
            millisecond += digit * multiplier
            multiplier /= 10
            offset += 1
    var timezone = 0
    if offset < value.byte_length() and UInt8(value.as_bytes()[offset]) != 90:
        var sign = -1 if UInt8(value.as_bytes()[offset]) == 43 else 1
        if (
            UInt8(value.as_bytes()[offset]) != 43
            and UInt8(value.as_bytes()[offset]) != 45
        ):
            return Float64(FloatLiteral.nan)
        if (
            offset + 5 >= value.byte_length()
            or UInt8(value.as_bytes()[offset + 3]) != 58
        ):
            return Float64(FloatLiteral.nan)
        timezone = sign * (
            _digits(value, offset + 1, 2) * 60 + _digits(value, offset + 4, 2)
        )
        offset += 6
    else:
        offset += 1
    if offset != value.byte_length() or hour > 23 or minute > 59 or second > 59:
        return Float64(FloatLiteral.nan)
    return _time_clip(
        _from_components(
            year, month - 1, day, hour, minute + timezone, second, millisecond
        )
    )


def _digits(value: String, start: Int, count: Int) -> Int:
    if start < 0 or start + count > value.byte_length():
        return -1
    var result = 0
    for index in range(start, start + count):
        var digit = _digit(UInt8(value.as_bytes()[index]))
        if digit < 0:
            return -1
        result = result * 10 + digit
    return result


def _digit(value: UInt8) -> Int:
    return Int(value - 48) if value >= 48 and value <= 57 else -1


def _floor_div(value: Int, divisor: Int) -> Int:
    var quotient = value / divisor
    return quotient - 1 if value < 0 and value % divisor != 0 else quotient


def _floor_mod(value: Int, divisor: Int) -> Int:
    return value - _floor_div(value, divisor) * divisor


def _floor_div64(value: Int64, divisor: Int64) -> Int64:
    var quotient = value / divisor
    return quotient - 1 if value < 0 and value % divisor != 0 else quotient


def _pad(value: Int, width: Int) -> String:
    var text = String(value)
    var result = String()
    for _ in range(max(width - text.byte_length(), 0)):
        result += "0"
    return result + text


def _year_text(year: Int) -> String:
    if year >= 0 and year <= 9999:
        return _pad(year, 4)
    return ("+" if year >= 0 else "-") + _pad(abs(year), 6)


def _weekday_name(value: Int) -> String:
    if value == 0:
        return "Sun"
    if value == 1:
        return "Mon"
    if value == 2:
        return "Tue"
    if value == 3:
        return "Wed"
    if value == 4:
        return "Thu"
    if value == 5:
        return "Fri"
    return "Sat"


def _month_name(value: Int) -> String:
    if value == 0:
        return "Jan"
    if value == 1:
        return "Feb"
    if value == 2:
        return "Mar"
    if value == 3:
        return "Apr"
    if value == 4:
        return "May"
    if value == 5:
        return "Jun"
    if value == 6:
        return "Jul"
    if value == 7:
        return "Aug"
    if value == 8:
        return "Sep"
    if value == 9:
        return "Oct"
    if value == 10:
        return "Nov"
    return "Dec"
