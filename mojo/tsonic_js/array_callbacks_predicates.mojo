from .array import JsArray


def array_find_index_zero[
    T: Copyable & Deinitable,
    Callback: def() raises -> Bool,
](array: JsArray[T], callback: Callback) raises -> Float64:
    for index in range(len(array)):
        if callback():
            return Float64(index)
    return -1


def array_find_index_value[
    T: Copyable & Deinitable,
    Callback: def(T) raises -> Bool,
](array: JsArray[T], callback: Callback) raises -> Float64:
    for index in range(len(array)):
        var value = array.read_value(index)
        if callback(value.copy()):
            return Float64(index)
    return -1


def array_find_index_with_index[
    T: Copyable & Deinitable,
    Callback: def(T, Float64) raises -> Bool,
](array: JsArray[T], callback: Callback) raises -> Float64:
    for index in range(len(array)):
        var value = array.read_value(index)
        if callback(value.copy(), Float64(index)):
            return Float64(index)
    return -1


def array_find_index_with_array[
    T: Copyable & Deinitable,
    Callback: def(T, Float64, JsArray[T]) raises -> Bool,
](array: JsArray[T], callback: Callback) raises -> Float64:
    for index in range(len(array)):
        var value = array.read_value(index)
        if callback(value.copy(), Float64(index), array):
            return Float64(index)
    return -1


def array_find_last_index_zero[
    T: Copyable & Deinitable,
    Callback: def() raises -> Bool,
](array: JsArray[T], callback: Callback) raises -> Float64:
    var index = len(array) - 1
    while index >= 0:
        if callback():
            return Float64(index)
        index -= 1
    return -1


def array_find_last_index_value[
    T: Copyable & Deinitable,
    Callback: def(T) raises -> Bool,
](array: JsArray[T], callback: Callback) raises -> Float64:
    var index = len(array) - 1
    while index >= 0:
        var value = array.read_value(index)
        if callback(value.copy()):
            return Float64(index)
        index -= 1
    return -1


def array_find_last_index_with_index[
    T: Copyable & Deinitable,
    Callback: def(T, Float64) raises -> Bool,
](array: JsArray[T], callback: Callback) raises -> Float64:
    var index = len(array) - 1
    while index >= 0:
        var value = array.read_value(index)
        if callback(value.copy(), Float64(index)):
            return Float64(index)
        index -= 1
    return -1


def array_find_last_index_with_array[
    T: Copyable & Deinitable,
    Callback: def(T, Float64, JsArray[T]) raises -> Bool,
](array: JsArray[T], callback: Callback) raises -> Float64:
    var index = len(array) - 1
    while index >= 0:
        var value = array.read_value(index)
        if callback(value.copy(), Float64(index), array):
            return Float64(index)
        index -= 1
    return -1


def array_find_zero[
    T: Copyable & Deinitable,
    Callback: def() raises -> Bool,
](array: JsArray[T], callback: Callback) raises -> Optional[T]:
    for index in range(len(array)):
        var current = array.get(index)
        if callback():
            return current^
    return None


def array_find_value[
    T: Copyable & Deinitable,
    Callback: def(T) raises -> Bool,
](array: JsArray[T], callback: Callback) raises -> Optional[T]:
    for index in range(len(array)):
        var value = array.read_value(index)
        if callback(value.copy()):
            return Optional[T](value^)
    return None


def array_find_with_index[
    T: Copyable & Deinitable,
    Callback: def(T, Float64) raises -> Bool,
](array: JsArray[T], callback: Callback) raises -> Optional[T]:
    for index in range(len(array)):
        var value = array.read_value(index)
        if callback(value.copy(), Float64(index)):
            return Optional[T](value^)
    return None


def array_find_with_array[
    T: Copyable & Deinitable,
    Callback: def(T, Float64, JsArray[T]) raises -> Bool,
](array: JsArray[T], callback: Callback) raises -> Optional[T]:
    for index in range(len(array)):
        var value = array.read_value(index)
        if callback(value.copy(), Float64(index), array):
            return Optional[T](value^)
    return None


