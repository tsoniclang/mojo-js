from std import math


@fieldwise_init
struct DateParts(Copyable):
    var year: Int
    var month: Int
    var day: Int
    var weekday: Int
    var hour: Int
    var minute: Int
    var second: Int
    var millisecond: Int


def invalid_time() -> Float64:
    return Float64(FloatLiteral.nan)


def time_clip(value: Float64) -> Float64:
    if not math.isfinite(value) or math.abs(value) > 8640000000000000.0:
        return invalid_time()
    var result = math.trunc(value)
    return 0.0 if result == 0 else result


def supplied_number(value: Optional[Float64]) -> Float64:
    return value.value() if value else invalid_time()


def constructor_year(value: Float64) -> Float64:
    if not math.isfinite(value):
        return invalid_time()
    var year = math.trunc(value)
    return year + 1900.0 if year >= 0 and year <= 99 else year


def from_components(
    year: Float64,
    month: Float64,
    day: Float64,
    hour: Float64,
    minute: Float64,
    second: Float64,
    millisecond: Float64,
) -> Float64:
    if not (
        math.isfinite(year) and math.isfinite(month) and math.isfinite(day)
        and math.isfinite(hour) and math.isfinite(minute)
        and math.isfinite(second) and math.isfinite(millisecond)
    ):
        return invalid_time()
    var integral_month = math.trunc(month)
    var normalized_year = math.trunc(year) + math.floor(integral_month / 12.0)
    if not math.isfinite(normalized_year):
        return invalid_time()
    var normalized_month = math.remainder(integral_month, 12.0)
    if normalized_month < 0:
        normalized_month += 12.0
    var days = days_from_civil(normalized_year, Int(normalized_month) + 1)
    var day_time = (
        math.trunc(hour) * 3600000.0 + math.trunc(minute) * 60000.0
        + math.trunc(second) * 1000.0 + math.trunc(millisecond)
    )
    return (days + math.trunc(day) - 1.0) * 86400000.0 + day_time


def days_from_civil(year: Float64, month: Int) -> Float64:
    var adjusted_year = year - (1.0 if month <= 2 else 0.0)
    var era = math.floor(adjusted_year / 400.0)
    var year_of_era = adjusted_year - era * 400.0
    var shifted_month = month + (-3 if month > 2 else 9)
    var day_of_year = Float64((153 * shifted_month + 2) / 5)
    var day_of_era = (
        year_of_era * 365.0 + math.floor(year_of_era / 4.0)
        - math.floor(year_of_era / 100.0) + day_of_year
    )
    return era * 146097.0 + day_of_era - 719468.0


def parts(milliseconds: Float64) -> DateParts:
    var total = Int64(milliseconds)
    var days = floor_div64(total, 86400000)
    var within = total - days * 86400000
    var civil = civil_from_days(Int(days))
    var hour = Int(within / 3600000)
    within -= Int64(hour) * 3600000
    var minute = Int(within / 60000)
    within -= Int64(minute) * 60000
    var second = Int(within / 1000)
    return DateParts(
        civil[0], civil[1] - 1, civil[2], floor_mod(Int(days) + 4, 7),
        hour, minute, second, Int(within - Int64(second) * 1000),
    )


def read_part(milliseconds: Float64, field: Int) -> Float64:
    if not math.isfinite(milliseconds):
        return invalid_time()
    var value = parts(milliseconds)
    if field == 0:
        return Float64(value.year)
    if field == 1:
        return Float64(value.month)
    if field == 2:
        return Float64(value.day)
    if field == 3:
        return Float64(value.weekday)
    if field == 4:
        return Float64(value.hour)
    if field == 5:
        return Float64(value.minute)
    if field == 6:
        return Float64(value.second)
    return Float64(value.millisecond)


def changed_parts(
    base: Float64,
    year: Optional[Float64] = None,
    month: Optional[Float64] = None,
    day: Optional[Float64] = None,
    hour: Optional[Float64] = None,
    minute: Optional[Float64] = None,
    second: Optional[Float64] = None,
    millisecond: Optional[Float64] = None,
) -> Float64:
    if not math.isfinite(base):
        return invalid_time()
    var value = parts(base)
    return from_components(
        year.value() if year else Float64(value.year),
        month.value() if month else Float64(value.month),
        day.value() if day else Float64(value.day),
        hour.value() if hour else Float64(value.hour),
        minute.value() if minute else Float64(value.minute),
        second.value() if second else Float64(value.second),
        millisecond.value() if millisecond else Float64(value.millisecond),
    )


def civil_from_days(days: Int) -> Tuple[Int, Int, Int]:
    var shifted = days + 719468
    var era = floor_div(shifted, 146097)
    var day_of_era = shifted - era * 146097
    var year_of_era = (
        day_of_era - day_of_era / 1460 + day_of_era / 36524
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


def floor_div(value: Int, divisor: Int) -> Int:
    var quotient = value / divisor
    return quotient - 1 if value < 0 and value % divisor != 0 else quotient


def floor_mod(value: Int, divisor: Int) -> Int:
    return value - floor_div(value, divisor) * divisor


def floor_div64(value: Int64, divisor: Int64) -> Int64:
    var quotient = value / divisor
    return quotient - 1 if value < 0 and value % divisor != 0 else quotient
