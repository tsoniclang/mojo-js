from std.testing import assert_equal, assert_true
from tsonic_js import JsString, JsValue, js_value_from_null
from tsonic_js.value.extraction import (
    js_value_bool,
    js_value_number,
    js_value_native_string,
    js_value_null,
    js_value_undefined,
)


def main() raises:
    assert_equal(js_value_number(JsValue(Float64(1.25))), 1.25)
    assert_equal(js_value_native_string(JsValue(JsString("text"))), "text")
    assert_true(js_value_bool(JsValue(True)))
    _ = js_value_null(js_value_from_null())
    _ = js_value_undefined(JsValue())
    var rejected = False
    try:
        _ = js_value_number(JsValue(JsString("1")))
    except:
        rejected = True
    assert_true(rejected)
