from std.collections import List
from std.memory import ArcPointer
from std.testing import assert_equal
from tsonic_js import (
    JsArray,
    array_filter_value,
    array_for_each_value,
    array_map_with_index,
    array_reduce_initial_value,
    array_sort_compare,
)
from tsonic_runtime import (
    ErasedCallableContext,
    Location,
    RaisingCallable,
    allocate_callable_environment,
    destroy_callable_environment,
)
from tsonic_runtime.callable import ErasedCallableEnvironment


@fieldwise_init
struct CallbackEnvironment:
    var offset: Float64
    var total: Location[Float64]

    @staticmethod
    def map_with_index(
        context: ErasedCallableContext,
        var arguments: Tuple[Float64, Float64],
    ) raises -> Float64:
        var environment = context.unsafe_bitcast[CallbackEnvironment]()
        return environment[].offset + arguments[0] + arguments[1]

    @staticmethod
    def greater_than_one(
        context: ErasedCallableContext,
        var arguments: Tuple[Float64],
    ) raises -> Bool:
        _ = context
        return arguments[0] > 1

    @staticmethod
    def add(
        context: ErasedCallableContext,
        var arguments: Tuple[Float64, Float64],
    ) raises -> Float64:
        _ = context
        return arguments[0] + arguments[1]

    @staticmethod
    def compare(
        context: ErasedCallableContext,
        var arguments: Tuple[Float64, Float64],
    ) raises -> Float64:
        _ = context
        return arguments[0] - arguments[1]

    @staticmethod
    def visit(
        context: ErasedCallableContext,
        var arguments: Tuple[Float64],
    ) raises -> None:
        var environment = context.unsafe_bitcast[CallbackEnvironment]()
        environment[].total.write(environment[].total.read() + arguments[0])

    @staticmethod
    def destroy(context: ErasedCallableContext):
        destroy_callable_environment[CallbackEnvironment](context)


def environment(
    offset: Float64, total: Location[Float64]
) -> ArcPointer[ErasedCallableEnvironment]:
    return allocate_callable_environment(
        CallbackEnvironment(offset, total), CallbackEnvironment.destroy
    )


def main() raises:
    var values = List[Float64]()
    values.append(3)
    values.append(1)
    values.append(2)
    var array = JsArray[Float64](values^)

    var total = Location[Float64](0)
    var mapped = array_map_with_index(
        array,
        RaisingCallable[Tuple[Float64, Float64], Float64](
            environment(10, total), CallbackEnvironment.map_with_index
        ),
    )
    assert_equal(mapped.get(0).value(), 13)
    assert_equal(mapped.get(1).value(), 12)
    assert_equal(mapped.get(2).value(), 14)

    var filtered = array_filter_value(
        array,
        RaisingCallable[Tuple[Float64], Bool](
            environment(0, total), CallbackEnvironment.greater_than_one
        ),
    )
    assert_equal(len(filtered), 2)
    assert_equal(filtered.get(0).value(), 3)
    assert_equal(filtered.get(1).value(), 2)

    var reduced = array_reduce_initial_value(
        array,
        RaisingCallable[Tuple[Float64, Float64], Float64](
            environment(0, total), CallbackEnvironment.add
        ),
        0,
    )
    assert_equal(reduced, 6)

    _ = array_sort_compare(
        array,
        RaisingCallable[Tuple[Float64, Float64], Float64](
            environment(0, total), CallbackEnvironment.compare
        ),
    )
    assert_equal(array.get(0).value(), 1)
    assert_equal(array.get(1).value(), 2)
    assert_equal(array.get(2).value(), 3)

    array_for_each_value(
        array,
        RaisingCallable[Tuple[Float64], NoneType](
            environment(0, total), CallbackEnvironment.visit
        ),
    )
    assert_equal(total.read(), 6)
