from std.collections import List
from std.memory import ArcPointer
from std.testing import assert_equal, assert_false, assert_true
from tsonic_runtime import Callable, ErasedCallableContext, RaisingCallable, WeakReferenceIdentity, allocate_callable_environment, destroy_callable_environment
from tsonic_js import (
    JsString, JsValue, js_value_from_array_values, js_value_from_source_array,
    js_value_from_source_object, js_value_structured_clone, json_stringify,
    encode_structured_clone, decode_structured_clone, object_keys,
)
from tsonic_js.inspection import inspect_value
from tsonic_js.value import JsValueWeakIdentity
from tsonic_js.array_values import _implicit_value_string


@fieldwise_init
struct SourceState:
    var count: Int
    var reads: Int
    var json_calls: Int
    var recursive: Bool
    var return_self: Bool


@fieldwise_init
struct SourceAdapter:
    var owner: ArcPointer[SourceState]
    var array: Bool

    @staticmethod
    def length(context: ErasedCallableContext, var _arguments: Tuple[]) -> Int:
        return 2 if context.unsafe_bitcast[Self]()[].owner[].recursive else 1

    @staticmethod
    def key(_context: ErasedCallableContext, var arguments: Tuple[Int]) -> JsString:
        return JsString("count" if arguments[0] == 0 else "self")

    @staticmethod
    def has(context: ErasedCallableContext, var arguments: Tuple[Int]) -> Bool:
        return arguments[0] >= 0 and arguments[0] < Self.length(context, ())

    @staticmethod
    def value(context: ErasedCallableContext, var arguments: Tuple[Int]) -> JsValue:
        var owner = context.unsafe_bitcast[Self]()[].owner
        owner[].reads += 1
        if arguments[0] == 0:
            return JsValue(Float64(owner[].count))
        return source_view(owner, array=context.unsafe_bitcast[Self]()[].array)

    @staticmethod
    def project(context: ErasedCallableContext, var _arguments: Tuple[String]) raises -> JsValue:
        var owner = context.unsafe_bitcast[Self]()[].owner
        owner[].json_calls += 1
        if owner[].return_self:
            return source_view(owner, selected_json=True)
        return JsValue(Float64(owner[].count))


def source_view(owner: ArcPointer[SourceState], selected_json: Bool = False, array: Bool = False) -> JsValue:
    var environment = allocate_callable_environment(SourceAdapter(owner, array), destroy_callable_environment[SourceAdapter])
    var length = Callable[Tuple[], Int](environment, SourceAdapter.length)
    var value = Callable[Tuple[Int], JsValue](environment, SourceAdapter.value)
    if array:
        var has = Callable[Tuple[Int], Bool](environment, SourceAdapter.has)
        return js_value_from_source_array(WeakReferenceIdentity(owner), length, has, value)
    var key = Callable[Tuple[Int], JsString](environment, SourceAdapter.key)
    var projection = Optional[RaisingCallable[Tuple[String], JsValue, Error]]()
    if selected_json:
        projection = RaisingCallable[Tuple[String], JsValue, Error](environment, SourceAdapter.project)
    return js_value_from_source_object(WeakReferenceIdentity(owner), length, key, value, projection)


def weak_temporary(owner: ArcPointer[SourceState]) -> JsValueWeakIdentity:
    return JsValueWeakIdentity(source_view(owner))


def released() -> JsValueWeakIdentity:
    var owner = ArcPointer(SourceState(1, 0, 0, False, False))
    return weak_temporary(owner)


def main() raises:
    var owner = ArcPointer(SourceState(1, 0, 0, False, False))
    var view = source_view(owner, selected_json=True)
    assert_equal(owner[].reads, 0)
    owner[].count = 2
    assert_equal(inspect_value(view), "{ count: 2 }")
    assert_equal(owner[].reads, 1)
    assert_equal(owner[].json_calls, 0)
    assert_equal(json_stringify(view).value().to_native_strict(), "2")
    assert_equal(owner[].json_calls, 1)
    assert_equal(owner[].reads, 1)
    assert_equal(len(object_keys(view)), 1)
    assert_equal(owner[].reads, 1)
    var weak = weak_temporary(owner)
    assert_true(weak.is_alive())
    assert_true(weak.matches(source_view(owner)))
    assert_true(view.same_identity(source_view(owner)))
    assert_false(released().is_alive())
    owner[].count = 3
    assert_equal(inspect_value(view), "{ count: 3 }")
    var inputs = List[JsValue]()
    inputs.append(view)
    inputs.append(source_view(owner))
    var enclosing = js_value_from_array_values(inputs^)
    owner[].count = 4
    assert_equal(enclosing.array_at(0).object_value(0)._number_value(), 4)
    var cloned = js_value_structured_clone(enclosing)
    assert_true(cloned.array_at(0).same_identity(cloned.array_at(1)))
    assert_false(cloned.array_at(0).same_identity(view))
    assert_equal(owner[].json_calls, 1)
    owner[].count = 5
    assert_equal(cloned.array_at(0).object_value(0)._number_value(), 4)
    assert_equal(enclosing.array_at(0).object_value(0)._number_value(), 5)
    var recursive_owner = ArcPointer(SourceState(7, 0, 0, True, False))
    var recursive_view = source_view(recursive_owner)
    assert_equal(inspect_value(recursive_view), "{ count: 7, self: [Circular] }")
    var recursive_clone = js_value_structured_clone(recursive_view)
    assert_true(recursive_clone.same_identity(recursive_clone.object_value(1)))
    var transported = decode_structured_clone(encode_structured_clone(recursive_view))
    assert_true(transported.same_identity(transported.object_value(1)))
    var rejected = False
    try:
        _ = json_stringify(recursive_view)
    except:
        rejected = True
    assert_true(rejected)
    owner[].return_self = True
    assert_equal(json_stringify(view).value().to_native_strict(), '{"count":5}')
    var array_view = source_view(owner, array=True)
    assert_equal(inspect_value(array_view), "[ 5 ]")
    assert_equal(_implicit_value_string(array_view).to_native_strict(), "5")
    owner[].count = 6
    assert_equal(_implicit_value_string(array_view).to_native_strict(), "6")
    var recursive_array = source_view(recursive_owner, array=True)
    assert_equal(_implicit_value_string(recursive_array).to_native_strict(), "7,")
    var array_clone = js_value_structured_clone(recursive_array)
    assert_true(array_clone.same_identity(array_clone.array_at(1)))
