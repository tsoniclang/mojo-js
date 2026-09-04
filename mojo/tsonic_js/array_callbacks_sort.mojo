from std.collections import List
from .array import JsArray


def array_sort_zero[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def() raises CallbackError -> Float64,
](
    mut array: JsArray[T],
    callback: Callback,
) raises CallbackError -> JsArray[
    T
]:
    var defined = _defined_values(array)
    for index in range(1, len(defined)):
        var value = defined[index].copy()
        var position = index
        while position > 0 and callback() > 0:
            defined[position] = defined[position - 1].copy()
            position -= 1
        defined[position] = value^
    _replace_defined(array, defined^)
    return array


def array_sort_value[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T) raises CallbackError -> Float64,
](
    mut array: JsArray[T],
    callback: Callback,
) raises CallbackError -> JsArray[
    T
]:
    var defined = _defined_values(array)
    for index in range(1, len(defined)):
        var value = defined[index].copy()
        var position = index
        while position > 0 and callback(defined[position - 1].copy()) > 0:
            defined[position] = defined[position - 1].copy()
            position -= 1
        defined[position] = value^
    _replace_defined(array, defined^)
    return array


def array_sort_compare[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T, T) raises CallbackError -> Float64,
](
    mut array: JsArray[T],
    callback: Callback,
) raises CallbackError -> JsArray[
    T
]:
    var defined = _defined_values(array)
    for index in range(1, len(defined)):
        var value = defined[index].copy()
        var position = index
        while (
            position > 0
            and callback(defined[position - 1].copy(), value.copy()) > 0
        ):
            defined[position] = defined[position - 1].copy()
            position -= 1
        defined[position] = value^
    _replace_defined(array, defined^)
    return array


def _defined_values[T: Copyable & Deinitable](array: JsArray[T]) -> List[T]:
    var values = List[T]()
    for current in array._elements[]:
        if current:
            values.append(current.value().copy())
    return values^


def _replace_defined[
    T: Copyable & Deinitable
](mut array: JsArray[T], var values: List[T]):
    var sorted = List[Optional[T]](capacity=len(array))
    for value in values^:
        sorted.append(Optional[T](value.copy()))
    while len(sorted) < len(array):
        sorted.append(None)
    array._elements[] = sorted^
