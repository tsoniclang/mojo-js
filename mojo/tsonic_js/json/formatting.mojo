from std.collections import List
from ..string import JsString


def _number_indent(space: Float64) -> JsString:
    var count = 0
    if space == space and space > 0:
        count = 10 if space >= 10 else Int(space)
    var units = List[UInt16](capacity=count)
    for _ in range(count):
        units.append(32)
    return JsString(code_units=units^)


def _string_indent(space: JsString) -> JsString:
    var count = min(len(space), 10)
    var units = List[UInt16](capacity=count)
    for index in range(count):
        units.append(space.code_unit_at(index).value())
    return JsString(code_units=units^)
