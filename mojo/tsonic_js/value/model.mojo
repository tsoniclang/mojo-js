from std.collections import List
from std.memory import ArcPointer
from tsonic_runtime import Callable, RaisingCallable, WeakReferenceIdentity
from ..boolean import boolean_to_string
from ..number import number_to_string
from ..string import JsString
from ..symbol import JsSymbol


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


@fieldwise_init
struct _SourceValueView:
    var identity: WeakReferenceIdentity
    var length: Callable[Tuple[], Int]
    var key: Optional[Callable[Tuple[Int], JsString]]
    var has: Optional[Callable[Tuple[Int], Bool]]
    var value: Callable[Tuple[Int], JsValue]
    var to_json: Optional[RaisingCallable[Tuple[String], JsValue, Error]]


struct _JsValueNode(Movable):
    var kind: Int
    var bool_value: Bool
    var number_value: Float64
    var string_value: JsString
    var symbol_value: Optional[JsSymbol]
    var identity: Optional[ArcPointer[Bool]]
    var json_projection: Optional[ArcPointer[_JsonProjectionState]]
    var source_view: Optional[ArcPointer[_SourceValueView]]
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
        self.source_view = None
        self.keys = List[JsString]()
        self.children = List[Int]()

    def __init__(out self, value: Bool):
        self = Self(_BOOL)
        self.bool_value = value

    def __init__(out self, value: Float64):
        self = Self(_NUMBER)
        self.number_value = value

    def __init__(out self, value: JsString):
        self = Self(_STRING)
        self.string_value = value

    def __init__(out self, value: JsSymbol):
        self = Self(_SYMBOL)
        self.symbol_value = Optional[JsSymbol](value)

    def __init__(
        out self,
        kind: Int,
        var keys: List[JsString],
        var children: List[Int],
    ):
        self = Self(kind)
        self.identity = Optional[ArcPointer[Bool]](ArcPointer(False))
        self.keys = keys^
        self.children = children^

    def __init__(
        out self,
        kind: Int,
        var keys: List[JsString],
        var children: List[Int],
        identity: ArcPointer[Bool],
    ):
        self = Self(kind)
        self.identity = Optional[ArcPointer[Bool]](identity)
        self.keys = keys^
        self.children = children^

    def __init__(
        out self,
        projection: ArcPointer[_JsonProjectionState],
    ):
        self = Self(_JSON_PROJECTION)
        self.json_projection = Optional[ArcPointer[_JsonProjectionState]](
            projection
        )

    def __init__(out self, kind: Int, view: ArcPointer[_SourceValueView]):
        self = Self(kind)
        self.source_view = Optional[ArcPointer[_SourceValueView]](view)


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

    def has_selected_to_json(self) -> Bool:
        var view = self._nodes[][self._index].source_view
        return self.is_json_projection() or (Bool(view) and Bool(view.value()[].to_json))

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
        return self._aggregate_length()

    def array_at(self, index: Int) raises -> Self:
        var length = self.array_length()
        if index < 0 or index >= length:
            raise Error("JavaScript array index is out of range")
        return self._aggregate_value(index)

    def array_has(self, index: Int) raises -> Bool:
        var length = self.array_length()
        return index >= 0 and index < length and self._aggregate_has(index)

    def object_length(self) raises -> Int:
        if not self.is_object():
            raise Error("JavaScript value is not an object")
        return self._aggregate_length()

    def object_key(self, index: Int) raises -> JsString:
        var length = self.object_length()
        if index < 0 or index >= length:
            raise Error("JavaScript object entry is out of range")
        return self._aggregate_key(index)

    def object_value(self, index: Int) raises -> Self:
        var length = self.object_length()
        if index < 0 or index >= length:
            raise Error("JavaScript object entry is out of range")
        return self._aggregate_value(index)

    def object_has_own(self, key: JsString) raises -> Bool:
        var length = self.object_length()
        for index in range(length):
            if self._aggregate_key(index) == key:
                return True
        return False

    def object_get(self, key: JsString) raises -> Optional[Self]:
        var length = self.object_length()
        for index in range(length):
            if self._aggregate_key(index) == key:
                return Optional[Self](self._aggregate_value(index))
        return None

    def same_identity(self, other: Self) -> Bool:
        if self.is_array() or self.is_object():
            if self._kind() != other._kind():
                return False
            return self._identity_address() == other._identity_address()
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
        var view = self._nodes[][self._index].source_view
        if view:
            var project = view.value()[].to_json
            if not project:
                raise Error("Source value has no selected toJSON operation")
            return project.value().call((key,))
        return self._json_projection()[].project.call((key,))

    def _aggregate_length(self) -> Int:
        var view = self._nodes[][self._index].source_view
        return view.value()[].length.call(()) if view else len(self._nodes[][self._index].children)

    def _aggregate_key(self, index: Int) -> JsString:
        var view = self._nodes[][self._index].source_view
        return view.value()[].key.value().call((index,)) if view else self._nodes[][self._index].keys[index]

    def _aggregate_value(self, index: Int) -> Self:
        if self.is_array() and not self._aggregate_has(index):
            return Self()
        var view = self._nodes[][self._index].source_view
        return view.value()[].value.call((index,)) if view else Self(self._nodes, self._nodes[][self._index].children[index])

    def _aggregate_has(self, index: Int) -> Bool:
        var view = self._nodes[][self._index].source_view
        return view.value()[].has.value().call((index,)) if view else self._nodes[][self._index].children[index] != -1

    def _identity_address(self) -> UInt:
        var view = self._nodes[][self._index].source_view
        if view:
            return view.value()[].identity.address
        var identity = self._nodes[][self._index].identity
        if identity:
            return UInt(Int(identity.value().ptr()))
        var projection = self._nodes[][self._index].json_projection
        return UInt(Int(projection.value().ptr())) if projection else UInt(Int(self._nodes.ptr()))

    def weak_identity(self) -> WeakReferenceIdentity:
        var view = self._nodes[][self._index].source_view
        if view:
            return view.value()[].identity
        var identity = self._nodes[][self._index].identity
        if identity:
            return WeakReferenceIdentity(identity.value())
        return WeakReferenceIdentity(self._nodes[][self._index].json_projection.value())

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
        return JsString("[object Object]")
    if value.is_object():
        return JsString("[object Object]")
    return _array_to_string(value)


def _array_to_string(value: JsValue) -> JsString:
    var result = JsString()
    var arrays = List[JsValue]()
    var indexes = List[Int]()
    arrays.append(value)
    indexes.append(0)
    while len(arrays) != 0:
        var depth = len(arrays) - 1
        var current = arrays[depth]
        var index = indexes[depth]
        if index >= current._aggregate_length():
            _ = arrays.pop()
            _ = indexes.pop()
            continue
        indexes[depth] += 1
        if index != 0:
            result += JsString(",")
        var child = current._aggregate_value(index)
        if child.is_array():
            var recursive = False
            for ancestor in arrays:
                if ancestor.same_identity(child):
                    recursive = True
                    break
            if not recursive:
                arrays.append(child)
                indexes.append(0)
        elif not child.is_null() and not child.is_undefined():
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


def js_truthy_present_result[
    T: Movable & Deinitable,
](var _value: T) -> Bool:
    return True


def js_truthy_absent_result[
    T: Movable & Deinitable,
](var _value: T) -> Bool:
    return False


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
