from std.collections import List
from std.testing import assert_equal

from tsonic_js import (
    JsString,
    decode_uri_component,
    decode_uri_component_native,
    encode_uri_component,
    encode_uri_component_native,
)


def main() raises:
    var encoded = encode_uri_component_native("alpha beta/😀")
    assert_equal(encoded, "alpha%20beta%2F%F0%9F%98%80")
    assert_equal(decode_uri_component_native(encoded), "alpha beta/😀")
    assert_equal(encode_uri_component_native("!~*'()"), "!~*'()")
    assert_equal(encode_uri_component_native("\x00"), "%00")
    assert_equal(decode_uri_component_native("%00"), "\x00")
    assert_equal(decode_uri_component_native("%E2%82%AC"), "€")
    assert_equal(decode_uri_component_native("a+b"), "a+b")
    var raw = JsString("😀").char_at(0)
    var decoded = decode_uri_component(raw + JsString("%20%F0%9F%98%80"))
    assert_equal(decoded, raw + JsString(" 😀"))
    var encode_rejected = False
    try:
        _ = encode_uri_component(raw)
    except:
        encode_rejected = True
    assert_equal(encode_rejected, True)

    var malformed_inputs: List[String] = [
        "%",
        "%GG",
        "%C0%AF",
        "%ED%A0%80",
        "%F4%90%80%80",
    ]
    for malformed in malformed_inputs:
        var rejected = False
        try:
            _ = decode_uri_component_native(malformed)
        except:
            rejected = True
        assert_equal(rejected, True)
        var exact_rejected = False
        try:
            _ = decode_uri_component(JsString(malformed))
        except:
            exact_rejected = True
        assert_equal(exact_rejected, True)
