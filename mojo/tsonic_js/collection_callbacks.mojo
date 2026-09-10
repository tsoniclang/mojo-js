from .map import JsMap
from .set import JsSet


def map_for_each_zero[
    R: Movable & Deinitable,
    K: Copyable & Deinitable & Equatable,
    V: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def() raises CallbackError -> R,
](map: JsMap[K, V], callback: Callback) raises CallbackError:
    for _ in map.keys():
        _ = callback()


def map_for_each_value[
    R: Movable & Deinitable,
    K: Copyable & Deinitable & Equatable,
    V: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(V) raises CallbackError -> R,
](map: JsMap[K, V], callback: Callback) raises CallbackError:
    for value in map.values():
        _ = callback(value.copy())


def map_for_each_value_key[
    R: Movable & Deinitable,
    K: Copyable & Deinitable & Equatable,
    V: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(V, K) raises CallbackError -> R,
](map: JsMap[K, V], callback: Callback) raises CallbackError:
    for entry in map.iter_entries():
        _ = callback(entry[1].copy(), entry[0].copy())


def map_for_each_with_map[
    R: Movable & Deinitable,
    K: Copyable & Deinitable & Equatable,
    V: Copyable & Deinitable,
    CallbackError: AnyType,
    Callback: def(V, K, JsMap[K, V]) raises CallbackError -> R,
](map: JsMap[K, V], callback: Callback,) raises CallbackError:
    for entry in map.iter_entries():
        _ = callback(entry[1].copy(), entry[0].copy(), map)


def set_for_each_zero[
    R: Movable & Deinitable,
    T: Copyable & Deinitable & Equatable,
    CallbackError: AnyType,
    Callback: def() raises CallbackError -> R,
](set: JsSet[T], callback: Callback) raises CallbackError:
    for _ in set.values():
        _ = callback()


def set_for_each_value[
    R: Movable & Deinitable,
    T: Copyable & Deinitable & Equatable,
    CallbackError: AnyType,
    Callback: def(T) raises CallbackError -> R,
](set: JsSet[T], callback: Callback) raises CallbackError:
    for value in set.values():
        _ = callback(value.copy())


def set_for_each_value_key[
    R: Movable & Deinitable,
    T: Copyable & Deinitable & Equatable,
    CallbackError: AnyType,
    Callback: def(T, T) raises CallbackError -> R,
](set: JsSet[T], callback: Callback) raises CallbackError:
    for value in set.values():
        _ = callback(value.copy(), value.copy())


def set_for_each_with_set[
    R: Movable & Deinitable,
    T: Copyable & Deinitable & Equatable,
    CallbackError: AnyType,
    Callback: def(T, T, JsSet[T]) raises CallbackError -> R,
](set: JsSet[T], callback: Callback,) raises CallbackError:
    for value in set.values():
        _ = callback(value.copy(), value.copy(), set)
