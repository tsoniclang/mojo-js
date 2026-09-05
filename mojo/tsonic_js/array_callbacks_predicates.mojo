from .array import JsArray


def array_find_index_zero[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def() raises CallbackError -> Bool,
](array: JsArray[T], callback: Callback) raises CallbackError -> Float64:
    for index in range(len(array)):
        if array._elements[][index] and callback():
            return Float64(index)
    return -1


def array_find_index_value[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T) raises CallbackError -> Bool,
](array: JsArray[T], callback: Callback) raises CallbackError -> Float64:
    for index in range(len(array)):
        var current = array._elements[][index].copy()
        if current and callback(current.value().copy()):
            return Float64(index)
    return -1


def array_find_index_with_index[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T, Float64) raises CallbackError -> Bool,
](array: JsArray[T], callback: Callback,) raises CallbackError -> Float64:
    for index in range(len(array)):
        var current = array._elements[][index].copy()
        if current and callback(current.value().copy(), Float64(index)):
            return Float64(index)
    return -1


def array_find_index_with_array[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T, Float64, JsArray[T]) raises CallbackError -> Bool,
](array: JsArray[T], callback: Callback,) raises CallbackError -> Float64:
    for index in range(len(array)):
        var current = array._elements[][index].copy()
        if current and callback(current.value().copy(), Float64(index), array):
            return Float64(index)
    return -1


def array_find_last_index_zero[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def() raises CallbackError -> Bool,
](array: JsArray[T], callback: Callback) raises CallbackError -> Float64:
    var index = len(array) - 1
    while index >= 0:
        if array._elements[][index] and callback():
            return Float64(index)
        index -= 1
    return -1


def array_find_last_index_value[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T) raises CallbackError -> Bool,
](array: JsArray[T], callback: Callback) raises CallbackError -> Float64:
    var index = len(array) - 1
    while index >= 0:
        var current = array._elements[][index].copy()
        if current and callback(current.value().copy()):
            return Float64(index)
        index -= 1
    return -1


def array_find_last_index_with_index[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T, Float64) raises CallbackError -> Bool,
](array: JsArray[T], callback: Callback,) raises CallbackError -> Float64:
    var index = len(array) - 1
    while index >= 0:
        var current = array._elements[][index].copy()
        if current and callback(current.value().copy(), Float64(index)):
            return Float64(index)
        index -= 1
    return -1


def array_find_last_index_with_array[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T, Float64, JsArray[T]) raises CallbackError -> Bool,
](array: JsArray[T], callback: Callback,) raises CallbackError -> Float64:
    var index = len(array) - 1
    while index >= 0:
        var current = array._elements[][index].copy()
        if current and callback(current.value().copy(), Float64(index), array):
            return Float64(index)
        index -= 1
    return -1


def array_find_zero[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def() raises CallbackError -> Bool,
](array: JsArray[T], callback: Callback) raises CallbackError -> Optional[T]:
    return _value_at(array, array_find_index_zero(array, callback))


def array_find_value[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T) raises CallbackError -> Bool,
](array: JsArray[T], callback: Callback) raises CallbackError -> Optional[T]:
    return _value_at(array, array_find_index_value(array, callback))


def array_find_with_index[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T, Float64) raises CallbackError -> Bool,
](array: JsArray[T], callback: Callback,) raises CallbackError -> Optional[T]:
    return _value_at(array, array_find_index_with_index(array, callback))


def array_find_with_array[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T, Float64, JsArray[T]) raises CallbackError -> Bool,
](array: JsArray[T], callback: Callback,) raises CallbackError -> Optional[T]:
    return _value_at(array, array_find_index_with_array(array, callback))


def array_find_last_zero[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def() raises CallbackError -> Bool,
](array: JsArray[T], callback: Callback) raises CallbackError -> Optional[T]:
    return _value_at(array, array_find_last_index_zero(array, callback))


def array_find_last_value[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T) raises CallbackError -> Bool,
](array: JsArray[T], callback: Callback) raises CallbackError -> Optional[T]:
    return _value_at(array, array_find_last_index_value(array, callback))


def array_find_last_with_index[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T, Float64) raises CallbackError -> Bool,
](array: JsArray[T], callback: Callback,) raises CallbackError -> Optional[T]:
    return _value_at(array, array_find_last_index_with_index(array, callback))


def array_find_last_with_array[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T, Float64, JsArray[T]) raises CallbackError -> Bool,
](array: JsArray[T], callback: Callback,) raises CallbackError -> Optional[T]:
    return _value_at(array, array_find_last_index_with_array(array, callback))


def array_some_zero[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def() raises CallbackError -> Bool,
](array: JsArray[T], callback: Callback) raises CallbackError -> Bool:
    return array_find_index_zero(array, callback) >= 0


def array_some_value[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T) raises CallbackError -> Bool,
](array: JsArray[T], callback: Callback) raises CallbackError -> Bool:
    return array_find_index_value(array, callback) >= 0


def array_some_with_index[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T, Float64) raises CallbackError -> Bool,
](array: JsArray[T], callback: Callback,) raises CallbackError -> Bool:
    return array_find_index_with_index(array, callback) >= 0


def array_some_with_array[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T, Float64, JsArray[T]) raises CallbackError -> Bool,
](array: JsArray[T], callback: Callback,) raises CallbackError -> Bool:
    return array_find_index_with_array(array, callback) >= 0


def array_every_zero[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def() raises CallbackError -> Bool,
](array: JsArray[T], callback: Callback) raises CallbackError -> Bool:
    for index in range(len(array)):
        if array._elements[][index] and not callback():
            return False
    return True


def array_every_value[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T) raises CallbackError -> Bool,
](array: JsArray[T], callback: Callback) raises CallbackError -> Bool:
    for index in range(len(array)):
        var current = array._elements[][index].copy()
        if current and not callback(current.value().copy()):
            return False
    return True


def array_every_with_index[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T, Float64) raises CallbackError -> Bool,
](array: JsArray[T], callback: Callback,) raises CallbackError -> Bool:
    for index in range(len(array)):
        var current = array._elements[][index].copy()
        if current and not callback(current.value().copy(), Float64(index)):
            return False
    return True


def array_every_with_array[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T, Float64, JsArray[T]) raises CallbackError -> Bool,
](array: JsArray[T], callback: Callback,) raises CallbackError -> Bool:
    for index in range(len(array)):
        var current = array._elements[][index].copy()
        if current and not callback(
            current.value().copy(), Float64(index), array
        ):
            return False
    return True


def _value_at[
    T: Copyable & Deinitable
](array: JsArray[T], index: Float64) -> Optional[T]:
    return None if index < 0 else array.get(Int(index))
