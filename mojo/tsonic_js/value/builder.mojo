from std.collections import List
from std.memory import ArcPointer
from ..string import JsString
from ..symbol import JsSymbol
from .model import JsValue, _JsValueNode, _JsonProjectionState, _UNDEFINED, _NULL, _ARRAY, _OBJECT


struct _JsValueBuilder(ImplicitlyCopyable):
    var _nodes: ArcPointer[List[_JsValueNode]]

    def __init__(out self):
        self._nodes = ArcPointer(List[_JsValueNode]())

    def append_undefined(mut self) raises -> Int:
        return self._append(_JsValueNode(_UNDEFINED))

    def append_null(mut self) raises -> Int:
        return self._append(_JsValueNode(_NULL))

    def append_bool(mut self, value: Bool) raises -> Int:
        return self._append(_JsValueNode(value))

    def append_number(mut self, value: Float64) raises -> Int:
        return self._append(_JsValueNode(value))

    def append_string(mut self, value: JsString) raises -> Int:
        return self._append(_JsValueNode(value))

    def append_symbol(mut self, value: JsSymbol) raises -> Int:
        return self._append(_JsValueNode(value))

    def append_json_projection(
        mut self, projection: ArcPointer[_JsonProjectionState]
    ) raises -> Int:
        return self._append(_JsValueNode(projection))

    def append_array(mut self, var children: List[Int]) raises -> Int:
        return self._append(_JsValueNode(_ARRAY, List[JsString](), children^))

    def append_array(
        mut self, var children: List[Int], identity: ArcPointer[Bool]
    ) raises -> Int:
        return self._append(
            _JsValueNode(_ARRAY, List[JsString](), children^, identity)
        )

    def append_object(
        mut self,
        var keys: List[JsString],
        var children: List[Int],
    ) raises -> Int:
        return self._append(_JsValueNode(_OBJECT, keys^, children^))

    def append_object(
        mut self,
        var keys: List[JsString],
        var children: List[Int],
        identity: ArcPointer[Bool],
    ) raises -> Int:
        return self._append(_JsValueNode(_OBJECT, keys^, children^, identity))

    def value(self, index: Int) -> JsValue:
        return JsValue(self._nodes, index)

    def _append(mut self, var node: _JsValueNode) raises -> Int:
        if len(self._nodes[]) >= 1048576:
            raise Error("JavaScript value graph exceeds its node budget")
        var index = len(self._nodes[])
        self._nodes[].append(node^)
        return index

