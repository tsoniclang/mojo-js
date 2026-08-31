from std.testing import assert_equal, assert_raises, assert_true
from tsonic_js import JsString


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

    assert_equal(JsString("a").concat(JsString("b")).to_native_strict(), "ab")
    assert_true(JsString("same") == JsString("same"))
