from std.testing import assert_equal
from tsonic_js import JsValue, JsString


def main() raises:
    assert_equal(JsValue.undefined().type_of(), "undefined")
    assert_equal(JsValue.null().type_of(), "object")
    assert_equal(JsValue(True).type_of(), "boolean")
    assert_equal(JsValue(2.5).type_of(), "number")
    assert_equal(JsValue(JsString("text")).type_of(), "string")
    assert_equal(
        JsValue.bigint(JsString("9007199254740993")).type_of(), "bigint"
    )
