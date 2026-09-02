from std.testing import assert_equal, assert_false, assert_true
from tsonic_js import (
    JsString,
    JsValue,
    js_truthy,
    js_value_to_string,
    json_parse,
    json_stringify,
    object_entries,
    object_has_own,
    object_is,
    object_keys,
    object_values,
)

from tsonic_js import boolean_to_string, boolean_value_of


def main() raises:
    assert_equal(boolean_to_string(True).to_native_strict(), "true")
    assert_false(boolean_value_of(False))
    var number = JsValue(Float64(4.5))
    assert_true(number.is_number())
    assert_equal(number.number_value(), 4.5)
    assert_true(js_truthy(number))

    var text = JsValue(JsString("text"))
    assert_true(text.is_string())
    assert_equal(text.string_value().to_native_strict(), "text")
    assert_false(js_truthy(JsValue(JsString())))

    var missing = JsValue.undefined()
    assert_true(missing.is_undefined())
    assert_false(js_truthy(missing))
    assert_true(
        object_is(
            JsValue(Float64(FloatLiteral.nan)),
            JsValue(Float64(FloatLiteral.nan)),
        )
    )
    assert_false(object_is(JsValue(-0.0), JsValue(0.0)))

    var parsed = json_parse(
        JsString('{"plain":1,"2":"two","1":true,"nested":[null,"😀"]}')
    )
    assert_true(parsed.is_object())
    assert_true(object_has_own(parsed, JsString("nested")))
    var keys = object_keys(parsed)
    assert_equal(keys[0].to_native_strict(), "1")
    assert_equal(keys[1].to_native_strict(), "2")
    assert_equal(keys[2].to_native_strict(), "plain")
    assert_equal(keys[3].to_native_strict(), "nested")
    assert_equal(len(object_values(parsed)), 4)
    assert_equal(len(object_entries(parsed)), 4)

    var encoded = json_stringify(parsed)
    assert_true(Bool(encoded))
    assert_equal(
        encoded.value().to_native_strict(),
        '{"1":true,"2":"two","plain":1,"nested":[null,"😀"]}',
    )
    assert_false(Bool(json_stringify(JsValue.undefined())))
    assert_equal(
        js_value_to_string(JsValue.undefined()).to_native_strict(), "undefined"
    )
    assert_equal(js_value_to_string(JsValue.null()).to_native_strict(), "null")
    assert_equal(js_value_to_string(JsValue(True)).to_native_strict(), "true")
    assert_equal(js_value_to_string(JsValue(4.5)).to_native_strict(), "4.5")
    assert_equal(
        js_value_to_string(JsValue(JsString("text"))).to_native_strict(), "text"
    )
    assert_equal(
        js_value_to_string(parsed).to_native_strict(), "[object Object]"
    )
    assert_equal(
        js_value_to_string(
            json_parse(JsString('[null,"value",[1],{}]'))
        ).to_native_strict(),
        ",value,1,[object Object]",
    )

    try:
        _ = json_parse(JsString('{"broken":}'))
        raise Error("invalid JSON unexpectedly parsed")
    except error:
        assert_equal(String(error), "invalid JSON value")
