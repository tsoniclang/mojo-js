from std.testing import assert_false, assert_true
from tsonic_js import JsString, JsValue, json_parse, symbol_new
from tsonic_js.object import object_is, strict_equal


def main() raises:
    assert_true(strict_equal(JsValue(-0.0), JsValue(0.0)))
    assert_false(object_is(JsValue(-0.0), JsValue(0.0)))
    var nan = JsValue(Float64(FloatLiteral.nan))
    assert_false(strict_equal(nan, nan))
    assert_true(object_is(nan, nan))
    assert_true(strict_equal(JsValue(1.0), JsValue(1.0)))
    assert_false(strict_equal(JsValue(1.0), JsValue(True)))
    assert_false(strict_equal(JsValue(1.0), JsValue(JsString("1"))))
    assert_true(strict_equal(JsValue(True), JsValue(True)))
    assert_true(strict_equal(JsValue.null(), JsValue.null()))
    assert_true(strict_equal(JsValue.undefined(), JsValue.undefined()))
    assert_false(strict_equal(JsValue.null(), JsValue.undefined()))
    assert_true(
        strict_equal(JsValue(JsString("proof")), JsValue(JsString("proof")))
    )
    var object = json_parse(JsString("{}"))
    assert_true(strict_equal(object, object))
    assert_false(strict_equal(object, json_parse(JsString("{}"))))
    var array = json_parse(JsString("[]"))
    assert_true(strict_equal(array, array))
    assert_false(strict_equal(array, json_parse(JsString("[]"))))
    var symbol = symbol_new(JsString("id"))
    assert_true(strict_equal(JsValue(symbol), JsValue(symbol)))
    assert_false(
        strict_equal(JsValue(symbol), JsValue(symbol_new(JsString("id"))))
    )
