from std.collections import List
from std.memory import ArcPointer

from .boolean import boolean_to_string
from .number import number_to_string
from .string import JsString


comptime _UNDEFINED = 0
comptime _NULL = 1
comptime _BOOL = 2
comptime _NUMBER = 3
comptime _STRING = 4
comptime _ARRAY = 5
comptime _OBJECT = 6


struct _JsValueNode(Movable):
    var kind: Int
    var bool_value: Bool
    var number_value: Float64
    var string_value: JsString
    var keys: List[JsString]
    var children: List[Int]

    def __init__(out self, kind: Int):
        self.kind = kind
        self.bool_value = False
        self.number_value = 0
        self.string_value = JsString()
        self.keys = List[JsString]()
        self.children = List[Int]()

    def __init__(out self, value: Bool):
        self.kind = _BOOL
        self.bool_value = value
        self.number_value = 0
        self.string_value = JsString()
        self.keys = List[JsString]()
        self.children = List[Int]()

    def __init__(out self, value: Float64):
        self.kind = _NUMBER
        self.bool_value = False
        self.number_value = value
        self.string_value = JsString()
        self.keys = List[JsString]()
        self.children = List[Int]()

    def __init__(out self, value: JsString):
        self.kind = _STRING
        self.bool_value = False
        self.number_value = 0
        self.string_value = value
        self.keys = List[JsString]()
        self.children = List[Int]()

    def __init__(
        out self,
        kind: Int,
        var keys: List[JsString],
        var children: List[Int],
    ):
        self.kind = kind
        self.bool_value = False
        self.number_value = 0
        self.string_value = JsString()
        self.keys = keys^
        self.children = children^


