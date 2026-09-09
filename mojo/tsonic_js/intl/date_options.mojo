from std import math
from ..value import JsValue
from .options import boolean_option, option_value, option_string, string_option, unicode_type_option


def _selection(options: JsValue, name: String, choices: String, patterns: String) raises -> String:
    var value = option_value(options, name)
    if value.is_undefined():
        return String()
    var selected = option_string(value, "")
    var values = choices.split("|")
    var targets = patterns.split("|")
    for index in range(len(values)):
        if selected == values[index]:
            return String(targets[index])
    raise Error("Invalid date option: ", name)


def _style(options: JsValue, name: String) raises -> Int32:
    var value = _selection(options, name, "full|long|medium|short", "0|1|2|3")
    return Int32(-1) if value == "" else Int32(Int(value))


struct DateOptions(Movable):
    var skeleton: String
    var zone: String
    var has_zone: Bool
    var calendar: String
    var numbering: String
    var date_style: Int32
    var time_style: Int32
    var hour12: Int32
    var hour_cycle: String
    var basic: Bool

    def __init__(out self, options: JsValue, required: String) raises:
        var matcher = string_option(options, "localeMatcher", "best fit")
        if matcher != "lookup" and matcher != "best fit":
            raise Error("Locale matcher must be lookup or best fit")
        self.calendar = unicode_type_option(options, "calendar")
        self.numbering = unicode_type_option(options, "numberingSystem")
        self.hour12 = boolean_option(options, "hour12")
        self.hour_cycle = _selection(options, "hourCycle", "h11|h12|h23|h24", "h11|h12|h23|h24")
        var zone = option_value(options, "timeZone")
        self.has_zone = not zone.is_undefined()
        self.zone = option_string(zone, "")
        if self.has_zone and (self.zone == "" or len(self.zone.as_bytes()) > 511 or "\0" in self.zone):
            raise Error("Invalid time-zone identifier")
        var weekday = _selection(options, "weekday", "long|short|narrow", "EEEE|EEE|EEEEE")
        var era = _selection(options, "era", "long|short|narrow", "GGGG|G|GGGGG")
        var year = _selection(options, "year", "numeric|2-digit", "y|yy")
        var month = _selection(options, "month", "numeric|2-digit|long|short|narrow", "M|MM|MMMM|MMM|MMMMM")
        var day = _selection(options, "day", "numeric|2-digit", "d|dd")
        var period = _selection(options, "dayPeriod", "long|short|narrow", "BBBB|B|BBBBB")
        var hour = _selection(options, "hour", "numeric|2-digit", "j|jj")
        var minute = _selection(options, "minute", "numeric|2-digit", "m|mm")
        var second = _selection(options, "second", "numeric|2-digit", "s|ss")
        var fraction = String()
        var digits = option_value(options, "fractionalSecondDigits")
        if not digits.is_undefined():
            if not digits.is_number() or not (digits.number_value() >= 1 and digits.number_value() <= 3):
                raise Error("fractionalSecondDigits must be between one and three")
            for _ in range(Int(math.floor(digits.number_value()))):
                fraction += "S"
        var zone_name = _selection(options, "timeZoneName", "long|short|shortOffset|longOffset|shortGeneric|longGeneric", "zzzz|z|O|OOOO|v|vvvv")
        var format_matcher = string_option(options, "formatMatcher", "best fit")
        if format_matcher != "best fit" and format_matcher != "basic":
            raise Error("Date formatMatcher must be basic or best fit")
        self.basic = format_matcher == "basic"
        self.date_style = _style(options, "dateStyle")
        self.time_style = _style(options, "timeStyle")
        self.skeleton = weekday + era + year + month + day + period + hour + minute + second + fraction + zone_name
        if self.date_style != -1 or self.time_style != -1:
            if self.skeleton != "":
                raise Error("Date styles cannot be combined with component options")
            if required == "date" and self.time_style != -1:
                raise Error("toLocaleDateString cannot select timeStyle")
            if required == "time" and self.date_style != -1:
                raise Error("toLocaleTimeString cannot select dateStyle")
        else:
            var need_defaults = True
            if required != "time" and (weekday != "" or year != "" or month != "" or day != ""):
                need_defaults = False
            if required != "date" and (period != "" or hour != "" or minute != "" or second != "" or fraction != ""):
                need_defaults = False
            if need_defaults:
                if required != "time":
                    year = "y"
                    month = "M"
                    day = "d"
                if required != "date":
                    hour = "j"
                    minute = "m"
                    second = "s"
                self.skeleton = weekday + era + year + month + day + period + hour + minute + second + fraction + zone_name
