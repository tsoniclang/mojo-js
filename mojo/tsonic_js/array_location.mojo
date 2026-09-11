from tsonic_runtime import TypedLocation, access_location, location_identity
from .array import JsArray, _array_index


def _read_element[T: Copyable & Deinitable](owner: JsArray[T], index: Int) raises -> T:
    return owner.read_value(index)


def _write_element[T: Copyable & Deinitable](mut owner: JsArray[T], index: Int, var value: T) raises:
    owner.set(index, value^)


def array_location[T: Copyable & Deinitable](owner: JsArray[T], index: Float64) raises -> TypedLocation[T]:
    var selected_index = _array_index(index)
    if selected_index < 0:
        raise Error("Array location requires a valid integer element index")
    var identity = location_identity(owner._elements).index(selected_index)
    return access_location[JsArray[T], Int, T](owner, selected_index, identity, _read_element[T], _write_element[T])
