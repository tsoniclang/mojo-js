from std.collections import List
from .array import JsArray
from .map import JsMap
from .set import JsSet
from .string import JsString


def array_new[T: Copyable & Deinitable](*items: T) -> JsArray[T]:
    var values = List[T](capacity=len(items))
    for item in items:
        values.append(item.copy())
    return JsArray[T](values^)


def array_from[T: Copyable & Deinitable](values: JsArray[T]) -> JsArray[T]:
    return values.copy()


def array_from(values: JsString) -> JsArray[JsString]:
    return JsArray[JsString](values.iter_values())


def array_from_map_value[
    T: Copyable & Deinitable,
    U: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T) raises CallbackError -> U,
](values: JsArray[T], callback: Callback) raises CallbackError -> JsArray[U]:
    var result = List[U]()
    for value in values.iter_values():
        result.append(callback(value.copy()))
    return JsArray[U](result^)


def array_from_map_with_index[
    T: Copyable & Deinitable,
    U: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T, Float64) raises CallbackError -> U,
](values: JsArray[T], callback: Callback,) raises CallbackError -> JsArray[U]:
    var result = List[U]()
    var index = 0
    for value in values.iter_values():
        result.append(callback(value.copy(), Float64(index)))
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
](entries: JsArray[Tuple[K, V]]) -> JsMap[K, V]:
    var result = JsMap[K, V]()
    for index in range(len(entries)):
        try:
            var entry = entries[Float64(index)]
            _ = result.set(entry[0].copy(), entry[1].copy())
        except:
            pass
    return result


def set_new[T: Copyable & Deinitable & Equatable]() -> JsSet[T]:
    return JsSet[T]()


def set_new[
    T: Copyable & Deinitable & Equatable
](values: JsArray[T]) -> JsSet[T]:
    var result = JsSet[T]()
    for index in range(len(values)):
        try:
            _ = result.add(values[Float64(index)])
        except:
            pass
    return result


def set_new(values: JsString) -> JsSet[JsString]:
    var result = JsSet[JsString]()
    for value in values.iter_values():
        _ = result.add(value)
    return result