def array_find_last_zero[
    T: Copyable & Deinitable,
    Callback: def() raises -> Bool,
](array: JsArray[T], callback: Callback) raises -> Optional[T]:
    var index = len(array) - 1
    while index >= 0:
        var current = array.get(index)
        if callback():
            return current^
        index -= 1
    return None


def array_find_last_value[
    T: Copyable & Deinitable,
    Callback: def(T) raises -> Bool,
](array: JsArray[T], callback: Callback) raises -> Optional[T]:
    var index = len(array) - 1
    while index >= 0:
        var value = array.read_value(index)
        if callback(value.copy()):
            return Optional[T](value^)
        index -= 1
    return None


def array_find_last_with_index[
    T: Copyable & Deinitable,
    Callback: def(T, Float64) raises -> Bool,
](array: JsArray[T], callback: Callback) raises -> Optional[T]:
    var index = len(array) - 1
    while index >= 0:
        var value = array.read_value(index)
        if callback(value.copy(), Float64(index)):
            return Optional[T](value^)
        index -= 1
    return None


def array_find_last_with_array[
    T: Copyable & Deinitable,
    Callback: def(T, Float64, JsArray[T]) raises -> Bool,
](array: JsArray[T], callback: Callback) raises -> Optional[T]:
    var index = len(array) - 1
    while index >= 0:
        var value = array.read_value(index)
        if callback(value.copy(), Float64(index), array):
            return Optional[T](value^)
        index -= 1
    return None


def array_some_zero[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def() raises CallbackError -> Bool,
](array: JsArray[T], callback: Callback) raises CallbackError -> Bool:
    for index in range(len(array)):
        var current = array.get(index)
        if current:
            if callback():
                return True
    return False


def array_some_value[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T) raises CallbackError -> Bool,
](array: JsArray[T], callback: Callback) raises CallbackError -> Bool:
    for index in range(len(array)):
        var current = array.get(index)
        if current:
            var value = current.value().copy()
            if callback(value.copy()):
                return True
    return False


def array_some_with_index[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T, Float64) raises CallbackError -> Bool,
](array: JsArray[T], callback: Callback) raises CallbackError -> Bool:
    for index in range(len(array)):
        var current = array.get(index)
        if current:
            var value = current.value().copy()
            if callback(value.copy(), Float64(index)):
                return True
    return False


def array_some_with_array[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T, Float64, JsArray[T]) raises CallbackError -> Bool,
](array: JsArray[T], callback: Callback) raises CallbackError -> Bool:
    for index in range(len(array)):
        var current = array.get(index)
        if current:
            var value = current.value().copy()
            if callback(value.copy(), Float64(index), array):
                return True
    return False


def array_every_zero[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def() raises CallbackError -> Bool,
](array: JsArray[T], callback: Callback) raises CallbackError -> Bool:
    for index in range(len(array)):
        var current = array.get(index)
        if current:
            if not callback():
                return False
    return True


def array_every_value[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T) raises CallbackError -> Bool,
](array: JsArray[T], callback: Callback) raises CallbackError -> Bool:
    for index in range(len(array)):
        var current = array.get(index)
        if current:
            var value = current.value().copy()
            if not callback(value.copy()):
                return False
    return True


def array_every_with_index[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T, Float64) raises CallbackError -> Bool,
](array: JsArray[T], callback: Callback) raises CallbackError -> Bool:
    for index in range(len(array)):
        var current = array.get(index)
        if current:
            var value = current.value().copy()
            if not callback(value.copy(), Float64(index)):
                return False
    return True


def array_every_with_array[
    T: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(T, Float64, JsArray[T]) raises CallbackError -> Bool,
](array: JsArray[T], callback: Callback) raises CallbackError -> Bool:
    for index in range(len(array)):
        var current = array.get(index)
        if current:
            var value = current.value().copy()
            if not callback(value.copy(), Float64(index), array):
                return False
    return True
