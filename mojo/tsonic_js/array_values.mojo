from tsonic_runtime.nullish import Null, Undefined
from std.collections import List

from .boolean import boolean_to_string
from .number import number_to_string
from .string import JsString
from .value import JsValue, js_value_from_undefined, js_value_to_string


def array_value_string[
    T: Copyable & Deinitable & Writable
](value: T) raises -> JsString:
    comptime if T == Float64:
        return number_to_string(rebind[Float64](value))
    elif T == Float32:
        return number_to_string(Float64(rebind[Float32](value)))
    elif T == Bool:
        return boolean_to_string(rebind[Bool](value))
    elif T == String:
        return JsString(rebind[String](value))
    elif T == JsString:
        return rebind[JsString](value)
    elif T == Null:
        return JsString("null")
    elif T == Undefined:
        return JsString("undefined")
    elif T == JsValue:
        return _implicit_value_string(rebind[JsValue](value))
    else:
        comptime assert (
            T == Int
            or T == UInt
            or T == Int8
            or T == UInt8
            or T == Int16
            or T == UInt16
            or T == Int32
            or T == UInt32
            or T == Int64
            or T == UInt64
        ), "Array string conversion requires an exact source value contract"
        return JsString(String(value))


def _implicit_value_string(value: JsValue) raises -> JsString:
    if value.is_symbol():
        raise Error("Cannot convert a Symbol value to a string")
    if not value.is_array():
        return js_value_to_string(value)
    var result = JsString()
    var arrays = List[JsValue]()
    var indexes = List[Int]()
    var lengths = List[Int]()
    arrays.append(value)
    indexes.append(0)
    lengths.append(value.array_length())
    while len(arrays) != 0:
        var depth = len(arrays) - 1
        var index = indexes[depth]
        if index == lengths[depth]:
            _ = arrays.pop()
            _ = indexes.pop()
            _ = lengths.pop()
            continue
        indexes[depth] += 1
        if index != 0:
            result += JsString(",")
        var child = arrays[depth].array_at(index)
        if child.is_symbol():
            raise Error("Cannot convert a Symbol value to a string")
        if child.is_array():
            var recursive = False
            for ancestor in arrays:
                if ancestor.same_identity(child):
                    recursive = True
                    break
            if not recursive:
                arrays.append(child)
                indexes.append(0)
                lengths.append(child.array_length())
        elif not child.is_null() and not child.is_undefined():
            result += js_value_to_string(child)
    return result


def array_present_value[
    T: Copyable & Deinitable
](value: Optional[T]) raises -> T:
    if value:
        return value.value().copy()
    comptime if T == Undefined:
        return rebind[T](Undefined()).copy()
    elif T == JsValue:
        return rebind[T](js_value_from_undefined()).copy()
    else:
        raise Error(
            "JavaScript undefined cannot inhabit this array element type"
        )


def array_constructor_length[
    T: Copyable & Deinitable
](value: T) -> Optional[Float64]:
    comptime if T == Float64:
        return rebind[Float64](value)
    elif T == Float32:
        return Float64(rebind[Float32](value))
    elif T == Int:
        return Float64(rebind[Int](value))
    elif T == UInt:
        return Float64(rebind[UInt](value))
    elif T == Int8:
        return Float64(rebind[Int8](value))
    elif T == UInt8:
        return Float64(rebind[UInt8](value))
    elif T == Int16:
        return Float64(rebind[Int16](value))
    elif T == UInt16:
        return Float64(rebind[UInt16](value))
    elif T == Int32:
        return Float64(rebind[Int32](value))
    elif T == UInt32:
        return Float64(rebind[UInt32](value))
    elif T == Int64:
        return Float64(rebind[Int64](value))
    elif T == UInt64:
        return Float64(rebind[UInt64](value))
    elif T == JsValue:
        var selected = rebind[JsValue](value)
        return selected._number_value() if selected.is_number() else None
    else:
        return None


def array_value_is_nullish[T: Copyable & Deinitable](value: T) -> Bool:
    comptime if T == Null or T == Undefined:
        return True
    elif T == JsValue:
        var selected = rebind[JsValue](value)
        return selected.is_null() or selected.is_undefined()
    else:
        return False


def array_value_is_undefined[T: Copyable & Deinitable](value: T) -> Bool:
    comptime if T == Undefined:
        return True
    elif T == JsValue:
        return rebind[JsValue](value).is_undefined()
    else:
        return False
