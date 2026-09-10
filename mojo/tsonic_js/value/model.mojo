from std.collections import List
from std.memory import ArcPointer
from tsonic_runtime import Callable, RaisingCallable, WeakReferenceIdentity
from ..boolean import boolean_to_string
from ..number import number_to_string
from ..string import JsString
from ..symbol import JsSymbol
from .byte_view import JsByteView


comptime _UNDEFINED = 0


comptime _NULL = 1


comptime _BOOL = 2


comptime _NUMBER = 3


comptime _STRING = 4


comptime _ARRAY = 5


comptime _OBJECT = 6


comptime _SYMBOL = 7

comptime _BYTE_VIEW = 8

comptime _BIGINT = 9


@fieldwise_init
struct _NativeValuePresentation:
    var brand: String
    var to_json: RaisingCallable[Tuple[String], JsValue, Error]
    var to_string: Callable[Tuple[], JsString]
    var inspect: Callable[Tuple[Int], String]


@fieldwise_init
struct _SourceValueView:
    var identity: WeakReferenceIdentity
    var prototype_identity: String
    var length: Callable[Tuple[], Int]
    var key: Optional[Callable[Tuple[Int], JsString]]
    var has: Optional[Callable[Tuple[Int], Bool]]
    var value: Callable[Tuple[Int], JsValue]
    var to_json: Optional[RaisingCallable[Tuple[String], JsValue, Error]]
    var property_reader: Optional[
        RaisingCallable[Tuple[JsString], JsValue, Error]
    ]


struct _JsValueNode(Movable):
    var kind: Int
    var bool_value: Bool
    var number_value: Float64
    var string_value: JsString
    var symbol_value: Optional[JsSymbol]
    var identity: Optional[ArcPointer[Bool]]
    var source_view: Optional[ArcPointer[_SourceValueView]]
    var byte_view: Optional[JsByteView]
    var native_presentation: Optional[ArcPointer[_NativeValuePresentation]]
    var keys: List[JsString]
    var children: List[Int]

    def __init__(out self, kind: Int):
        self.kind = kind
        self.bool_value = False
        self.number_value = 0
        self.string_value = JsString()
        self.symbol_value = None
        self.identity = None
        self.source_view = None
        self.byte_view = None
        self.native_presentation = None
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

    def __init__(out self, kind: Int, view: ArcPointer[_SourceValueView]):
        self = Self(kind)
        self.source_view = Optional[ArcPointer[_SourceValueView]](view)

    def __init__(
        out self,
        view: JsByteView,
        presentation: Optional[ArcPointer[_NativeValuePresentation]] = None,
    ):
        self = Self(_BYTE_VIEW)
        self.byte_view = view
        self.native_presentation = presentation
        self.identity = view.identity


