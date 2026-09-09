from std.collections import List
from .array import JsArray
from .array_values import array_constructor_length
from .map import JsMap
from .set import JsSet
from .string import JsString


def array_new[T: Copyable & Deinitable](items: List[T]) raises -> JsArray[T]:
    if len(items) == 1:
        var length = array_constructor_length(items[0])
        if length:
            var requested = length.value()
            if (
                requested != requested
                or requested < 0
                or requested > 4294967295
            ):
                raise Error("Invalid array length")
            var count = Int(requested)
            if Float64(count) != requested:
                raise Error("Invalid array length")
            var elements = List[Optional[T]](capacity=count)
            for _ in range(count):
                elements.append(None)
            return JsArray[T](elements=elements^)
    return JsArray[T](items.copy())


def array_from[
    T: Copyable & Deinitable
](values: JsArray[T]) raises -> JsArray[T]:
    return JsArray[T](values.iter_values())


def array_from(values: JsString) -> JsArray[JsString]:
    return JsArray[JsString](values.iter_values())


def array_from(values: String) -> JsArray[String]:
    var result = List[String]()
    for codepoint in values.codepoints():
        result.append(String(codepoint))
    return JsArray[String](result^)


def array_join_native[
    T: Copyable & Deinitable & Writable
](values: JsArray[T], separator: String = ",") raises -> String:
    return values.join(JsString(separator)).to_native_strict()


def array_from_map_value[
    T: Copyable & Deinitable,
    U: Copyable & Deinitable,
    Callback: def(T) raises -> U,
](values: JsArray[T], callback: Callback) raises -> JsArray[U]:
    var result = List[U]()
    var index = 0
    while index < len(values):
        result.append(callback(values.read_value(index)))
        index += 1
    return JsArray[U](result^)


def array_from_map_with_index[
    T: Copyable & Deinitable,
    U: Copyable & Deinitable,
    Callback: def(T, Float64) raises -> U,
](values: JsArray[T], callback: Callback,) raises -> JsArray[U]:
    var result = List[U]()
    var index = 0
    while index < len(values):
        result.append(callback(values.read_value(index), Float64(index)))
        index += 1
    return JsArray[U](result^)


def map_new[
    K: Copyable & Deinitable & Equatable,
    V: Copyable & Deinitable,
]() -> JsMap[K, V]:
    return JsMap[K, V]()


def map_new[
    K: Copyable & Deinitable & Equatable,
    V: Copyable & Deinitable,
](entries: JsArray[Tuple[K, V]]) raises -> JsMap[K, V]:
    var result = JsMap[K, V]()
    for index in range(len(entries)):
        var entry = entries.read_value(index)
        _ = result.set(entry[0].copy(), entry[1].copy())
    return result


def set_new[T: Copyable & Deinitable & Equatable]() -> JsSet[T]:
    return JsSet[T]()


def set_new[
    T: Copyable & Deinitable & Equatable
](values: JsArray[T]) raises -> JsSet[T]:
    var result = JsSet[T]()
    for index in range(len(values)):
        _ = result.add(values.read_value(index))
    return result


def set_new(values: JsString) -> JsSet[JsString]:
    var result = JsSet[JsString]()
    for value in values.iter_values():
        _ = result.add(value)
    return result
