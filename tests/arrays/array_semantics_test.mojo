from std.testing import assert_equal, assert_false, assert_true
from tsonic_runtime.nullish import Null, Undefined
from tsonic_js import (
    JsArray,
    JsString,
    JsValue,
    array_from,
    array_join_native,
    array_new,
)
from tsonic_js.symbol import symbol_new
from tsonic_js.value import (
    js_value_from_null,
    js_value_from_number,
    js_value_from_string,
    js_value_from_undefined,
    js_value_from_symbol,
)


def stringification() raises:
    assert_equal(array_join_native(JsArray[Float64]([0, 1])), "0,1")
    assert_equal(array_join_native(JsArray[Float64]([0, 1]), "|"), "0|1")
    assert_equal(array_join_native(JsArray[Bool]([True, False])), "true,false")
    assert_equal(array_join_native(JsArray[Float64]([-0.0, 1.5])), "0,1.5")
    assert_equal(
        array_join_native(
            JsArray[Float64](
                [
                    Float64(FloatLiteral.nan),
                    Float64(FloatLiteral.infinity),
                    Float64(FloatLiteral.negative_infinity),
                    1e21,
                    1e-7,
                ]
            )
        ),
        "NaN,Infinity,-Infinity,1e+21,1e-7",
    )
    assert_equal(array_join_native(JsArray[Null]([Null(), Null()])), ",")
    assert_equal(array_join_native(JsArray[Undefined]([Undefined()])), "")
    assert_equal(
        array_join_native(
            JsArray[JsValue](
                [
                    js_value_from_number(0),
                    js_value_from_null(),
                    js_value_from_undefined(),
                    js_value_from_string(JsString("tail")),
                ]
            ),
            "|",
        ),
        "0|||tail",
    )
    var units = JsArray[JsString](
        [
            JsString(code_units=[UInt16(0xD800)]),
            JsString("x"),
        ]
    ).join(JsString())
    assert_equal(len(units), 2)
    assert_equal(units.code_unit_at(0).value(), UInt16(0xD800))
    assert_equal(units.code_unit_at(1).value(), UInt16(120))
    var rejected = False
    try:
        _ = array_join_native(
            JsArray[JsString]([JsString(code_units=[UInt16(0xD800)])])
        )
    except:
        rejected = True
    assert_true(rejected)
    assert_equal(
        array_join_native(
            JsArray[JsString](
                [
                    JsString(code_units=[UInt16(0xD83D)]),
                    JsString(code_units=[UInt16(0xDE00)]),
                ]
            ),
            "",
        ),
        "😀",
    )


def ordering() raises:
    var numbers = JsArray[Float64]([10, 1, 2, -1, 1.1])
    _ = numbers.sort()
    assert_equal(array_join_native(numbers), "-1,1,1.1,10,2")
    var strings = JsArray[String](["\uE000", "😀", "a"])
    _ = strings.sort()
    assert_equal(array_join_native(strings), "a,😀,\uE000")
    var values = JsArray[JsValue](
        [
            js_value_from_undefined(),
            js_value_from_string(JsString("z")),
            js_value_from_null(),
            js_value_from_number(1),
        ]
    )
    values.set(5, js_value_from_number(2))
    _ = values.sort()
    assert_equal(array_join_native(values), "1,2,,z,,")
    assert_true(values.has(4))
    assert_true(values.get(4).value().is_undefined())
    assert_false(values.has(5))


def indexes() raises:
    var values = JsArray[Float64]([10, 20, 10])
    var nan = Float64(FloatLiteral.nan)
    var infinity = Float64(FloatLiteral.infinity)
    assert_equal(values.last_index_of(10, -1), 2)
    assert_equal(values.last_index_of(10, -2), 0)
    assert_equal(values.last_index_of(10, -3.9), 0)
    assert_equal(values.last_index_of(10, -4), -1)
    assert_equal(values.last_index_of(10, nan), 0)
    assert_equal(values.last_index_of(10, infinity), 2)
    assert_equal(values.last_index_of(10, -infinity), -1)
    assert_equal(values.index_of(10, nan), 0)
    assert_equal(values.index_of(10, infinity), -1)
    assert_equal(values.index_of(10, -infinity), 0)
    assert_equal(values.at(nan).value(), 10)
    assert_equal(values.at(-3.9).value(), 10)
    assert_false(values.at(infinity))
    assert_false(values.at(-infinity))
    assert_false(values.get_index(0.5))
    assert_false(values.get_index(1e100))
    assert_false(values.get_index(nan))
    assert_equal(len(values.slice(nan)), 3)
    assert_equal(len(values.slice(infinity)), 0)
    assert_equal(len(values.slice(-infinity)), 3)
    assert_equal(len(values.splice(1, nan, items=[])), 0)
    assert_equal(len(values.splice(1, -infinity, items=[])), 0)
    assert_equal(len(values.splice(1, infinity, items=[])), 2)


def copying() raises:
    var original = JsArray[Float64]([1, 2])
    var copied = array_from(original)
    assert_false(original.same_storage(copied))
    copied.set(0, 9)
    assert_equal(original.get(0).value(), 1)
    assert_equal(copied.get(0).value(), 9)
    _ = original.push([3])
    assert_equal(len(original), 3)
    assert_equal(len(copied), 2)


def constructors() raises:
    var sized = array_new[Float64]([3])
    assert_equal(len(sized), 3)
    assert_false(sized.has(0))
    assert_equal(array_join_native(sized), ",,")
    assert_equal(array_join_native(array_new[String](["3"])), "3")
    assert_equal(array_join_native(array_new[Float64]([3, 4])), "3,4")
    for invalid in [-1.0, 1.5, 4294967296.0, Float64(FloatLiteral.nan)]:
        var rejected = False
        try:
            _ = array_new[Float64]([invalid])
        except:
            rejected = True
        assert_true(rejected)
    var symbols = JsArray[JsValue]([js_value_from_symbol(symbol_new())])
    var rejected = False
    try:
        _ = symbols.join()
    except:
        rejected = True
    assert_true(rejected)


def main() raises:
    stringification()
    ordering()
    indexes()
    copying()
    constructors()
