from std.collections import List
from std.testing import assert_equal, assert_false, assert_true
from tsonic_runtime import (
    BigInt,
    ErasedCallableContext,
    RaisingCallable,
    allocate_callable_environment,
    destroy_callable_environment,
)
from tsonic_js import (
    JsString,
    JsValue,
    js_value_from_bigint,
    js_value_from_array_values,
    js_value_structured_clone,
    js_value_to_string,
    js_truthy,
    object_is,
    json_stringify,
    json_stringify_with_replacer_and_space_number,
)
from tsonic_js.inspection import inspect_value
from tsonic_js.value import encode_structured_clone, decode_structured_clone


@fieldwise_init
struct DecimalReplacer:
    @staticmethod
    def replace(
        _context: ErasedCallableContext, var arguments: Tuple[String, JsValue]
    ) raises -> JsValue:
        return JsValue(arguments[1].bigint_value()) if arguments[
            1
        ].is_bigint() else arguments[1]

    @staticmethod
    def destroy(context: ErasedCallableContext):
        destroy_callable_environment[Self](context)


def exact_integer[T: Writable](value: T, expected: String) raises:
    var retained = js_value_from_bigint(value)
    assert_true(retained.is_bigint())
    assert_false(retained.is_number())
    assert_false(retained.is_string())
    assert_equal(retained.bigint_value().to_native_strict(), expected)
    assert_equal(js_value_to_string(retained).to_native_strict(), expected)
    assert_equal(inspect_value(retained), expected + "n")
    assert_true(object_is(retained, js_value_structured_clone(retained)))
    assert_true(
        object_is(
            retained, decode_structured_clone(encode_structured_clone(retained))
        )
    )


def rejected_json(value: JsValue) raises:
    var rejected = False
    try:
        _ = json_stringify(value)
    except:
        rejected = True
    assert_true(rejected)


def main() raises:
    exact_integer(
        BigInt.from_decimal_literal(
            "12345678901234567890123456789012345678901234567890"
        ),
        "12345678901234567890123456789012345678901234567890",
    )
    exact_integer(
        -BigInt.from_decimal_literal(
            "12345678901234567890123456789012345678901234567890"
        ),
        "-12345678901234567890123456789012345678901234567890",
    )
    exact_integer(Int64(-9223372036854775808), "-9223372036854775808")
    exact_integer(UInt64(18446744073709551615), "18446744073709551615")
    exact_integer(UInt64(9007199254740993), "9007199254740993")
    exact_integer(
        Int128(-170141183460469231731687303715884105728),
        "-170141183460469231731687303715884105728",
    )
    exact_integer(
        UInt128(340282366920938463463374607431768211455),
        "340282366920938463463374607431768211455",
    )
    var first = js_value_from_bigint(UInt64(9007199254740992))
    var second = js_value_from_bigint(UInt64(9007199254740993))
    assert_false(object_is(first, second))
    assert_false(object_is(first, JsValue(Float64(9007199254740992))))
    assert_false(object_is(second, JsValue(JsString("9007199254740993"))))
    assert_true(
        object_is(
            js_value_from_bigint(Int64(1)), js_value_from_bigint(UInt64(1))
        )
    )
    assert_false(js_truthy(js_value_from_bigint(UInt64(0))))
    assert_true(js_truthy(js_value_from_bigint(Int64(-1))))
    var values = List[JsValue]()
    values.append(second)
    var nested = js_value_from_array_values(values^)
    rejected_json(second)
    rejected_json(nested)
    var context = allocate_callable_environment(
        DecimalReplacer(), DecimalReplacer.destroy
    )
    var replacer = RaisingCallable[Tuple[String, JsValue], JsValue, Error](
        context, DecimalReplacer.replace
    )
    assert_equal(
        json_stringify_with_replacer_and_space_number(nested, replacer, 0)
        .value()
        .to_native_strict(),
        '["9007199254740993"]',
    )
    var invalid_values = List[String]()
    invalid_values.append("")
    invalid_values.append("-")
    invalid_values.append("-0")
    invalid_values.append("00")
    invalid_values.append("01")
    invalid_values.append("+1")
    invalid_values.append("1.0")
    invalid_values.append("1e3")
    invalid_values.append(" 1")
    invalid_values.append("1 ")
    invalid_values.append("1n")
    invalid_values.append("１")
    invalid_values.append("😀")
    for invalid in invalid_values:
        var rejected = False
        try:
            _ = JsValue.bigint(JsString(invalid))
        except:
            rejected = True
        assert_true(rejected)
    var canonical = encode_structured_clone(js_value_from_bigint(UInt64(12)))
    for version in range(0x31, 0x34):
        var old = canonical.copy()
        old[3] = UInt8(version)
        var rejected = False
        try:
            _ = decode_structured_clone(old^)
        except:
            rejected = True
        assert_true(rejected)
    var invalid_digits = canonical.copy()
    invalid_digits[21] = UInt8(48)
    var rejected = False
    try:
        _ = decode_structured_clone(invalid_digits^)
    except:
        rejected = True
    assert_true(rejected)
