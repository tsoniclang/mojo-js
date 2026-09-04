from std.collections import List
from std.memory import bitcast

from .array import JsArray
from .string import JsString
from .value import JsValue


def object_is(left: JsValue, right: JsValue) -> Bool:
    if left.is_undefined() or left.is_null():
        return left._kind() == right._kind()
    if left.is_bool():
        if not right.is_bool():
            return False
        return left._bool_value() == right._bool_value()
    if left.is_number():
        if not right.is_number():
            return False
        var left_number = left._number_value()
        var right_number = right._number_value()
        if left_number != left_number:
            return right_number != right_number
        if left_number == 0 and right_number == 0:
            return bitcast[.uint64](left_number) == bitcast[.uint64](
                right_number
            )
        return left_number == right_number
    if left.is_string():
        if not right.is_string():
            return False
        return left._string_value() == right._string_value()
    if left.is_symbol():
        return (
            right.is_symbol()
            and left._nodes[][left._index]
            .symbol_value.value()
            .same(right._nodes[][right._index].symbol_value.value())
        )
    if left.is_array() or left.is_object():
        return right._kind() == left._kind() and left.same_identity(right)
    return False


def object_keys(value: JsValue) raises -> JsArray[JsString]:
    var keys = List[JsString]()
    for index in _object_key_order(value):
        keys.append(value.object_key(index))
    return JsArray[JsString](keys^)


def object_values(value: JsValue) raises -> JsArray[JsValue]:
    var values = List[JsValue]()
    for index in _object_key_order(value):
        values.append(value.object_value(index))
    return JsArray[JsValue](values^)


def object_entries(value: JsValue) raises -> JsArray[Tuple[JsString, JsValue]]:
    var entries = List[Tuple[JsString, JsValue]]()
    for index in _object_key_order(value):
        entries.append((value.object_key(index), value.object_value(index)))
    return JsArray[Tuple[JsString, JsValue]](entries^)


def object_has_own(value: JsValue, key: JsString) raises -> Bool:
    return value.object_has_own(key)


def _object_key_order(value: JsValue) raises -> List[Int]:
    var integer_indexes = List[UInt32]()
    var integer_entries = List[Int]()
    var other_entries = List[Int]()
    for index in range(value.object_length()):
        var integer = _array_index(value.object_key(index))
        if integer:
            var insertion = len(integer_indexes)
            while (
                insertion > 0
                and integer_indexes[insertion - 1] > integer.value()
            ):
                insertion -= 1
            integer_indexes.insert(insertion, integer.value())
            integer_entries.insert(insertion, index)
        else:
            other_entries.append(index)
    for index in other_entries:
        integer_entries.append(index)
    return integer_entries^


def _array_index(key: JsString) -> Optional[UInt32]:
    if len(key) == 0 or (len(key) > 1 and key.code_unit_at(0) == UInt16(48)):
        return None
    var value = UInt64(0)
    for index in range(len(key)):
        var unit = key.code_unit_at(index)
        if not unit or unit.value() < 48 or unit.value() > 57:
            return None
        value = value * 10 + UInt64(unit.value() - 48)
        if value >= 0xFFFFFFFF:
            return None
    return Optional[UInt32](UInt32(value))