struct JsValue(ImplicitlyCopyable):
    var _nodes: ArcPointer[List[_JsValueNode]]
    var _index: Int

    def __init__(out self):
        var nodes = List[_JsValueNode]()
        nodes.append(_JsValueNode(_UNDEFINED))
        self._nodes = ArcPointer(nodes^)
        self._index = 0

    def __init__(out self, value: Bool):
        var nodes = List[_JsValueNode]()
        nodes.append(_JsValueNode(value))
        self._nodes = ArcPointer(nodes^)
        self._index = 0

    def __init__(out self, value: Float64):
        var nodes = List[_JsValueNode]()
        nodes.append(_JsValueNode(value))
        self._nodes = ArcPointer(nodes^)
        self._index = 0

    def __init__(out self, value: JsString):
        var nodes = List[_JsValueNode]()
        nodes.append(_JsValueNode(value))
        self._nodes = ArcPointer(nodes^)
        self._index = 0

    def __init__(
        out self,
        nodes: ArcPointer[List[_JsValueNode]],
        index: Int,
    ):
        self._nodes = nodes
        self._index = index

    @staticmethod
    def null() -> Self:
        var nodes = List[_JsValueNode]()
        nodes.append(_JsValueNode(_NULL))
        return Self(ArcPointer(nodes^), 0)

    @staticmethod
    def undefined() -> Self:
        return Self()

    def is_undefined(self) -> Bool:
        return self._kind() == _UNDEFINED

    def is_null(self) -> Bool:
        return self._kind() == _NULL

    def is_bool(self) -> Bool:
        return self._kind() == _BOOL

    def is_number(self) -> Bool:
        return self._kind() == _NUMBER

    def is_string(self) -> Bool:
        return self._kind() == _STRING

    def is_array(self) -> Bool:
        return self._kind() == _ARRAY

    def is_object(self) -> Bool:
        return self._kind() == _OBJECT

    def bool_value(self) raises -> Bool:
        if not self.is_bool():
            raise Error("JavaScript value is not a boolean")
        return self._bool_value()

    def number_value(self) raises -> Float64:
        if not self.is_number():
            raise Error("JavaScript value is not a number")
        return self._number_value()

    def string_value(self) raises -> JsString:
        if not self.is_string():
            raise Error("JavaScript value is not a string")
        return self._string_value()

    def array_length(self) raises -> Int:
        if not self.is_array():
            raise Error("JavaScript value is not an array")
        return len(self._nodes[][self._index].children)

    def array_at(self, index: Int) raises -> Self:
        var length = self.array_length()
        if index < 0 or index >= length:
            raise Error("JavaScript array index is out of range")
        return Self(
            self._nodes,
            self._nodes[][self._index].children[index],
        )

    def object_length(self) raises -> Int:
        if not self.is_object():
            raise Error("JavaScript value is not an object")
        return len(self._nodes[][self._index].keys)

    def object_key(self, index: Int) raises -> JsString:
        var length = self.object_length()
        if index < 0 or index >= length:
            raise Error("JavaScript object entry is out of range")
        return self._nodes[][self._index].keys[index]

    def object_value(self, index: Int) raises -> Self:
        var length = self.object_length()
        if index < 0 or index >= length:
            raise Error("JavaScript object entry is out of range")
        return Self(
            self._nodes,
            self._nodes[][self._index].children[index],
        )

    def object_has_own(self, key: JsString) raises -> Bool:
        var length = self.object_length()
        for index in range(length):
            if self._nodes[][self._index].keys[index] == key:
                return True
        return False

    def same_identity(self, other: Self) -> Bool:
        return self._nodes is other._nodes and self._index == other._index

    def _kind(self) -> Int:
        return self._nodes[][self._index].kind

    def _bool_value(self) -> Bool:
        return self._nodes[][self._index].bool_value

    def _number_value(self) -> Float64:
        return self._nodes[][self._index].number_value

    def _string_value(self) -> JsString:
        return self._nodes[][self._index].string_value

    def _node_index(self) -> Int:
        return self._index

    def _storage(self) -> ArcPointer[List[_JsValueNode]]:
        return self._nodes


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

    def append_array(mut self, var children: List[Int]) raises -> Int:
        return self._append(_JsValueNode(_ARRAY, List[JsString](), children^))

    def append_object(
        mut self,
        var keys: List[JsString],
        var children: List[Int],
    ) raises -> Int:
        return self._append(_JsValueNode(_OBJECT, keys^, children^))

    def value(self, index: Int) -> JsValue:
        return JsValue(self._nodes, index)

    def _append(mut self, var node: _JsValueNode) raises -> Int:
        if len(self._nodes[]) >= 1048576:
            raise Error("JavaScript value graph exceeds its node budget")
        var index = len(self._nodes[])
        self._nodes[].append(node^)
        return index


def js_value_from_bool(value: Bool) -> JsValue:
    return JsValue(value)


def js_value_from_number(value: Float64) -> JsValue:
    return JsValue(value)


def js_value_from_string(value: JsString) -> JsValue:
    return JsValue(value)


def js_value_from_null() -> JsValue:
    return JsValue.null()


def js_value_from_undefined() -> JsValue:
    return JsValue.undefined()


def js_value_to_string(value: JsValue) -> JsString:
    if value.is_undefined():
        return JsString("undefined")
    if value.is_null():
        return JsString("null")
    if value.is_bool():
        return boolean_to_string(value._bool_value())
    if value.is_number():
        return number_to_string(value._number_value())
    if value.is_string():
        return value._string_value()
    if value.is_object():
        return JsString("[object Object]")
    var result = JsString()
    for index in range(len(value._nodes[][value._index].children)):
        if index != 0:
            result += JsString(",")
        var child = JsValue(
            value._nodes,
            value._nodes[][value._index].children[index],
        )
        if not child.is_null() and not child.is_undefined():
            result += js_value_to_string(child)
    return result


def js_truthy(value: JsValue) -> Bool:
    if value.is_undefined() or value.is_null():
        return False
    if value.is_bool():
        return value._bool_value()
    if value.is_number():
        var number = value._number_value()
        return number != 0 and number == number
    if value.is_string():
        return len(value._string_value()) != 0
    return True
