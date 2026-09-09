from .arithmetic import from_components, invalid_time, time_clip
from .formatting import month_name, weekday_name
from .timezone import utc_time


def parse_date(value: String) raises -> Float64:
    if value.byte_length() >= 3:
        for index in range(7):
            if has_prefix(value, weekday_name(index)):
                return parse_display_date(value)
    return parse_iso(value)


def parse_iso(value: String) raises -> Float64:
    var length = value.byte_length()
    var position = 0
    var year_width = 4
    var sign = 1
    if length > 0 and (byte_at(value, 0) == 43 or byte_at(value, 0) == 45):
        sign = -1 if byte_at(value, 0) == 45 else 1
        position = 1
        year_width = 6
    var year = digits(value, position, year_width)
    if year < 0 or (sign == -1 and year == 0):
        return invalid_time()
    year *= sign
    position += year_width
    var month = 1
    var day = 1
    if position == length:
        return time_clip(from_components(Float64(year), 0, 1, 0, 0, 0, 0))
    if byte_at(value, position) != 45:
        return invalid_time()
    month = digits(value, position + 1, 2)
    position += 3
    if month < 1 or month > 12:
        return invalid_time()
    if position == length:
        return time_clip(from_components(Float64(year), Float64(month - 1), 1, 0, 0, 0, 0))
    if byte_at(value, position) != 45:
        return invalid_time()
    day = digits(value, position + 1, 2)
    position += 3
    if day < 1 or day > 31:
        return invalid_time()
    if position == length:
        return time_clip(from_components(
            Float64(year), Float64(month - 1), Float64(day), 0, 0, 0, 0
        ))
    if byte_at(value, position) != 84:
        return invalid_time()
    var hour = digits(value, position + 1, 2)
    if byte_at(value, position + 3) != 58:
        return invalid_time()
    var minute = digits(value, position + 4, 2)
    position += 6
    var second = 0
    var millisecond = 0
    if byte_at(value, position) == 58:
        second = digits(value, position + 1, 2)
        position += 3
        if byte_at(value, position) == 46:
            position += 1
            var fractional_start = position
            var multiplier = 100
            while position < length:
                var digit = digits(value, position, 1)
                if digit < 0:
                    break
                millisecond += digit * multiplier
                multiplier /= 10
                position += 1
            if position == fractional_start:
                return invalid_time()
    if (
        hour < 0 or hour > 24 or minute < 0 or minute > 59
        or second < 0 or second > 59
        or (hour == 24 and (minute != 0 or second != 0 or millisecond != 0))
    ):
        return invalid_time()
    var timestamp = from_components(
        Float64(year), Float64(month - 1), Float64(day), Float64(hour),
        Float64(minute), Float64(second), Float64(millisecond),
    )
    if position == length:
        return time_clip(utc_time(timestamp))
    if byte_at(value, position) == 90:
        return time_clip(timestamp) if position + 1 == length else invalid_time()
    var direction = byte_at(value, position)
    if direction != 43 and direction != 45:
        return invalid_time()
    if position + 6 != length or byte_at(value, position + 3) != 58:
        return invalid_time()
    var offset_hours = digits(value, position + 1, 2)
    var offset_minutes = digits(value, position + 4, 2)
    if offset_hours < 0 or offset_hours > 23 or offset_minutes < 0 or offset_minutes > 59:
        return invalid_time()
    var offset = Float64(offset_hours * 60 + offset_minutes) * 60000.0
    return time_clip(timestamp - offset if direction == 43 else timestamp + offset)


def parse_display_date(value: String) -> Float64:
    var fields = value.split(" ")
    if len(fields) < 6:
        return invalid_time()
    var utc = fields[0].byte_length() == 4 and byte_at(fields[0], 3) == 44
    if (utc and len(fields) != 6) or (not utc and fields[0].byte_length() != 3):
        return invalid_time()
    var month_text = fields[2] if utc else fields[1]
    var month = -1
    for index in range(12):
        if month_text == month_name(index):
            month = index
    var day_text = fields[1] if utc else fields[2]
    var day = digits(day_text, 0, day_text.byte_length())
    var year_text = fields[3]
    var negative_year = byte_at(year_text, 0) == 45
    var year_start = 1 if negative_year else 0
    var year = digits(year_text, year_start, year_text.byte_length() - year_start)
    if year < 0 or month < 0 or day < 1 or day > 31:
        return invalid_time()
    if negative_year:
        year = -year
    var clock = fields[4]
    if clock.byte_length() != 8 or byte_at(clock, 2) != 58 or byte_at(clock, 5) != 58:
        return invalid_time()
    var hour = digits(clock, 0, 2)
    var minute = digits(clock, 3, 2)
    var second = digits(clock, 6, 2)
    if hour < 0 or hour > 23 or minute < 0 or minute > 59 or second < 0 or second > 59:
        return invalid_time()
    var offset = 0
    var timezone = fields[5]
    if utc:
        if timezone != "GMT":
            return invalid_time()
    else:
        if timezone.byte_length() != 8 or not has_prefix(timezone, "GMT"):
            return invalid_time()
        var direction = byte_at(timezone, 3)
        var hours = digits(timezone, 4, 2)
        var minutes = digits(timezone, 6, 2)
        if (direction != 43 and direction != 45) or hours < 0 or hours > 23 or minutes < 0 or minutes > 59:
            return invalid_time()
        offset = (hours * 60 + minutes) * (1 if direction == 43 else -1)
        if len(fields) > 6 and (byte_at(fields[6], 0) != 40 or byte_at(value, value.byte_length() - 1) != 41):
            return invalid_time()
    return time_clip(from_components(
        Float64(year), Float64(month), Float64(day), Float64(hour),
        Float64(minute - offset), Float64(second), 0,
    ))


def has_prefix(value: StringSlice, prefix: StringSlice) -> Bool:
    if value.byte_length() < prefix.byte_length():
        return False
    for index in range(prefix.byte_length()):
        if byte_at(value, index) != byte_at(prefix, index):
            return False
    return True


def byte_at(value: StringSlice, position: Int) -> Int:
    if position < 0 or position >= value.byte_length():
        return -1
    return Int(UInt8(value.as_bytes()[position]))


def digits(value: StringSlice, start: Int, count: Int) -> Int:
    if count < 1 or count > 6 or start < 0 or start + count > value.byte_length():
        return -1
    var result = 0
    for index in range(start, start + count):
        var digit = byte_at(value, index) - 48
        if digit < 0 or digit > 9:
            return -1
        result = result * 10 + digit
    return result
