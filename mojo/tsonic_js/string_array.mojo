from std.collections import List

from .array import JsArray
from .string import JsString


fn string_split(
    value: JsString,
    separator: JsString,
    limit: Float64 = 4294967295.0,
) -> JsArray[JsString]:
    var output = List[JsString]()
    var maximum = max(min(Int(limit), 4294967295), 0)
    if maximum == 0:
        return JsArray[JsString](output^)
    if len(separator) == 0:
        for index in range(min(len(value), maximum)):
            output.append(value.char_at(Float64(index)))
        return JsArray[JsString](output^)
    var start = 0
    while start <= len(value) and len(output) < maximum:
        var found = Int(value.index_of(separator, Float64(start)))
        if found < 0:
            output.append(value.slice(Float64(start)))
            break
        output.append(value.slice(Float64(start), Float64(found)))
        start = found + len(separator)
    return JsArray[JsString](output^)
