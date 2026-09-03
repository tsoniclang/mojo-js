from std.collections import List
from std.memory import ArcPointer

from .boolean import boolean_to_string
from .number import number_to_string
from .string import JsString
from .symbol import JsSymbol


comptime _UNDEFINED = 0
comptime _NULL = 1
comptime _BOOL = 2
comptime _NUMBER = 3
comptime _STRING = 4
comptime _ARRAY = 5
comptime _OBJECT = 6
comptime _SYMBOL = 7


struct _JsValueNode(Movable):
    var kind: Int
    var bool_value: Bool
    var number_value: Float64
    var string_value: JsString
    var symbol_value: Optional[JsSymbol]
    var keys: List[JsString]
    var children: List[Int]

    def __init__(out self, kind: Int):
        self.kind = kind
        self.bool_value = False
        self.number_value = 0
        self.string_value = JsString()
        self.symbol_value = None
        self.keys = List[JsString]()
        self.children = List[Int]()

    def __init__(out self, value: Bool):
        self.kind = _BOOL
        self.bool_value = value
        self.number_value = 0
        self.string_value = JsString()
        self.symbol_value = None
        self.keys = List[JsString]()
        self.children = List[Int]()

    def __init__(out self, value: Float64):
        self.kind = _NUMBER
        self.bool_value = False
        self.number_value = value
        self.string_value = JsString()
        self.symbol_value = None
        self.keys = List[JsString]()
        self.children = List[Int]()

    def __init__(out self, value: JsString):
        self.kind = _STRING
        self.bool_value = False
        self.number_value = 0
        self.string_value = value
        self.symbol_value = None
        self.keys = List[JsString]()
        self.children = List[Int]()

    def __init__(out self, value: JsSymbol):
        self.kind = _SYMBOL
        self.bool_value = False
        self.number_value = 0
        self.string_value = JsString()
        self.symbol_value = Optional[JsSymbol](value)
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
        self.symbol_value = None
        self.keys = keys^
        self.children = children^


struct JsValue(ImplicitlyCopyable, Writable):
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

    def __init__(out self, value: JsSymbol):
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

    def write_to(self, mut writer: Some[Writer]):
        writer.write(js_value_to_string(self))

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

    def is_symbol(self) -> Bool:
        return self._kind() == _SYMBOL

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

    def symbol_value(self) raises -> JsSymbol:
        if not self.is_symbol():
            raise Error("JavaScript value is not a symbol")
        return self._nodes[][self._index].symbol_value.value()

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

    def object_get(self, key: JsString) raises -> Optional[Self]:
        var length = self.object_length()
        for index in range(length):
            if self._nodes[][self._index].keys[index] == key:
                return Optional[Self](
                    Self(
                        self._nodes,
                        self._nodes[][self._index].children[index],
                    )
                )
        return None

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

    def append_symbol(mut self, value: JsSymbol) raises -> Int:
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


def _js_value_from_tagged_callback_argument(value: JsValue) raises -> JsValue:
    var builder = _JsValueBuilder()
    var root = _append_tagged_callback_argument(builder, value)
    return builder.value(root)


def _append_tagged_callback_argument(
    mut builder: _JsValueBuilder, value: JsValue
) raises -> Int:
    var kind = _required_tagged_field(value, "kind").string_value()
    if kind == JsString("undefined"):
        return builder.append_undefined()
    if kind == JsString("null"):
        return builder.append_null()
    if kind == JsString("boolean"):
        return builder.append_bool(
            _required_tagged_field(value, "value").bool_value()
        )
    if kind == JsString("number"):
        return builder.append_number(
            _required_tagged_field(value, "value").number_value()
        )
    if kind == JsString("string"):
        return builder.append_string(
            _required_tagged_field(value, "value").string_value()
        )
    if kind == JsString("object"):
        var entries = _required_tagged_field(value, "entries")
        var keys = List[JsString]()
        var children = List[Int]()
        for index in range(entries.array_length()):
            var entry = entries.array_at(index)
            if entry.array_length() != 2:
                raise Error("JavaScript callback object entry has invalid arity")
            keys.append(entry.array_at(0).string_value())
            children.append(
                _append_tagged_callback_argument(builder, entry.array_at(1))
            )
        return builder.append_object(keys^, children^)
    raise Error("JavaScript callback argument has an unsupported tagged kind")


def _required_tagged_field(value: JsValue, name: String) raises -> JsValue:
    var field = value.object_get(JsString(name))
    if not field:
        raise Error("JavaScript callback argument is missing field " + name)
    return field.value()


def js_value_from_bool(value: Bool) -> JsValue:
    return JsValue(value)


def js_value_from_number(value: Float64) -> JsValue:
    return JsValue(value)


def js_value_from_string(value: JsString) -> JsValue:
    return JsValue(value)


def js_value_from_symbol(value: JsSymbol) -> JsValue:
    return JsValue(value)


def js_value_from_null() -> JsValue:
    return JsValue.null()


def js_value_from_undefined() -> JsValue:
    return JsValue.undefined()


def js_value_error(message: String) raises -> JsValue:
    var builder = _JsValueBuilder()
    var keys = List[JsString]()
    var children = List[Int]()
    keys.append(JsString("name"))
    children.append(builder.append_string(JsString("Error")))
    keys.append(JsString("message"))
    children.append(builder.append_string(JsString(message)))
    return builder.value(builder.append_object(keys^, children^))


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
    if value.is_symbol():
        var description = value.symbol_value().description()
        return (
            JsString("Symbol(") + description.value() + JsString(")")
            if description
            else JsString("Symbol()")
        )
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


def js_event_key_equal(left: JsValue, right: JsValue) -> Bool:
    if left.is_string() and right.is_string():
        return left._string_value() == right._string_value()
    if left.is_symbol() and right.is_symbol():
        return left._nodes[][left._index].symbol_value.value().same(
            right._nodes[][right._index].symbol_value.value()
        )
    return False
