from std.collections import List
from ..array import JsArray
from ..string import JsString
from .format_part import IntlFormatPart
from .native import IntlResult


def formatted_parts(result: IntlResult) raises -> JsArray[IntlFormatPart]:
    var count = result.part_count()
    var units = result.units()
    var parts = List[IntlFormatPart](capacity=count)
    for index in range(count):
        var bounds = result.part_bounds(index)
        var text = List[UInt16](capacity=bounds[1])
        for offset in range(bounds[1]):
            text.append(units[bounds[0] + offset])
        parts.append(IntlFormatPart(result.part_type(index), JsString(code_units=text^).to_native_strict()))
    return JsArray[IntlFormatPart](parts^)
