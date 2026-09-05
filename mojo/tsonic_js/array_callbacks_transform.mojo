from std.collections import List
from .array import JsArray


def array_map_zero[
    U: Copyable & Deinitable,
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def() raises CallbackError -> U,
](array: JsArray[T], callback: Callback) raises CallbackError -> JsArray[U]:
    var result = List[Optional[U]](capacity=len(array))
    for index in range(len(array)):
        var current = array._elements[][index].copy()
        result.append(Optional[U](callback()) if current else None)
    return JsArray[U](elements=result^)


def array_map_value[
    U: Copyable & Deinitable,
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T) raises CallbackError -> U,
](array: JsArray[T], callback: Callback) raises CallbackError -> JsArray[U]:
    var result = List[Optional[U]](capacity=len(array))
    for index in range(len(array)):
        var current = array._elements[][index].copy()
        result.append(
            Optional[U](callback(current.value().copy())) if current else None
        )
    return JsArray[U](elements=result^)


def array_map_with_index[
    U: Copyable & Deinitable,
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T, Float64) raises CallbackError -> U,
](array: JsArray[T], callback: Callback,) raises CallbackError -> JsArray[U]:
    var result = List[Optional[U]](capacity=len(array))
    for index in range(len(array)):
        var current = array._elements[][index].copy()
        result.append(
            Optional[U](
                callback(current.value().copy(), Float64(index))
            ) if current else None
        )
    return JsArray[U](elements=result^)


def array_map_with_array[
    U: Copyable & Deinitable,
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T, Float64, JsArray[T]) raises CallbackError -> U,
](array: JsArray[T], callback: Callback,) raises CallbackError -> JsArray[U]:
    var result = List[Optional[U]](capacity=len(array))
    for index in range(len(array)):
        var current = array._elements[][index].copy()
        result.append(
            Optional[U](
                callback(current.value().copy(), Float64(index), array)
            ) if current else None
        )
    return JsArray[U](elements=result^)


def array_for_each_zero[
    R: Movable & Deinitable,
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def() raises CallbackError -> R,
](array: JsArray[T], callback: Callback) raises CallbackError:
    for index in range(len(array)):
        if array._elements[][index]:
            _ = callback()


def array_for_each_value[
    R: Movable & Deinitable,
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T) raises CallbackError -> R,
](array: JsArray[T], callback: Callback) raises CallbackError:
    for index in range(len(array)):
        var current = array._elements[][index].copy()
        if current:
            _ = callback(current.value().copy())


def array_for_each_value_index[
    R: Movable & Deinitable,
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T, Float64) raises CallbackError -> R,
](array: JsArray[T], callback: Callback,) raises CallbackError:
    for index in range(len(array)):
        var current = array._elements[][index].copy()
        if current:
            _ = callback(current.value().copy(), Float64(index))


def array_for_each_with_array[
    R: Movable & Deinitable,
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T, Float64, JsArray[T]) raises CallbackError -> R,
](array: JsArray[T], callback: Callback,) raises CallbackError:
    for index in range(len(array)):
        var current = array._elements[][index].copy()
        if current:
            _ = callback(current.value().copy(), Float64(index), array)


def array_filter_zero[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def() raises CallbackError -> Bool,
](array: JsArray[T], callback: Callback) raises CallbackError -> JsArray[T]:
    var result = List[Optional[T]]()
    for index in range(len(array)):
        var current = array._elements[][index].copy()
        if current and callback():
            result.append(current.copy())
    return JsArray[T](elements=result^)


def array_filter_value[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T) raises CallbackError -> Bool,
](array: JsArray[T], callback: Callback) raises CallbackError -> JsArray[T]:
    var result = List[Optional[T]]()
    for index in range(len(array)):
        var current = array._elements[][index].copy()
        if current and callback(current.value().copy()):
            result.append(current.copy())
    return JsArray[T](elements=result^)


def array_filter_with_index[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T, Float64) raises CallbackError -> Bool,
](array: JsArray[T], callback: Callback,) raises CallbackError -> JsArray[T]:
    var result = List[Optional[T]]()
    for index in range(len(array)):
        var current = array._elements[][index].copy()
        if current and callback(current.value().copy(), Float64(index)):
            result.append(current.copy())
    return JsArray[T](elements=result^)


def array_filter_with_array[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T, Float64, JsArray[T]) raises CallbackError -> Bool,
](array: JsArray[T], callback: Callback,) raises CallbackError -> JsArray[T]:
    var result = List[Optional[T]]()
    for index in range(len(array)):
        var current = array._elements[][index].copy()
        if current and callback(current.value().copy(), Float64(index), array):
            result.append(current.copy())
    return JsArray[T](elements=result^)
