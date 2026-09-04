from .array import JsArray


def array_reduce_initial_zero[
    U: Copyable & Deinitable,
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def() raises CallbackError -> U,
](array: JsArray[T], callback: Callback, initial: U,) raises CallbackError -> U:
    var accumulator = initial.copy()
    for index in range(len(array)):
        if array._elements[][index]:
            accumulator = callback()
    return accumulator^


def array_reduce_initial_accumulator[
    U: Copyable & Deinitable,
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(U) raises CallbackError -> U,
](array: JsArray[T], callback: Callback, initial: U,) raises CallbackError -> U:
    var accumulator = initial.copy()
    for index in range(len(array)):
        if array._elements[][index]:
            accumulator = callback(accumulator^)
    return accumulator^


def array_reduce_initial_value[
    U: Copyable & Deinitable,
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(U, T) raises CallbackError -> U,
](array: JsArray[T], callback: Callback, initial: U,) raises CallbackError -> U:
    var accumulator = initial.copy()
    for index in range(len(array)):
        var current = array._elements[][index].copy()
        if current:
            accumulator = callback(accumulator^, current.value().copy())
    return accumulator^


def array_reduce_initial_with_index[
    U: Copyable & Deinitable,
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(U, T, Float64) raises CallbackError -> U,
](array: JsArray[T], callback: Callback, initial: U,) raises CallbackError -> U:
    var accumulator = initial.copy()
    for index in range(len(array)):
        var current = array._elements[][index].copy()
        if current:
            accumulator = callback(
                accumulator^, current.value().copy(), Float64(index)
            )
    return accumulator^


def array_reduce_initial_with_array[
    U: Copyable & Deinitable,
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(U, T, Float64, JsArray[T]) raises CallbackError -> U,
](array: JsArray[T], callback: Callback, initial: U,) raises CallbackError -> U:
    var accumulator = initial.copy()
    for index in range(len(array)):
        var current = array._elements[][index].copy()
        if current:
            accumulator = callback(
                accumulator^, current.value().copy(), Float64(index), array
            )
    return accumulator^


def array_reduce_from_first_zero[
    T: Copyable & Deinitable,
    Callback: def() raises -> T,
](array: JsArray[T], callback: Callback) raises -> T:
    var first = _first_present(array)
    var accumulator = array._elements[][first].copy().value().copy()
    for index in range(first + 1, len(array)):
        if array._elements[][index]:
            accumulator = callback()
    return accumulator^


def array_reduce_from_first_accumulator[
    T: Copyable & Deinitable,
    Callback: def(T) raises -> T,
](array: JsArray[T], callback: Callback) raises -> T:
    var first = _first_present(array)
    var accumulator = array._elements[][first].copy().value().copy()
    for index in range(first + 1, len(array)):
        if array._elements[][index]:
            accumulator = callback(accumulator^)
    return accumulator^


def array_reduce_from_first_value[
    T: Copyable & Deinitable,
    Callback: def(T, T) raises -> T,
](array: JsArray[T], callback: Callback) raises -> T:
    var first = _first_present(array)
    var accumulator = array._elements[][first].copy().value().copy()
    for index in range(first + 1, len(array)):
        var current = array._elements[][index].copy()
        if current:
            accumulator = callback(accumulator^, current.value().copy())
    return accumulator^


def array_reduce_from_first_with_index[
    T: Copyable & Deinitable,
    Callback: def(T, T, Float64) raises -> T,
](array: JsArray[T], callback: Callback) raises -> T:
    var first = _first_present(array)
    var accumulator = array._elements[][first].copy().value().copy()
    for index in range(first + 1, len(array)):
        var current = array._elements[][index].copy()
        if current:
            accumulator = callback(
                accumulator^, current.value().copy(), Float64(index)
            )
    return accumulator^


def array_reduce_from_first_with_array[
    T: Copyable & Deinitable,
    Callback: def(T, T, Float64, JsArray[T]) raises -> T,
](array: JsArray[T], callback: Callback,) raises -> T:
    var first = _first_present(array)
    var accumulator = array._elements[][first].copy().value().copy()
    for index in range(first + 1, len(array)):
        var current = array._elements[][index].copy()
        if current:
            accumulator = callback(
                accumulator^, current.value().copy(), Float64(index), array
            )
    return accumulator^


def _first_present[T: Copyable & Deinitable](array: JsArray[T]) raises -> Int:
    for index in range(len(array)):
        if array._elements[][index]:
            return index
    raise Error("Reduce of empty JavaScript array with no initial value")