def _require_bigint_digits(value: JsString) raises:
    var length = len(value)
    if length == 0:
        raise Error("Bigint digits must be canonical signed decimal text")
    var start = 1 if value.code_unit_at(0).value() == 45 else 0
    if start == length:
        raise Error("Bigint digits must be canonical signed decimal text")
    if value.code_unit_at(start).value() == 48 and (start != 0 or length != 1):
        raise Error("Bigint digits must be canonical signed decimal text")
    for index in range(start, length):
        var digit = value.code_unit_at(index).value()
        if digit < 48 or digit > 57:
            raise Error("Bigint digits must be canonical signed decimal text")


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

    @staticmethod
    def bigint(value: JsString) raises -> Self:
        _require_bigint_digits(value)
        return Self._from_bigint_digits(value)

    @staticmethod
    def _from_bigint_digits(value: JsString) -> Self:
        var node = _JsValueNode(value)
        node.kind = _BIGINT
        var nodes = List[_JsValueNode]()
        nodes.append(node^)
        return Self(ArcPointer(nodes^), 0)

    def is_undefined(self) -> Bool:
        return self._kind() == _UNDEFINED

    def type_of(self) -> String:
        if self.is_undefined():
            return "undefined"
        if self.is_bool():
            return "boolean"
        if self.is_number():
            return "number"
        if self.is_bigint():
            return "bigint"
        if self.is_string():
            return "string"
        if self.is_symbol():
            return "symbol"
        return "object"

    def is_null(self) -> Bool:
        return self._kind() == _NULL

    def is_bool(self) -> Bool:
        return self._kind() == _BOOL

    def is_number(self) -> Bool:
        return self._kind() == _NUMBER

    def is_bigint(self) -> Bool:
        return self._kind() == _BIGINT

    def is_string(self) -> Bool:
        return self._kind() == _STRING

    def is_symbol(self) -> Bool:
        return self._kind() == _SYMBOL

    def is_array(self) -> Bool:
        return self._kind() == _ARRAY

    def is_object(self) -> Bool:
        return self._kind() == _OBJECT or self._kind() == _BYTE_VIEW

    def is_byte_view(self) -> Bool:
        return self._kind() == _BYTE_VIEW

    def byte_view(self) raises -> JsByteView:
        if not self.is_byte_view():
            raise Error("JavaScript value is not an unsigned byte view")
        var view = self._nodes[][self._index].byte_view.value()
        view.validate()
        return view

    def has_native_brand(self, brand: String) -> Bool:
        var presentation = self._nodes[][self._index].native_presentation
        return Bool(presentation) and presentation.value()[].brand == brand

    def same_prototype(self, other: Self) -> Bool:
        if self._kind() != other._kind():
            return False
        if self.is_byte_view():
            var left = self._nodes[][self._index].native_presentation
            var right = other._nodes[][other._index].native_presentation
            if Bool(left) != Bool(right):
                return False
            return not left or left.value()[].brand == right.value()[].brand
        var left = self._nodes[][self._index].source_view
        var right = other._nodes[][other._index].source_view
        var left_identity = (
            left.value()[].prototype_identity if left else String()
        )
        var right_identity = (
            right.value()[].prototype_identity if right else String()
        )
        return left_identity == right_identity

    def has_selected_to_json(self) -> Bool:
        if self._nodes[][self._index].native_presentation:
            return True
        var view = self._nodes[][self._index].source_view
        return Bool(view) and Bool(view.value()[].to_json)

    def bool_value(self) raises -> Bool:
        if not self.is_bool():
            raise Error("JavaScript value is not a boolean")
        return self._bool_value()

    def number_value(self) raises -> Float64:
        if not self.is_number():
            raise Error("JavaScript value is not a number")
        return self._number_value()

    def bigint_value(self) raises -> JsString:
        if not self.is_bigint():
            raise Error("JavaScript value is not a bigint")
        return self._string_value()

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
        if self.is_byte_view():
            self._nodes[][self._index].byte_view.value().validate()
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

    def property_get(self, key: JsString) raises -> Self:
        var own = self.object_get(key)
        if own:
            return own.value()
        if self.is_byte_view() and (
            key == JsString("length") or key == JsString("byteLength")
        ):
            return Self(Float64(self.byte_view().length))
        if self.is_byte_view() and key == JsString("byteOffset"):
            return Self(Float64(self.byte_view().offset))
        var view = self._nodes[][self._index].source_view
        if view and view.value()[].property_reader:
            return view.value()[].property_reader.value().call((key,))
        return Self()

    def array_property(self, index: Int) raises -> Self:
        var length = self.array_length()
        if index < 0 or index >= length:
            return Self()
        return self._aggregate_value(index)

    def same_identity(self, other: Self) -> Bool:
        if self.is_array() or self.is_object():
            if self._kind() != other._kind():
                return False
            return self._identity_address() == other._identity_address()
        return self._nodes is other._nodes and self._index == other._index

    def _aggregate_identity(self) raises -> ArcPointer[Bool]:
        var identity = self._nodes[][self._index].identity
        if not identity:
            raise Error("JavaScript value is not an aggregate")
        return identity.value()

    def _project_json(self, key: String) raises -> Self:
        var native = self._nodes[][self._index].native_presentation
        if native:
            return native.value()[].to_json.call((key,))
        var view = self._nodes[][self._index].source_view
        if not view or not view.value()[].to_json:
            raise Error("Source value has no selected toJSON operation")
        return view.value()[].to_json.value().call((key,))

    def _aggregate_length(self) -> Int:
        if self.is_byte_view():
            return self._nodes[][self._index].byte_view.value().length
        var view = self._nodes[][self._index].source_view
        return view.value()[].length.call(()) if view else len(
            self._nodes[][self._index].children
        )

    def _aggregate_key(self, index: Int) -> JsString:
        if self.is_byte_view():
            return JsString(String(index))
        var view = self._nodes[][self._index].source_view
        return (
            view.value()[]
            .key.value()
            .call((index,)) if view else self._nodes[][self._index]
            .keys[index]
        )

    def _aggregate_value(self, index: Int) -> Self:
        if self.is_byte_view():
            var bytes = self._nodes[][self._index].byte_view.value()
            return Self(Float64(bytes.storage[][bytes.offset + index]))
        if self.is_array() and not self._aggregate_has(index):
            return Self()
        var view = self._nodes[][self._index].source_view
        return view.value()[].value.call((index,)) if view else Self(
            self._nodes, self._nodes[][self._index].children[index]
        )

    def _aggregate_has(self, index: Int) -> Bool:
        var view = self._nodes[][self._index].source_view
        return (
            view.value()[]
            .has.value()
            .call((index,)) if view else self._nodes[][self._index]
            .children[index]
            != -1
        )

    def _identity_address(self) -> UInt:
        var view = self._nodes[][self._index].source_view
        if view:
            return view.value()[].identity.address
        var identity = self._nodes[][self._index].identity
        return UInt(Int(identity.value().ptr()))

    def _weak_identity(self) -> WeakReferenceIdentity:
        var view = self._nodes[][self._index].source_view
        if view:
            return view.value()[].identity
        var identity = self._nodes[][self._index].identity
        return WeakReferenceIdentity(identity.value())

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
    if value.is_bigint():
        return value._string_value()
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
    if value.is_byte_view():
        var presentation = value._nodes[][value._index].native_presentation
        if presentation:
            return presentation.value()[].to_string.call(())
        var text = String()
        var bytes = value._nodes[][value._index].byte_view.value()
        for index in range(bytes.length):
            if index:
                text += ","
            text += String(bytes.storage[][bytes.offset + index])
        return JsString(text)
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
    if value.is_bigint():
        return value._string_value() != JsString("0")
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
