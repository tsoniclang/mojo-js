from std.collections import List, Set
from ..number import number_to_string
from ..string import JsString
from ..value import JsValue
from .limits import _MAX_JSON_INPUT_UNITS


def json_property_list(value: JsValue) raises -> List[JsString]:
    var length = value.array_length()
    if length > _MAX_JSON_INPUT_UNITS:
        raise Error("JSON property list exceeds its input budget")
    var result = List[JsString]()
    var seen = Set[JsString]()
    for index in range(length):
        var entry = value.array_property(index)
        var key = JsString()
        if entry.is_string():
            key = entry.string_value()
        elif entry.is_number():
            key = number_to_string(entry.number_value())
        else:
            continue
        if key not in seen:
            seen.add(key)
            result.append(key)
    return result
