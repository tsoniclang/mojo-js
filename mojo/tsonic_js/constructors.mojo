from std.collections import List

from .array import JsArray
from .map import JsMap
from .set import JsSet


fn array_new[T: Copyable & Deinitable](*items: T) -> JsArray[T]:
    var values = List[T](capacity=len(items))
    for item in items:
        values.append(item.copy())
    return JsArray[T](values^)


fn map_new[
    K: Copyable & Deinitable & Equatable,
    V: Copyable & Deinitable,
]() -> JsMap[K, V]:
    return JsMap[K, V]()


fn map_new[
    K: Copyable & Deinitable & Equatable,
    V: Copyable & Deinitable,
](entries: JsArray[Tuple[K, V]]) -> JsMap[K, V]:
    var result = JsMap[K, V]()
    for index in range(len(entries)):
        try:
            var entry = entries[Float64(index)]
            _ = result.set(entry.get[0](), entry.get[1]())
        except:
            pass
    return result


fn set_new[T: Copyable & Deinitable & Equatable]() -> JsSet[T]:
    return JsSet[T]()


fn set_new[T: Copyable & Deinitable & Equatable](values: JsArray[T]) -> JsSet[T]:
    var result = JsSet[T]()
    for index in range(len(values)):
        try:
            _ = result.add(values[Float64(index)])
        except:
            pass
    return result
