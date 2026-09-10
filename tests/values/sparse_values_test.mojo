from std.collections import List
from std.testing import assert_equal, assert_false, assert_true
from tsonic_runtime import (
    Callable,
    ErasedCallableContext,
    WeakReferenceIdentity,
    allocate_callable_environment,
    destroy_callable_environment,
)
from tsonic_js import (
    JsArray,
    JsString,
    JsValue,
    js_value_from_array_values,
    js_value_from_source_array,
    js_value_from_string,
    js_value_structured_clone,
    json_stringify,
    encode_structured_clone,
    decode_structured_clone,
    object_keys,
    object_values,
    object_entries,
    object_has_own,
)
from tsonic_js.inspection import inspect_value
from tsonic_js.value.builder import _JsValueBuilder


@fieldwise_init
struct SparseView:
    var source: JsArray[JsValue]

    @staticmethod
    def length(context: ErasedCallableContext, var _arguments: Tuple[]) -> Int:
        return len(context.unsafe_bitcast[Self]()[].source)

    @staticmethod
    def has(context: ErasedCallableContext, var arguments: Tuple[Int]) -> Bool:
        return context.unsafe_bitcast[Self]()[].source.has(arguments[0])

    @staticmethod
    def value(
        context: ErasedCallableContext, var arguments: Tuple[Int]
    ) -> JsValue:
        return context.unsafe_bitcast[Self]()[].source.get(arguments[0]).value()


def view(source: JsArray[JsValue]) -> JsValue:
    var environment = allocate_callable_environment(
        SparseView(source), destroy_callable_environment[SparseView]
    )
    return js_value_from_source_array(
        source.weak_identity(),
        Callable[Tuple[], Int](environment, SparseView.length),
        Callable[Tuple[Int], Bool](environment, SparseView.has),
        Callable[Tuple[Int], JsValue](environment, SparseView.value),
    )


def assert_sparse(value: JsValue) raises:
    assert_equal(value.array_length(), 3)
    assert_false(value.array_has(0))
    assert_true(value.array_at(0).is_undefined())
    assert_true(value.array_has(1))
    assert_true(value.array_at(1).is_undefined())
    assert_false(value.array_has(2))
    assert_equal(
        json_stringify(value).value().to_native_strict(), "[null,null,null]"
    )
    assert_equal(
        inspect_value(value), "[ <1 empty item>, undefined, <1 empty item> ]"
    )
    var keys = object_keys(value)
    assert_equal(len(keys), 1)
    assert_equal(keys.get(0).value(), JsString("1"))
    assert_true(object_has_own(value, JsString("length")))
    assert_false(object_has_own(value, JsString("0")))
    assert_true(object_has_own(value, JsString("1")))
    assert_equal(len(object_entries(value)), 1)
    assert_true(object_values(value).get(0).value().is_undefined())


def main() raises:
    var slots = List[Optional[JsValue]]()
    slots.append(None)
    slots.append(Optional[JsValue](JsValue()))
    slots.append(None)
    var source = JsArray[JsValue](elements=slots^)
    var live = view(source)
    assert_sparse(live)
    var cloned = js_value_structured_clone(live)
    assert_sparse(cloned)
    assert_false(cloned.same_identity(live))
    assert_sparse(decode_structured_clone(encode_structured_clone(live)))
    var outer = List[JsValue]()
    outer.append(cloned)
    assert_sparse(js_value_from_array_values(outer^).array_at(0))
    source.set(0, JsValue(Float64(7)))
    assert_true(live.array_has(0))
    assert_equal(live.array_at(0).number_value(), Float64(7))
    assert_sparse(cloned)
    var text = js_value_from_string(JsString("😀"))
    assert_equal(len(object_keys(text)), 2)
    assert_equal(
        object_values(text)
        .get(0)
        .value()
        .string_value()
        .code_unit_at(0)
        .value(),
        UInt16(0xD83D),
    )
    assert_true(object_has_own(text, JsString("length")))
    assert_false(object_has_own(text, JsString("01")))
    assert_equal(len(object_keys(JsValue(Float64(3)))), 0)
    var invalid = encode_structured_clone(cloned)
    invalid[3] = 49
    var rejected = False
    try:
        _ = decode_structured_clone(invalid^)
    except:
        rejected = True
    assert_true(rejected)
    var builder = _JsValueBuilder()
    var bad_keys = List[JsString]()
    bad_keys.append(JsString("bad"))
    var bad_children = List[Int]()
    bad_children.append(-1)
    var object = builder.append_object(bad_keys^, bad_children^)
    rejected = False
    try:
        _ = js_value_structured_clone(builder.value(object))
    except:
        rejected = True
    assert_true(rejected)
