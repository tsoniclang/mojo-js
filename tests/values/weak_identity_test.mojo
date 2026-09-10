from std.collections import List
from std.memory import ArcPointer
from std.testing import assert_equal, assert_false, assert_true
from tsonic_js import (
    JsString,
    JsValue,
    js_value_from_array_values,
    js_value_from_source_object,
    js_value_structured_clone,
)
from tsonic_js.value import JsValueWeakIdentity
from tsonic_runtime import (
    Callable,
    ErasedCallableContext,
    Location,
    RaisingCallable,
    WeakReferenceIdentity,
    allocate_callable_environment,
    destroy_callable_environment,
)


@fieldwise_init
struct ProjectionEnvironment:
    var owner: ArcPointer[Bool]
    var destroyed: Location[Int]

    @staticmethod
    def length(_context: ErasedCallableContext, var _arguments: Tuple[]) -> Int:
        return 0

    @staticmethod
    def key(
        _context: ErasedCallableContext, var _arguments: Tuple[Int]
    ) -> JsString:
        return JsString()

    @staticmethod
    def value(
        _context: ErasedCallableContext, var _arguments: Tuple[Int]
    ) -> JsValue:
        return JsValue()

    @staticmethod
    def invoke(
        context: ErasedCallableContext, var arguments: Tuple[String]
    ) raises -> JsValue:
        return JsValue.undefined()

    @staticmethod
    def destroy(context: ErasedCallableContext):
        var environment = context.unsafe_bitcast[ProjectionEnvironment]()
        environment[].destroyed.write(environment[].destroyed.read() + 1)
        destroy_callable_environment[ProjectionEnvironment](context)


def released_aggregate() raises -> JsValueWeakIdentity:
    var value = js_value_from_array_values([JsValue(1.0)])
    var identity = JsValueWeakIdentity(value)
    assert_true(identity.is_alive())
    assert_true(identity.matches(value))
    assert_false(identity.matches(js_value_structured_clone(value)))
    var enclosing = js_value_from_array_values([value])
    assert_true(identity.matches(enclosing.array_at(0)))
    return identity


def released_projection(destroyed: Location[Int]) raises -> JsValueWeakIdentity:
    var owner = ArcPointer(False)
    var environment = allocate_callable_environment(
        ProjectionEnvironment(owner, destroyed), ProjectionEnvironment.destroy
    )
    var project = RaisingCallable[Tuple[String], JsValue](
        environment, ProjectionEnvironment.invoke
    )
    var value = js_value_from_source_object(
        WeakReferenceIdentity(owner),
        "",
        Callable[Tuple[], Int](environment, ProjectionEnvironment.length),
        Callable[Tuple[Int], JsString](environment, ProjectionEnvironment.key),
        Callable[Tuple[Int], JsValue](environment, ProjectionEnvironment.value),
        project,
    )
    var clone = js_value_structured_clone(value)
    assert_equal(clone.object_length(), 0)
    assert_false(clone.same_identity(value))
    var identity = JsValueWeakIdentity(value)
    assert_true(identity.matches(value))
    assert_true(identity.is_alive())
    return identity


def main() raises:
    var aggregate = released_aggregate()
    assert_false(aggregate.is_alive())
    assert_false(aggregate.matches(js_value_from_array_values([JsValue(1.0)])))
    var destroyed = Location(0)
    var projection = released_projection(destroyed)
    assert_equal(destroyed.read(), 1)
    assert_false(projection.is_alive())
    var primitive = JsValueWeakIdentity(JsValue(1.0))
    assert_false(primitive.is_alive())
    assert_false(primitive.matches(JsValue(1.0)))
