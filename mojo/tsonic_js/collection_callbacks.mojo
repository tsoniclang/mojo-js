from tsonic_runtime import RaisingCallable

from .map import JsMap
from .set import JsSet


def map_for_each_zero[
    R: Movable & Deinitable,
    K: Copyable & Deinitable & Equatable,
    V: Copyable & Deinitable,
](map: JsMap[K, V], callback: RaisingCallable[Tuple[], R]) raises:
    for _ in map._entries[]:
        _ = callback.call(())


def map_for_each_value[
    R: Movable & Deinitable,
    K: Copyable & Deinitable & Equatable,
    V: Copyable & Deinitable,
](map: JsMap[K, V], callback: RaisingCallable[Tuple[V], R]) raises:
    for entry in map._entries[]:
        _ = callback.call((entry.value.copy(),))


def map_for_each_value_key[
    R: Movable & Deinitable,
    K: Copyable & Deinitable & Equatable,
    V: Copyable & Deinitable,
](map: JsMap[K, V], callback: RaisingCallable[Tuple[V, K], R]) raises:
    for entry in map._entries[]:
        _ = callback.call((entry.value.copy(), entry.key.copy()))


def map_for_each_with_map[
    R: Movable & Deinitable,
    K: Copyable & Deinitable & Equatable,
    V: Copyable & Deinitable,
](
    map: JsMap[K, V], callback: RaisingCallable[Tuple[V, K, JsMap[K, V]], R]
) raises:
    for entry in map._entries[]:
        _ = callback.call((entry.value.copy(), entry.key.copy(), map))


def set_for_each_zero[
    R: Movable & Deinitable,
    T: Copyable & Deinitable & Equatable,
](set: JsSet[T], callback: RaisingCallable[Tuple[], R]) raises:
    for _ in set._values[]:
        _ = callback.call(())


def set_for_each_value[
    R: Movable & Deinitable,
    T: Copyable & Deinitable & Equatable,
](set: JsSet[T], callback: RaisingCallable[Tuple[T], R]) raises:
    for value in set._values[]:
        _ = callback.call((value.copy(),))


def set_for_each_value_key[
    R: Movable & Deinitable,
    T: Copyable & Deinitable & Equatable,
](set: JsSet[T], callback: RaisingCallable[Tuple[T, T], R]) raises:
    for value in set._values[]:
        _ = callback.call((value.copy(), value.copy()))


def set_for_each_with_set[
    R: Movable & Deinitable,
    T: Copyable & Deinitable & Equatable,
](set: JsSet[T], callback: RaisingCallable[Tuple[T, T, JsSet[T]], R]) raises:
    for value in set._values[]:
        _ = callback.call((value.copy(), value.copy(), set))
