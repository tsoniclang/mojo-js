from std.collections import List
from std.memory import ArcPointer
from std.testing import assert_equal, assert_false, assert_true
from tsonic_js import JsByteView, JsString, JsValue, js_value_from_byte_view, js_value_from_array_values, js_value_structured_clone, json_stringify, object_keys, object_is, inspect_value
from tsonic_js.value import encode_structured_clone, decode_structured_clone


def rejected(var bytes: List[UInt8]) raises:
    var failed = False
    try:
        _ = decode_structured_clone(bytes^)
    except:
        failed = True
    assert_true(failed)


def main() raises:
    var storage = ArcPointer(List[UInt8](1, 2, 3, 4))
    var view = JsByteView(storage, 0, 3, ArcPointer(False))
    var source = js_value_from_byte_view(view)
    var retained_alias = js_value_from_byte_view(view)
    var slice = js_value_from_byte_view(JsByteView(storage, 1, 2, ArcPointer(False)))
    assert_true(source.is_object())
    assert_false(source.is_array())
    assert_true(source.is_byte_view())
    assert_true(object_is(source, retained_alias))
    assert_false(object_is(source, slice))
    assert_equal(source.object_value(1).number_value(), 2)
    storage[][1] = 9
    assert_equal(retained_alias.object_value(1).number_value(), 9)
    assert_equal(slice.object_value(0).number_value(), 9)
    assert_equal(source.property_get(JsString("length")).number_value(), 3)
    assert_equal(slice.property_get(JsString("byteOffset")).number_value(), 1)
    assert_equal(len(object_keys(source)), 3)
    assert_equal(json_stringify(source).value().to_native_strict(), '{"0":1,"1":9,"2":3}')
    assert_equal(inspect_value(source), "Uint8Array(3) [ 1, 9, 3 ]")
    var values = List[JsValue]()
    values.append(source)
    values.append(retained_alias)
    values.append(slice)
    var group = js_value_from_array_values(values^)
    var clone = js_value_structured_clone(group)
    assert_true(clone.array_at(0).same_identity(clone.array_at(1)))
    assert_false(clone.array_at(0).same_identity(source))
    assert_false(clone.array_at(0).same_identity(clone.array_at(2)))
    var first = clone.array_at(0).byte_view()
    var second = clone.array_at(2).byte_view()
    assert_equal(first.storage_identity(), second.storage_identity())
    assert_false(first.storage_identity() == view.storage_identity())
    first.set(1, 7)
    assert_equal(second.get(0), 7)
    assert_equal(storage[][1], 9)
    var wire = encode_structured_clone(clone)
    var decoded = decode_structured_clone(wire.copy())
    assert_true(decoded.array_at(0).same_identity(decoded.array_at(1)))
    assert_equal(decoded.array_at(0).byte_view().storage_identity(), decoded.array_at(2).byte_view().storage_identity())
    decoded.array_at(0).byte_view().set(1, 5)
    assert_equal(decoded.array_at(2).byte_view().get(0), 5)
    assert_equal(second.get(0), 7)
    var direct = encode_structured_clone(source)
    assert_equal(len(direct), 37)
    for offset in [25, 29, 33]:
        var mutated = direct.copy()
        mutated[offset] = 255
        rejected(mutated^)
    var old_version = direct.copy()
    old_version[3] = 0x32
    rejected(old_version^)
    for length in range(len(direct)):
        var truncated = List[UInt8]()
        for index in range(length):
            truncated.append(direct[index])
        rejected(truncated^)
    var invalid = JsByteView(storage, 3, 2, ArcPointer(False))
    var invalid_rejected = False
    try:
        _ = js_value_structured_clone(js_value_from_byte_view(invalid))
    except:
        invalid_rejected = True
    assert_true(invalid_rejected)
