from std.collections import List
from std.testing import assert_equal, assert_false, assert_true
from tsonic_js import JsString, JsSymbol, JsValue, object_is
from tsonic_js.value import (
    _JsValueBuilder,
    encode_structured_clone,
    decode_structured_clone,
)


def rejects(var bytes: List[UInt8]) raises:
    var rejected = False
    try:
        _ = decode_structured_clone(bytes^)
    except:
        rejected = True
    assert_true(rejected)


def main() raises:
    var builder = _JsValueBuilder()
    var root = builder.append_array(List[Int]())
    var text = builder.append_string(
        JsString(code_units=List[UInt16](0x61, 0, 0xD800, 0xDC00, 0xDFFF))
    )
    var negative_zero = builder.append_number(-0.0)
    var nan = builder.append_number(Float64(FloatLiteral.nan))
    var undefined = builder.append_undefined()
    builder.set_aggregate_children(
        root, List[Int](root, root, text, negative_zero, nan, undefined)
    )
    var source = builder.value(root)
    var bytes = encode_structured_clone(source)
    var clone = decode_structured_clone(bytes.copy())
    assert_false(source.same_identity(clone))
    assert_true(clone.same_identity(clone.array_at(0)))
    assert_true(clone.array_at(0).same_identity(clone.array_at(1)))
    assert_equal(
        clone.array_at(2).string_value(), source.array_at(2).string_value()
    )
    assert_true(object_is(clone.array_at(3), JsValue(-0.0)))
    assert_true(
        object_is(clone.array_at(4), JsValue(Float64(FloatLiteral.nan)))
    )
    assert_true(clone.array_at(5).is_undefined())
    for length in range(len(bytes)):
        var truncated = List[UInt8]()
        for index in range(length):
            truncated.append(bytes[index])
        rejects(truncated^)
    var trailing = bytes.copy()
    trailing.append(0)
    rejects(trailing^)
    var bad_version = bytes.copy()
    bad_version[0] = 0
    rejects(bad_version^)
    var bad_root = bytes.copy()
    bad_root[8] = 255
    rejects(bad_root^)
    var bad_kind = bytes.copy()
    bad_kind[16] = 255
    rejects(bad_kind^)
    var bad_reference = bytes.copy()
    bad_reference[21] = 255
    rejects(bad_reference^)
    var rejected = False
    try:
        _ = encode_structured_clone(JsValue(JsSymbol()))
    except:
        rejected = True
    assert_true(rejected)
