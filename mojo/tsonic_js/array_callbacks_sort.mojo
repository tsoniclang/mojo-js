from std.collections import List
from .array import JsArray
from .array_values import array_value_is_undefined


def array_sort_zero[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def() raises CallbackError -> Float64,
](array: JsArray[T], callback: Callback,) raises CallbackError -> JsArray[T]:
    var original_length = len(array)
    var undefined = _undefined_values(array)
    var defined = _defined_values(array)
    for index in range(1, len(defined)):
        var value = defined[index].copy()
        var position = index
        while position > 0 and callback() > 0:
            defined[position] = defined[position - 1].copy()
            position -= 1
        defined[position] = value^
    _replace_defined(array, defined^, undefined^, original_length)
    return array


def array_sort_value[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T) raises CallbackError -> Float64,
](array: JsArray[T], callback: Callback,) raises CallbackError -> JsArray[T]:
    var original_length = len(array)
    var undefined = _undefined_values(array)
    var defined = _defined_values(array)
    for index in range(1, len(defined)):
        var value = defined[index].copy()
        var position = index
        while position > 0 and callback(defined[position - 1].copy()) > 0:
            defined[position] = defined[position - 1].copy()
            position -= 1
        defined[position] = value^
    _replace_defined(array, defined^, undefined^, original_length)
    return array


def array_sort_compare[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T, T) raises CallbackError -> Float64,
](array: JsArray[T], callback: Callback,) raises CallbackError -> JsArray[T]:
    var original_length = len(array)
    var undefined = _undefined_values(array)
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
    _replace_defined(array, defined^, undefined^, original_length)
    return array


def _defined_values[T: Copyable & Deinitable](array: JsArray[T]) -> List[T]:
    var values = List[T]()
    for current in array._elements[]:
        if current and not array_value_is_undefined(current.value()):
            values.append(current.value().copy())
    return values^


def _undefined_values[T: Copyable & Deinitable](array: JsArray[T]) -> List[T]:
    var values = List[T]()
    for current in array._elements[]:
        if current and array_value_is_undefined(current.value()):
            values.append(current.value().copy())
    return values^


def _replace_defined[
    T: Copyable & Deinitable
](array: JsArray[T], var values: List[T], var undefined: List[T], length: Int):
    var index = 0
    for value in values^:
        array.set(index, value.copy())
        index += 1
    for value in undefined^:
        array.set(index, value.copy())
        index += 1
    while index < length:
        _ = array.delete(Float64(index))
        index += 1
