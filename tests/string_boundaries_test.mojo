from std.testing import assert_equal, assert_false, assert_raises, assert_true
from tsonic_js import (
    JsString,
    native_string_at,
    native_string_char_at,
    native_string_from_char_code,
    native_string_from_code_point,
    native_string_get_index,
    native_string_pad_end,
    native_string_pad_start,
    native_string_slice,
    native_string_substr,
    native_string_substring,
    string_from_char_code,
    string_from_code_point,
    string_split,
)
from tsonic_js.string_indexes import string_capacity, string_repeat_shape


def main() raises:
    var positive = Float64(FloatLiteral.infinity)
    var negative = Float64(FloatLiteral.negative_infinity)
    var nan = Float64(FloatLiteral.nan)
    var source = JsString("aba😀")
    for index in List[Float64](positive, negative, 1e100, -1e100):
        assert_equal(len(source.char_at(index)), 0)
        assert_false(Bool(source.at(index)))
        assert_false(Bool(source.code_point_at(index)))
        assert_false(Bool(source.get_index(index)))
    assert_equal(source.char_at(nan).to_native_strict(), "a")
    assert_equal(source.char_at(1.9).to_native_strict(), "b")
    assert_false(Bool(source.get_index(1.9)))
    assert_false(Bool(source.get_index(nan)))
    assert_equal(source.last_index_of(JsString("a"), nan), 2)
    assert_equal(source.slice(negative, positive).to_native_strict(), "aba😀")
    assert_equal(
        source.substring(positive, negative).to_native_strict(), "aba😀"
    )
    assert_equal(source.substr(1, 1e100).to_native_strict(), "ba😀")
    assert_equal(source.substr(1, negative).to_native_strict(), "")
    assert_equal(len(string_split(source, JsString(""), negative)), 0)
    assert_equal(len(string_split(source, JsString(""), nan)), 0)
    assert_equal(len(string_split(source, JsString(""), positive)), 0)
    assert_equal(len(string_split(source, JsString(""), -1)), 5)
    assert_equal(len(string_split(source, JsString(""), 4294967297.9)), 1)
    var units = string_from_char_code([nan, positive, negative, -1, 65537.9])
    assert_equal(units.code_unit_at(0).value(), UInt16(0))
    assert_equal(units.code_unit_at(1).value(), UInt16(0))
    assert_equal(units.code_unit_at(2).value(), UInt16(0))
    assert_equal(units.code_unit_at(3).value(), UInt16(0xFFFF))
    assert_equal(units.code_unit_at(4).value(), UInt16(1))
    for scalar in List[Float64](
        nan, positive, negative, 1e100, -1, 1.5, 0x110000
    ):
        with assert_raises(contains="invalid JavaScript Unicode code point"):
            _ = string_from_code_point([scalar])
    assert_equal(native_string_get_index("abc", 1).value(), "b")
    assert_false(Bool(native_string_get_index("abc", 1.9)))
    assert_false(Bool(native_string_get_index("abc", positive)))
    assert_equal(native_string_slice("😀", 0, 2), "😀")
    assert_equal(native_string_from_code_point([0x1F600]), "😀")
    with assert_raises(contains="unpaired UTF-16"):
        _ = native_string_char_at("😀", 0)
    with assert_raises(contains="unpaired UTF-16"):
        _ = native_string_at("😀", -1)
    with assert_raises(contains="unpaired UTF-16"):
        _ = native_string_get_index("😀", 0)
    with assert_raises(contains="unpaired UTF-16"):
        _ = native_string_slice("😀", 0, 1)
    with assert_raises(contains="unpaired UTF-16"):
        _ = native_string_substr("😀", 0, 1)
    with assert_raises(contains="unpaired UTF-16"):
        _ = native_string_substring("😀", 0, 1)
    with assert_raises(contains="unpaired UTF-16"):
        _ = native_string_pad_start("x", 2, "😀")
    with assert_raises(contains="unpaired UTF-16"):
        _ = native_string_pad_end("x", 2, "😀")
    with assert_raises(contains="unpaired UTF-16"):
        _ = native_string_from_char_code([0xD800])
    with assert_raises(contains="unpaired UTF-16"):
        _ = native_string_from_code_point([0xD800])
    assert_equal(JsString().repeat(1e100).to_native_strict(), "")
    assert_equal(JsString("x").repeat(-0.9).to_native_strict(), "")
    assert_equal(
        source.pad_start(positive, JsString()).to_native_strict(), "aba😀"
    )
    assert_equal(string_repeat_shape(2, 8388609.0), (8388609, 16777218))
    assert_equal(string_capacity(16777217), 16777217)
    with assert_raises(contains="string length"):
        _ = string_repeat_shape(2, 1e100)
    with assert_raises(contains="native storage capacity"):
        _ = string_capacity(1e100)
    with assert_raises(contains="repeat count"):
        _ = JsString().repeat(positive)
    var exact = JsString("😀").char_at(0)
    assert_equal(exact.code_unit_at(0).value(), UInt16(0xD83D))
    assert_true(Bool(source.at(-1)))
    var length = 16777217
    var repeated = JsString("x").repeat(Float64(length))
    assert_equal(len(repeated), length)
    for index in range(length):
        assert_equal(repeated.code_unit_at(index).value(), UInt16(120))
    var padded = JsString("tail").pad_start(Float64(length), JsString("ab"))
    assert_equal(len(padded), length)
    assert_equal(padded.slice(0, 5).to_native_strict(), "ababa")
    assert_equal(padded.slice(Float64(length - 4)).to_native_strict(), "tail")
