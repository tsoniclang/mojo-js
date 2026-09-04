from .map import JsMap
from .set import JsSet


def map_for_each_zero[
    R: Movable & Deinitable,
    K: Copyable & Deinitable & Equatable,
    V: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def() raises CallbackError -> R,
](map: JsMap[K, V], callback: Callback) raises CallbackError:
    for _ in map._entries[]:
        _ = callback()


def map_for_each_value[
    R: Movable & Deinitable,
    K: Copyable & Deinitable & Equatable,
    V: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(V) raises CallbackError -> R,
](map: JsMap[K, V], callback: Callback) raises CallbackError:
    for entry in map._entries[]:
        _ = callback(entry.value.copy())


def map_for_each_value_key[
    R: Movable & Deinitable,
    K: Copyable & Deinitable & Equatable,
    V: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(V, K) raises CallbackError -> R,
](map: JsMap[K, V], callback: Callback) raises CallbackError:
    for entry in map._entries[]:
        _ = callback(entry.value.copy(), entry.key.copy())


def map_for_each_with_map[
    R: Movable & Deinitable,
    K: Copyable & Deinitable & Equatable,
    V: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(V, K, JsMap[K, V]) raises CallbackError -> R,
](map: JsMap[K, V], callback: Callback,) raises CallbackError:
    for entry in map._entries[]:
        _ = callback(entry.value.copy(), entry.key.copy(), map)


def set_for_each_zero[
    R: Movable & Deinitable,
    T: Copyable & Deinitable & Equatable,
    CallbackError: AnyType,
    Callback: def() raises CallbackError -> R,
](set: JsSet[T], callback: Callback) raises CallbackError:
    for _ in set._values[]:
        _ = callback()


def set_for_each_value[
    R: Movable & Deinitable,
    T: Copyable & Deinitable & Equatable,
    CallbackError: AnyType,
    Callback: def(T) raises CallbackError -> R,
](set: JsSet[T], callback: Callback) raises CallbackError:
    for value in set._values[]:
        _ = callback(value.copy())


def set_for_each_value_key[
    R: Movable & Deinitable,
    T: Copyable & Deinitable & Equatable,
    CallbackError: AnyType,
    Callback: def(T, T) raises CallbackError -> R,
](set: JsSet[T], callback: Callback) raises CallbackError:
    for value in set._values[]:
        _ = callback(value.copy(), value.copy())


def set_for_each_with_set[
    R: Movable & Deinitable,
    T: Copyable & Deinitable & Equatable,
    CallbackError: AnyType,
    Callback: def(T, T, JsSet[T]) raises CallbackError -> R,
](set: JsSet[T], callback: Callback,) raises CallbackError:
    for value in set._values[]:
        _ = callback(value.copy(), value.copy(), set)
