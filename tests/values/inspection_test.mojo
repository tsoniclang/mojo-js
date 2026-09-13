from std.collections import List
from std.testing import assert_equal
from tsonic_js import JsString, JsValue
from tsonic_js.inspection import inspect_value, quote_inspected_string
from tsonic_js.value import _JsValueBuilder


def main() raises:
    var builder = _JsValueBuilder()
    var one = builder.append_number(1)
    var name = builder.append_string(JsString("Alice"))
    var array = builder.append_array([one, name])
    var object = builder.append_object(
        [JsString("items"), JsString("not plain")], [array, name]
    )
    assert_equal(inspect_value(builder.value(array)), "[ 1, 'Alice' ]")
    assert_equal(
        inspect_value(builder.value(object)),
        "{ items: [ 1, 'Alice' ], 'not plain': 'Alice' }",
    )
    assert_equal(
        inspect_value(builder.value(object), 0),
        "{ items: [Array], 'not plain': 'Alice' }",
    )
    assert_equal(
        inspect_value(builder.value(array), 2, 1), "[ 1, ... 1 more item ]"
    )
    assert_equal(quote_inspected_string(JsString("😀\n'\\")), "'😀\\n\\'\\\\'")
    var lone = JsString(code_units=[0xD800])
    assert_equal(quote_inspected_string(lone), "'\\ud800'")
    var cycle = builder.append_array(List[Int]())
    var value = builder.value(cycle)
    value._storage()[][cycle].children.append(cycle)
    assert_equal(inspect_value(value), "[ [Circular] ]")
