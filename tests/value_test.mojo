from std.testing import assert_equal, assert_true
from tsonic_js import JsPrimitiveValue, JsString
from tsonic_runtime import Undefined


def main() raises:
    var value = JsPrimitiveValue(Float64(4.5))
    assert_true(value.isa[Float64]())
    assert_equal(value[Float64], 4.5)

    value.set[JsString](JsString("text"))
    assert_equal(value[JsString].to_native_strict(), "text")

    value.set[Undefined](Undefined())
    assert_true(value.isa[Undefined]())
