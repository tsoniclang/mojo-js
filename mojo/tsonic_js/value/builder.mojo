from std.collections import List
from std.memory import ArcPointer
from ..string import JsString
from ..symbol import JsSymbol
from .model import JsValue, _JsValueNode, _SourceValueView, _UNDEFINED, _NULL, _ARRAY, _OBJECT


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

    def append_array(mut self, var children: List[Int]) raises -> Int:
        return self._append(_JsValueNode(_ARRAY, List[JsString](), children^))

    def append_source_view(mut self, kind: Int, view: ArcPointer[_SourceValueView]) raises -> Int:
        if kind != _ARRAY and kind != _OBJECT:
            raise Error("Closed source view must be an array or object")
        return self._append(_JsValueNode(kind, view))

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

    def set_aggregate_children(mut self, index: Int, var children: List[Int]) raises:
        if index < 0 or index >= len(self._nodes[]):
            raise Error("JavaScript value graph contains an invalid aggregate")
        var kind = self._nodes[][index].kind
        if kind != _ARRAY and kind != _OBJECT:
            raise Error("JavaScript value graph node is not an aggregate")
        if kind == _OBJECT and len(self._nodes[][index].keys) != len(children):
            raise Error("JavaScript object keys and values have different lengths")
        for child in children:
            if kind == _ARRAY and child == -1:
                continue
            if child < 0 or child >= len(self._nodes[]):
                raise Error("JavaScript value graph contains an invalid reference")
        self._nodes[][index].children = children^

    def _append(mut self, var node: _JsValueNode) raises -> Int:
        if len(self._nodes[]) >= 1048576:
            raise Error("JavaScript value graph exceeds its node budget")
        var index = len(self._nodes[])
        self._nodes[].append(node^)
        return index
