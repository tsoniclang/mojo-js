from std.collections import List
from std.memory import ArcPointer
from ..string import JsString
from .model import JsValue, _JsValueNode, _ARRAY, _OBJECT, _SYMBOL, _JSON_PROJECTION, _BOOL, _NUMBER, _STRING


def js_value_structured_clone(value: JsValue) raises -> JsValue:
    var reachable = List[Bool](capacity=len(value._nodes[]))
    var remapped = List[Int](capacity=len(value._nodes[]))
    for _ in range(len(value._nodes[])):
        reachable.append(False)
        remapped.append(-1)
    var pending = List[Int]()
    pending.append(value._index)
    while len(pending) != 0:
        var index = pending.pop()
        if index < 0 or index >= len(value._nodes[]):
            raise Error("JavaScript value graph contains an invalid reference")
        if reachable[index]:
            continue
        reachable[index] = True
        var kind = value._nodes[][index].kind
        if kind == _ARRAY or kind == _OBJECT:
            for child in value._nodes[][index].children:
                pending.append(child)

    var nodes = List[_JsValueNode](capacity=len(value._nodes[]))
    for index in range(len(value._nodes[])):
        if not reachable[index]:
            continue
        var kind = value._nodes[][index].kind
        if kind == _SYMBOL:
            raise Error("JavaScript symbols cannot be structured-cloned")
        if kind == _JSON_PROJECTION:
            raise Error(
                "JavaScript JSON projections cannot be structured-cloned"
            )
        remapped[index] = len(nodes)
        if kind == _BOOL:
            nodes.append(_JsValueNode(value._nodes[][index].bool_value))
        elif kind == _NUMBER:
            nodes.append(_JsValueNode(value._nodes[][index].number_value))
        elif kind == _STRING:
            nodes.append(_JsValueNode(value._nodes[][index].string_value))
        elif kind == _ARRAY or kind == _OBJECT:
            var keys = List[JsString](capacity=len(value._nodes[][index].keys))
            for key in value._nodes[][index].keys:
                keys.append(key)
            var children = List[Int](
                capacity=len(value._nodes[][index].children)
            )
            for child in value._nodes[][index].children:
                if child < 0 or child >= index or remapped[child] < 0:
                    raise Error(
                        "JavaScript value graph is not in canonical order"
                    )
                children.append(remapped[child])
            nodes.append(_JsValueNode(kind, keys^, children^))
        else:
            nodes.append(_JsValueNode(kind))
    return JsValue(ArcPointer(nodes^), remapped[value._index])

