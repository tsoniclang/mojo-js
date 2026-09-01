from std.testing import assert_equal, assert_false, assert_raises, assert_true
from tsonic_js import (
    JsString,
    string_from_char_code,
    string_from_code_point,
    string_split,
)


def main() raises:
    var ascii = JsString("hello")
    assert_equal(len(ascii), 5)
    assert_equal(ascii.to_native_strict(), "hello")

    var emoji = JsString("😀")
    assert_equal(len(emoji), 2)
    assert_equal(emoji.code_unit_at(0).value(), UInt16(0xD83D))
    assert_equal(emoji.code_unit_at(1).value(), UInt16(0xDE00))
    assert_equal(emoji.to_native_strict(), "😀")

    var first = emoji.char_at(0)
    assert_equal(len(first), 1)
    with assert_raises(contains="unpaired UTF-16 high surrogate"):
        _ = first.to_native_strict()
    assert_equal(first.to_native_lossy(), "�")
    assert_equal(String(first), "�")

    assert_equal(JsString("a").concat(JsString("b")).to_native_strict(), "ab")
    assert_true(JsString("same") == JsString("same"))

    var text = JsString("  Alpha beta Alpha  ")
    assert_true(text.includes(JsString("beta")))
    assert_true(text.starts_with(JsString("  Alpha")))
    assert_true(text.ends_with(JsString("Alpha  ")))
    assert_equal(text.index_of(JsString("Alpha")), 2)
    assert_equal(text.last_index_of(JsString("Alpha")), 13)
    assert_equal(text.slice(2, 7).to_native_strict(), "Alpha")
    assert_equal(text.substring(8, 12).to_native_strict(), "beta")
    assert_equal(text.substr(8, 4).to_native_strict(), "beta")
    assert_equal(text.at(-3).value().to_native_strict(), "a")
    assert_equal(text.char_code_at(2), 65)
    assert_equal(emoji.code_point_at(0).value(), 0x1F600)
    assert_equal(text.trim().to_native_strict(), "Alpha beta Alpha")
    assert_equal(text.trim_start().to_native_strict(), "Alpha beta Alpha  ")
    assert_equal(text.trim_end().to_native_strict(), "  Alpha beta Alpha")
    assert_equal(JsString("ab").repeat(3).to_native_strict(), "ababab")
    assert_equal(
        JsString("x").pad_start(3, JsString("0")).to_native_strict(), "00x"
    )
    assert_equal(
        JsString("x").pad_end(3, JsString("0")).to_native_strict(), "x00"
    )
    assert_equal(JsString("Aa").to_lower_case().to_native_strict(), "aa")
    assert_equal(JsString("Aa").to_upper_case().to_native_strict(), "AA")
    assert_equal(
        JsString("one one")
        .replace(JsString("one"), JsString("two"))
        .to_native_strict(),
        "two one",
    )
    assert_equal(
        JsString("one one")
        .replace_all(JsString("one"), JsString("two"))
        .to_native_strict(),
        "two two",
    )
    var pieces = string_split(JsString("a,b,c"), JsString(","), 2)
    assert_equal(len(pieces), 2)
    assert_equal(pieces.get(1).value().to_native_strict(), "b")
    assert_equal(string_from_char_code(65, 66).to_native_strict(), "AB")
    assert_equal(string_from_code_point(0x1F600).to_native_strict(), "😀")
    assert_true(emoji.is_well_formed())
    assert_false(first.is_well_formed())
    assert_equal(first.to_well_formed().to_native_strict(), "�")
