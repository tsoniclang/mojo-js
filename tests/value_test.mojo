from std.collections import List
from std.testing import assert_equal, assert_false, assert_true
from tsonic_js import (
    JsString,
    JsValue,
    js_truthy,
    js_value_structured_clone,
    js_value_to_string,
    json_parse,
    json_stringify,
    object_entries,
    object_has_own,
    object_is,
    object_keys,
    object_values,
    symbol_new,
)
from tsonic_js.value import _JsValueBuilder

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
    assert_equal(String(JsValue(JsString("written"))), "written")
    assert_equal(
        js_value_to_string(parsed).to_native_strict(), "[object Object]"
    )
    assert_equal(
        js_value_to_string(
            json_parse(JsString('[null,"value",[1],{}]'))
        ).to_native_strict(),
        ",value,1,[object Object]",
    )

    var graph = _JsValueBuilder()
    var shared = graph.append_string(JsString("shared"))
    var children = List[Int]()
    children.append(shared)
    children.append(shared)
    var original = graph.value(graph.append_array(children^))
    var cloned = js_value_structured_clone(original)
    assert_false(cloned.same_identity(original))
    assert_true(cloned.array_at(0).same_identity(cloned.array_at(1)))
    assert_false(cloned.array_at(0).same_identity(original.array_at(0)))
    assert_equal(cloned.array_at(0).string_value().to_native_strict(), "shared")

    var unrelated = _JsValueBuilder()
    _ = unrelated.append_symbol(symbol_new(JsString("not reachable")))
    var reachable = unrelated.value(
        unrelated.append_string(JsString("reachable"))
    )
    assert_equal(
        js_value_structured_clone(reachable).string_value().to_native_strict(),
        "reachable",
    )

    var symbol_graph = _JsValueBuilder()
    var symbol = symbol_graph.value(
        symbol_graph.append_symbol(symbol_new(JsString("identity")))
    )
    try:
        _ = js_value_structured_clone(symbol)
        raise Error("symbol unexpectedly structured-cloned")
    except error:
        assert_equal(
            String(error), "JavaScript symbols cannot be structured-cloned"
        )

    try:
        _ = json_parse(JsString('{"broken":}'))
        raise Error("invalid JSON unexpectedly parsed")
    except error:
        assert_equal(String(error), "invalid JSON value")
