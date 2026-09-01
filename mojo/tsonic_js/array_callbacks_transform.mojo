from std.collections import List
from tsonic_runtime import RaisingCallable

from .array import JsArray


def array_map_zero[
    U: Copyable & Deinitable,
    T: Copyable & Deinitable,
](array: JsArray[T], callback: RaisingCallable[Tuple[], U]) raises -> JsArray[
    U
]:
    var result = List[Optional[U]](capacity=len(array))
    for index in range(len(array)):
        var current = array._elements[][index].copy()
        result.append(Optional[U](callback.call(())) if current else None)
    return JsArray[U](elements=result^)


def array_map_value[
    U: Copyable & Deinitable,
    T: Copyable & Deinitable,
](array: JsArray[T], callback: RaisingCallable[Tuple[T], U]) raises -> JsArray[
    U
]:
    var result = List[Optional[U]](capacity=len(array))
    for index in range(len(array)):
        var current = array._elements[][index].copy()
        result.append(
            Optional[U](
                callback.call((current.value().copy(),))
            ) if current else None
        )
    return JsArray[U](elements=result^)


def array_map_with_index[
    U: Copyable & Deinitable,
    T: Copyable & Deinitable,
](
    array: JsArray[T], callback: RaisingCallable[Tuple[T, Float64], U]
) raises -> JsArray[U]:
    var result = List[Optional[U]](capacity=len(array))
    for index in range(len(array)):
        var current = array._elements[][index].copy()
        result.append(
            Optional[U](
                callback.call((current.value().copy(), Float64(index)))
            ) if current else None
        )
    return JsArray[U](elements=result^)


def array_map_with_array[
    U: Copyable & Deinitable,
    T: Copyable & Deinitable,
](
    array: JsArray[T],
    callback: RaisingCallable[Tuple[T, Float64, JsArray[T]], U],
) raises -> JsArray[U]:
    var result = List[Optional[U]](capacity=len(array))
    for index in range(len(array)):
        var current = array._elements[][index].copy()
        result.append(
            Optional[U](
                callback.call((current.value().copy(), Float64(index), array))
            ) if current else None
        )
    return JsArray[U](elements=result^)


def array_for_each_zero[
    R: Movable & Deinitable,
    T: Copyable & Deinitable,
](array: JsArray[T], callback: RaisingCallable[Tuple[], R]) raises:
    for index in range(len(array)):
        if array._elements[][index]:
            _ = callback.call(())


def array_for_each_value[
    R: Movable & Deinitable,
    T: Copyable & Deinitable,
](array: JsArray[T], callback: RaisingCallable[Tuple[T], R]) raises:
    for index in range(len(array)):
        var current = array._elements[][index].copy()
        if current:
            _ = callback.call((current.value().copy(),))


def array_for_each_value_index[
    R: Movable & Deinitable,
    T: Copyable & Deinitable,
](array: JsArray[T], callback: RaisingCallable[Tuple[T, Float64], R]) raises:
    for index in range(len(array)):
        var current = array._elements[][index].copy()
        if current:
            _ = callback.call((current.value().copy(), Float64(index)))


def array_for_each_with_array[
    R: Movable & Deinitable,
    T: Copyable & Deinitable,
](
    array: JsArray[T],
    callback: RaisingCallable[Tuple[T, Float64, JsArray[T]], R],
) raises:
    for index in range(len(array)):
        var current = array._elements[][index].copy()
        if current:
            _ = callback.call((current.value().copy(), Float64(index), array))


def array_filter_zero[
    T: Copyable & Deinitable
](
    array: JsArray[T], callback: RaisingCallable[Tuple[], Bool]
) raises -> JsArray[T]:
    var result = List[Optional[T]]()
    for index in range(len(array)):
        var current = array._elements[][index].copy()
        if current and callback.call(()):
            result.append(current.copy())
    return JsArray[T](elements=result^)


def array_filter_value[
    T: Copyable & Deinitable
](
    array: JsArray[T], callback: RaisingCallable[Tuple[T], Bool]
) raises -> JsArray[T]:
    var result = List[Optional[T]]()
    for index in range(len(array)):
        var current = array._elements[][index].copy()
        if current and callback.call((current.value().copy(),)):
            result.append(current.copy())
    return JsArray[T](elements=result^)


def array_filter_with_index[
    T: Copyable & Deinitable
](
    array: JsArray[T], callback: RaisingCallable[Tuple[T, Float64], Bool]
) raises -> JsArray[T]:
    var result = List[Optional[T]]()
    for index in range(len(array)):
        var current = array._elements[][index].copy()
        if current and callback.call((current.value().copy(), Float64(index))):
            result.append(current.copy())
    return JsArray[T](elements=result^)


def array_filter_with_array[
    T: Copyable & Deinitable
](
    array: JsArray[T],
    callback: RaisingCallable[Tuple[T, Float64, JsArray[T]], Bool],
) raises -> JsArray[T]:
    var result = List[Optional[T]]()
    for index in range(len(array)):
        var current = array._elements[][index].copy()
        if current and callback.call(
            (current.value().copy(), Float64(index), array)
        ):
            result.append(current.copy())
    return JsArray[T](elements=result^)
