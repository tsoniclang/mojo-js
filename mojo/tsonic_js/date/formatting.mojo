from std import math

from .arithmetic import DateParts, parts
from .timezone import zone_name, zone_offset


def iso_string(milliseconds: Float64) raises -> String:
    if not math.isfinite(milliseconds):
        raise Error("Invalid JavaScript Date")
    var value = parts(milliseconds)
    return (
        year_text(value.year)
        + "-"
        + pad(value.month + 1, 2)
        + "-"
        + pad(value.day, 2)
        + "T"
        + clock_text(value)
        + "."
        + pad(value.millisecond, 3)
        + "Z"
    )


def utc_string(milliseconds: Float64) -> String:
    if not math.isfinite(milliseconds):
        return "Invalid Date"
    var value = parts(milliseconds)
    return (
        weekday_name(value.weekday)
        + ", "
        + pad(value.day, 2)
        + " "
        + month_name(value.month)
        + " "
        + calendar_year_text(value.year)
        + " "
        + clock_text(value)
        + " GMT"
    )


def local_date_string(milliseconds: Float64) raises -> String:
    if not math.isfinite(milliseconds):
        return "Invalid Date"
    var value = parts(milliseconds + zone_offset(milliseconds))
    return (
        weekday_name(value.weekday)
        + " "
        + month_name(value.month)
        + " "
        + pad(value.day, 2)
        + " "
        + calendar_year_text(value.year)
    )


def local_time_string(milliseconds: Float64) raises -> String:
    if not math.isfinite(milliseconds):
        return "Invalid Date"
    var offset = zone_offset(milliseconds)
    var value = parts(milliseconds + offset)
    var minutes = Int(math.abs(offset) / 60000.0)
    return (
        clock_text(value)
        + " GMT"
        + ("+" if offset >= 0 else "-")
        + pad(minutes / 60, 2)
        + pad(minutes % 60, 2)
        + " ("
        + zone_name(milliseconds)
        + ")"
    )


def local_string(milliseconds: Float64) raises -> String:
    if not math.isfinite(milliseconds):
        return "Invalid Date"
    return (
        local_date_string(milliseconds) + " " + local_time_string(milliseconds)
    )


def clock_text(value: DateParts) -> String:
    return (
        pad(value.hour, 2)
        + ":"
        + pad(value.minute, 2)
        + ":"
        + pad(value.second, 2)
    )


def pad(value: Int, width: Int) -> String:
    var text = String(value)
    var result = String()
    for _ in range(max(width - text.byte_length(), 0)):
        result += "0"
    return result + text


def year_text(year: Int) -> String:
    if year >= 0 and year <= 9999:
        return pad(year, 4)
    return ("+" if year >= 0 else "-") + pad(abs(year), 6)


def calendar_year_text(year: Int) -> String:
    return ("-" if year < 0 else "") + pad(abs(year), 4)


def weekday_name(value: Int) -> String:
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


def month_name(value: Int) -> String:
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
