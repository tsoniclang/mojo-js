from std import math
from std.memory import ArcPointer
from std.utils import Variant
from tsonic_runtime import Null

from ..string import JsString
from .arithmetic import changed_parts, read_part, supplied_number, time_clip
from .formatting import (
    iso_string, local_date_string, local_string, local_time_string, utc_string,
)
from .timezone import local_time, utc_time, zone_offset


struct JsDate(ImplicitlyCopyable):
    var _milliseconds: ArcPointer[Float64]

    def __init__(out self, milliseconds: Float64):
        self._milliseconds = ArcPointer(time_clip(milliseconds))

    def get_time(self) -> Float64:
        return self._milliseconds[]

    def value_of(self) -> Float64:
        return self.get_time()

    def set_time(mut self, value: Float64) -> Float64:
        self._milliseconds[] = time_clip(value)
        return self.get_time()

    def get_utc_full_year(self) -> Float64:
        return read_part(self.get_time(), 0)

    def get_full_year(self) raises -> Float64:
        return read_part(local_time(self.get_time()), 0)

    def get_utc_month(self) -> Float64:
        return read_part(self.get_time(), 1)

    def get_month(self) raises -> Float64:
        return read_part(local_time(self.get_time()), 1)

    def get_utc_date(self) -> Float64:
        return read_part(self.get_time(), 2)

    def get_date(self) raises -> Float64:
        return read_part(local_time(self.get_time()), 2)

    def get_utc_day(self) -> Float64:
        return read_part(self.get_time(), 3)

    def get_day(self) raises -> Float64:
        return read_part(local_time(self.get_time()), 3)

    def get_utc_hours(self) -> Float64:
        return read_part(self.get_time(), 4)

    def get_hours(self) raises -> Float64:
        return read_part(local_time(self.get_time()), 4)

    def get_utc_minutes(self) -> Float64:
        return read_part(self.get_time(), 5)

    def get_minutes(self) raises -> Float64:
        return read_part(local_time(self.get_time()), 5)

    def get_utc_seconds(self) -> Float64:
        return read_part(self.get_time(), 6)

    def get_seconds(self) raises -> Float64:
        return read_part(local_time(self.get_time()), 6)

    def get_utc_milliseconds(self) -> Float64:
        return read_part(self.get_time(), 7)

    def get_milliseconds(self) raises -> Float64:
        return read_part(local_time(self.get_time()), 7)

    def get_timezone_offset(self) raises -> Float64:
        return (0.0 - zone_offset(self.get_time())) / 60000.0

    def set_utc_milliseconds(
        mut self,
        millisecond: Float64,
    ) -> Float64:
        var base = self.get_time()
        var changed = changed_parts(
            base,
            millisecond=millisecond,
        )
        return self.set_time(changed)

    def set_milliseconds(
        mut self,
        millisecond: Float64,
    ) raises -> Float64:
        var base = self.get_time()
        base = local_time(base)
        var changed = changed_parts(
            base,
            millisecond=millisecond,
        )
        return self.set_time(utc_time(changed))

    def set_utc_seconds(
        mut self,
        second: Float64,
    ) -> Float64:
        var base = self.get_time()
        var changed = changed_parts(
            base,
            second=second,
        )
        return self.set_time(changed)

    def set_utc_seconds(
        mut self,
        second: Float64,
        millisecond: Optional[Float64],
    ) -> Float64:
        var base = self.get_time()
        var changed = changed_parts(
            base,
            second=second,
            millisecond=supplied_number(millisecond),
        )
        return self.set_time(changed)

    def set_seconds(
        mut self,
        second: Float64,
    ) raises -> Float64:
        var base = self.get_time()
        base = local_time(base)
        var changed = changed_parts(
            base,
            second=second,
        )
        return self.set_time(utc_time(changed))

    def set_seconds(
        mut self,
        second: Float64,
        millisecond: Optional[Float64],
    ) raises -> Float64:
        var base = self.get_time()
        base = local_time(base)
        var changed = changed_parts(
            base,
            second=second,
            millisecond=supplied_number(millisecond),
        )
        return self.set_time(utc_time(changed))

    def set_utc_minutes(
        mut self,
        minute: Float64,
    ) -> Float64:
        var base = self.get_time()
        var changed = changed_parts(
            base,
            minute=minute,
        )
        return self.set_time(changed)

    def set_utc_minutes(
        mut self,
        minute: Float64,
        second: Optional[Float64],
    ) -> Float64:
        var base = self.get_time()
        var changed = changed_parts(
            base,
            minute=minute,
            second=supplied_number(second),
        )
        return self.set_time(changed)

    def set_utc_minutes(
        mut self,
        minute: Float64,
        second: Optional[Float64],
        millisecond: Optional[Float64],
    ) -> Float64:
        var base = self.get_time()
        var changed = changed_parts(
            base,
            minute=minute,
            second=supplied_number(second),
            millisecond=supplied_number(millisecond),
        )
        return self.set_time(changed)

    def set_minutes(
        mut self,
        minute: Float64,
    ) raises -> Float64:
        var base = self.get_time()
        base = local_time(base)
        var changed = changed_parts(
            base,
            minute=minute,
        )
        return self.set_time(utc_time(changed))

    def set_minutes(
        mut self,
        minute: Float64,
        second: Optional[Float64],
    ) raises -> Float64:
        var base = self.get_time()
        base = local_time(base)
        var changed = changed_parts(
            base,
            minute=minute,
            second=supplied_number(second),
        )
        return self.set_time(utc_time(changed))

    def set_minutes(
        mut self,
        minute: Float64,
        second: Optional[Float64],
        millisecond: Optional[Float64],
    ) raises -> Float64:
        var base = self.get_time()
        base = local_time(base)
        var changed = changed_parts(
            base,
            minute=minute,
            second=supplied_number(second),
            millisecond=supplied_number(millisecond),
        )
        return self.set_time(utc_time(changed))

    def set_utc_hours(
        mut self,
        hour: Float64,
    ) -> Float64:
        var base = self.get_time()
        var changed = changed_parts(
            base,
            hour=hour,
        )
        return self.set_time(changed)

    def set_utc_hours(
        mut self,
        hour: Float64,
        minute: Optional[Float64],
    ) -> Float64:
        var base = self.get_time()
        var changed = changed_parts(
            base,
            hour=hour,
            minute=supplied_number(minute),
        )
        return self.set_time(changed)

    def set_utc_hours(
        mut self,
        hour: Float64,
        minute: Optional[Float64],
        second: Optional[Float64],
    ) -> Float64:
        var base = self.get_time()
        var changed = changed_parts(
            base,
            hour=hour,
            minute=supplied_number(minute),
            second=supplied_number(second),
        )
        return self.set_time(changed)

    def set_utc_hours(
        mut self,
        hour: Float64,
        minute: Optional[Float64],
        second: Optional[Float64],
        millisecond: Optional[Float64],
    ) -> Float64:
        var base = self.get_time()
        var changed = changed_parts(
            base,
            hour=hour,
            minute=supplied_number(minute),
            second=supplied_number(second),
            millisecond=supplied_number(millisecond),
        )
        return self.set_time(changed)

    def set_hours(
        mut self,
        hour: Float64,
    ) raises -> Float64:
        var base = self.get_time()
        base = local_time(base)
        var changed = changed_parts(
            base,
            hour=hour,
        )
        return self.set_time(utc_time(changed))

    def set_hours(
        mut self,
        hour: Float64,
        minute: Optional[Float64],
    ) raises -> Float64:
        var base = self.get_time()
        base = local_time(base)
        var changed = changed_parts(
            base,
            hour=hour,
            minute=supplied_number(minute),
        )
        return self.set_time(utc_time(changed))

    def set_hours(
        mut self,
        hour: Float64,
        minute: Optional[Float64],
        second: Optional[Float64],
    ) raises -> Float64:
        var base = self.get_time()
        base = local_time(base)
        var changed = changed_parts(
            base,
            hour=hour,
            minute=supplied_number(minute),
            second=supplied_number(second),
        )
        return self.set_time(utc_time(changed))

    def set_hours(
        mut self,
        hour: Float64,
        minute: Optional[Float64],
        second: Optional[Float64],
        millisecond: Optional[Float64],
    ) raises -> Float64:
        var base = self.get_time()
        base = local_time(base)
        var changed = changed_parts(
            base,
            hour=hour,
            minute=supplied_number(minute),
            second=supplied_number(second),
            millisecond=supplied_number(millisecond),
        )
        return self.set_time(utc_time(changed))

    def set_utc_date(
        mut self,
        day: Float64,
    ) -> Float64:
        var base = self.get_time()
        var changed = changed_parts(
            base,
            day=day,
        )
        return self.set_time(changed)

    def set_date(
        mut self,
        day: Float64,
    ) raises -> Float64:
        var base = self.get_time()
        base = local_time(base)
        var changed = changed_parts(
            base,
            day=day,
        )
        return self.set_time(utc_time(changed))

    def set_utc_month(
        mut self,
        month: Float64,
    ) -> Float64:
        var base = self.get_time()
        var changed = changed_parts(
            base,
            month=month,
        )
        return self.set_time(changed)

    def set_utc_month(
        mut self,
        month: Float64,
        day: Optional[Float64],
    ) -> Float64:
        var base = self.get_time()
        var changed = changed_parts(
            base,
            month=month,
            day=supplied_number(day),
        )
        return self.set_time(changed)

    def set_month(
        mut self,
        month: Float64,
    ) raises -> Float64:
        var base = self.get_time()
        base = local_time(base)
        var changed = changed_parts(
            base,
            month=month,
        )
        return self.set_time(utc_time(changed))

    def set_month(
        mut self,
        month: Float64,
        day: Optional[Float64],
    ) raises -> Float64:
        var base = self.get_time()
        base = local_time(base)
        var changed = changed_parts(
            base,
            month=month,
            day=supplied_number(day),
        )
        return self.set_time(utc_time(changed))

    def set_utc_full_year(
        mut self,
        year: Float64,
    ) -> Float64:
        var base = self.get_time()
        if not math.isfinite(base):
            base = 0.0
        var changed = changed_parts(
            base,
            year=year,
        )
        return self.set_time(changed)

    def set_utc_full_year(
        mut self,
        year: Float64,
        month: Optional[Float64],
    ) -> Float64:
        var base = self.get_time()
        if not math.isfinite(base):
            base = 0.0
        var changed = changed_parts(
            base,
            year=year,
            month=supplied_number(month),
        )
        return self.set_time(changed)

    def set_utc_full_year(
        mut self,
        year: Float64,
        month: Optional[Float64],
        day: Optional[Float64],
    ) -> Float64:
        var base = self.get_time()
        if not math.isfinite(base):
            base = 0.0
        var changed = changed_parts(
            base,
            year=year,
            month=supplied_number(month),
            day=supplied_number(day),
        )
        return self.set_time(changed)

    def set_full_year(
        mut self,
        year: Float64,
    ) raises -> Float64:
        var base = self.get_time()
        if not math.isfinite(base):
            base = 0.0
        else:
            base = local_time(base)
        var changed = changed_parts(
            base,
            year=year,
        )
        return self.set_time(utc_time(changed))

    def set_full_year(
        mut self,
        year: Float64,
        month: Optional[Float64],
    ) raises -> Float64:
        var base = self.get_time()
        if not math.isfinite(base):
            base = 0.0
        else:
            base = local_time(base)
        var changed = changed_parts(
            base,
            year=year,
            month=supplied_number(month),
        )
        return self.set_time(utc_time(changed))

    def set_full_year(
        mut self,
        year: Float64,
        month: Optional[Float64],
        day: Optional[Float64],
    ) raises -> Float64:
        var base = self.get_time()
        if not math.isfinite(base):
            base = 0.0
        else:
            base = local_time(base)
        var changed = changed_parts(
            base,
            year=year,
            month=supplied_number(month),
            day=supplied_number(day),
        )
        return self.set_time(utc_time(changed))

    def to_iso_string(self) raises -> JsString:
        return JsString(iso_string(self.get_time()))

    def to_json(self) raises -> Variant[JsString, Null]:
        if not math.isfinite(self.get_time()):
            return Variant[JsString, Null](Null())
        return Variant[JsString, Null](self.to_iso_string())

    def to_utc_string(self) -> JsString:
        return JsString(utc_string(self.get_time()))

    def to_string(self) raises -> JsString:
        return JsString(local_string(self.get_time()))

    def to_date_string(self) raises -> JsString:
        return JsString(local_date_string(self.get_time()))

    def to_time_string(self) raises -> JsString:
        return JsString(local_time_string(self.get_time()))
