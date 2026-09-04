from std.collections import List
from std.memory import ArcPointer
from tsonic_runtime import RaisingCallable

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
comptime _JSON_PROJECTION = 8


@fieldwise_init
struct _JsonProjectionState:
    var project: RaisingCallable[Tuple[String], JsValue, Error]


struct _JsValueNode(Movable):
    var kind: Int
    var bool_value: Bool
    var number_value: Float64
    var string_value: JsString
    var symbol_value: Optional[JsSymbol]
    var identity: Optional[ArcPointer[Bool]]
    var json_projection: Optional[ArcPointer[_JsonProjectionState]]
    var keys: List[JsString]
    var children: List[Int]

    def __init__(out self, kind: Int):
        self.kind = kind
        self.bool_value = False
        self.number_value = 0
        self.string_value = JsString()
        self.symbol_value = None
        self.identity = None
        self.json_projection = None
        self.keys = List[JsString]()
        self.children = List[Int]()

    def __init__(out self, value: Bool):
        self.kind = _BOOL
        self.bool_value = value
        self.number_value = 0
        self.string_value = JsString()
        self.symbol_value = None
        self.identity = None
        self.json_projection = None
        self.keys = List[JsString]()
        self.children = List[Int]()

    def __init__(out self, value: Float64):
        self.kind = _NUMBER
        self.bool_value = False
        self.number_value = value
        self.string_value = JsString()
        self.symbol_value = None
        self.identity = None
        self.json_projection = None
        self.keys = List[JsString]()
        self.children = List[Int]()

    def __init__(out self, value: JsString):
        self.kind = _STRING
        self.bool_value = False
        self.number_value = 0
        self.string_value = value
        self.symbol_value = None
        self.identity = None
        self.json_projection = None
        self.keys = List[JsString]()
        self.children = List[Int]()

    def __init__(out self, value: JsSymbol):
        self.kind = _SYMBOL
        self.bool_value = False
        self.number_value = 0
        self.string_value = JsString()
        self.symbol_value = Optional[JsSymbol](value)
        self.identity = None
        self.json_projection = None
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
        self.identity = Optional[ArcPointer[Bool]](ArcPointer(False))
        self.json_projection = None
        self.keys = keys^
        self.children = children^

    def __init__(
        out self,
        kind: Int,
        var keys: List[JsString],
        var children: List[Int],
        identity: ArcPointer[Bool],
    ):
        self.kind = kind
        self.bool_value = False
        self.number_value = 0
        self.string_value = JsString()
        self.symbol_value = None
        self.identity = Optional[ArcPointer[Bool]](identity)
        self.json_projection = None
        self.keys = keys^
        self.children = children^

    def __init__(
        out self,
        projection: ArcPointer[_JsonProjectionState],
    ):
        self.kind = _JSON_PROJECTION
        self.bool_value = False
        self.number_value = 0
        self.string_value = JsString()
        self.symbol_value = None
        self.identity = None
        self.json_projection = Optional[ArcPointer[_JsonProjectionState]](
            projection
        )
        self.keys = List[JsString]()
        self.children = List[Int]()


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
        projection: ArcPointer[_JsonProjectionState],
    ):
        var nodes = List[_JsValueNode]()
        nodes.append(_JsValueNode(projection))
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

    def is_json_projection(self) -> Bool:
        return self._kind() == _JSON_PROJECTION

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
        if self.is_array() or self.is_object():
            if self._kind() != other._kind():
                return False
            var left = self._nodes[][self._index].identity
            var right = other._nodes[][other._index].identity
            return Bool(left) and Bool(right) and left.value() is right.value()
        if self.is_json_projection():
            var left = self._nodes[][self._index].json_projection
            var right = other._nodes[][other._index].json_projection
            return (
                other.is_json_projection()
                and Bool(left)
                and Bool(right)
                and left.value() is right.value()
            )
        return self._nodes is other._nodes and self._index == other._index

    def _aggregate_identity(self) raises -> ArcPointer[Bool]:
        var identity = self._nodes[][self._index].identity
        if not identity:
            raise Error("JavaScript value is not an aggregate")
        return identity.value()

    def _json_projection(self) raises -> ArcPointer[_JsonProjectionState]:
        var projection = self._nodes[][self._index].json_projection
        if not projection:
            raise Error("JavaScript value is not a JSON projection")
        return projection.value()

    def _project_json(self, key: String) raises -> Self:
        return self._json_projection()[].project.call((key,))

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
        return self._append(
            _JsValueNode(_OBJECT, keys^, children^, identity)
        )

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
                raise Error(
                    "JavaScript callback object entry has invalid arity"
                )
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


def js_value_from_json_projection(
    project: RaisingCallable[Tuple[String], JsValue, Error]
) -> JsValue:
    return JsValue(ArcPointer(_JsonProjectionState(project)))


def js_value_from_array_values(var values: List[JsValue]) raises -> JsValue:
    var builder = _JsValueBuilder()
    var children = List[Int](capacity=len(values))
    var active = List[JsValue]()
    var copied = List[JsValue]()
    var copied_indexes = List[Int]()
    for value in values^:
        children.append(
            _append_js_value_graph(
                builder, value, active, copied, copied_indexes, 0
            )
        )
    return builder.value(builder.append_array(children^))


def js_value_from_object_entries(
    var keys: List[JsString], var values: List[JsValue]
) raises -> JsValue:
    if len(keys) != len(values):
        raise Error("JavaScript object keys and values have different lengths")
    var builder = _JsValueBuilder()
    var copied_keys = List[JsString](capacity=len(keys))
    var children = List[Int](capacity=len(values))
    var active = List[JsValue]()
    var copied = List[JsValue]()
    var copied_indexes = List[Int]()
    for index in range(len(keys)):
        copied_keys.append(keys[index])
        children.append(
            _append_js_value_graph(
                builder,
                values[index],
                active,
                copied,
                copied_indexes,
                0,
            )
        )
    return builder.value(builder.append_object(copied_keys^, children^))


def _append_js_value_graph(
    mut builder: _JsValueBuilder,
    value: JsValue,
    mut active: List[JsValue],
    mut copied: List[JsValue],
    mut copied_indexes: List[Int],
    depth: Int,
) raises -> Int:
    if depth > 512:
        raise Error("JavaScript value graph exceeds its nesting budget")
    if value.is_undefined():
        return builder.append_undefined()
    if value.is_null():
        return builder.append_null()
    if value.is_bool():
        return builder.append_bool(value._bool_value())
    if value.is_number():
        return builder.append_number(value._number_value())
    if value.is_string():
        return builder.append_string(value._string_value())
    if value.is_symbol():
        return builder.append_symbol(value.symbol_value())
    if value.is_json_projection():
        return builder.append_json_projection(value._json_projection())
    for ancestor in active:
        if ancestor.same_identity(value):
            raise Error("cyclic JavaScript value cannot be materialized")
    for index in range(len(copied)):
        if copied[index].same_identity(value):
            return copied_indexes[index]
    active.append(value)
    if value.is_array():
        var children = List[Int](capacity=value.array_length())
        for index in range(value.array_length()):
            children.append(
                _append_js_value_graph(
                    builder,
                    value.array_at(index),
                    active,
                    copied,
                    copied_indexes,
                    depth + 1,
                )
            )
        _ = active.pop()
        var target = builder.append_array(
            children^, value._aggregate_identity()
        )
        copied.append(value)
        copied_indexes.append(target)
        return target
    if value.is_object():
        var keys = List[JsString](capacity=value.object_length())
        var children = List[Int](capacity=value.object_length())
        for index in range(value.object_length()):
            keys.append(value.object_key(index))
            children.append(
                _append_js_value_graph(
                    builder,
                    value.object_value(index),
                    active,
                    copied,
                    copied_indexes,
                    depth + 1,
                )
            )
        _ = active.pop()
        var target = builder.append_object(
            keys^, children^, value._aggregate_identity()
        )
        copied.append(value)
        copied_indexes.append(target)
        return target
    _ = active.pop()
    raise Error("JavaScript value graph contains an unsupported node")


def js_value_error(message: String) raises -> JsValue:
    var builder = _JsValueBuilder()
    var keys = List[JsString]()
    var children = List[Int]()
    keys.append(JsString("name"))
    children.append(builder.append_string(JsString("Error")))
    keys.append(JsString("message"))
    children.append(builder.append_string(JsString(message)))
    return builder.value(builder.append_object(keys^, children^))


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
            raise Error("JavaScript JSON projections cannot be structured-cloned")
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
        var description = (
            value._nodes[][value._index].symbol_value.value().description()
        )
        return (
            JsString("Symbol(")
            + description.value()
            + JsString(")") if description else JsString("Symbol()")
        )
    if value.is_json_projection():
        return JsString("[JSON projection]")
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
        return (
            left._nodes[][left._index]
            .symbol_value.value()
            .same(right._nodes[][right._index].symbol_value.value())
        )
    return False
