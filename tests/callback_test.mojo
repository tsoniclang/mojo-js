from std.collections import List
from std.memory import ArcPointer
from std.testing import assert_equal
from tsonic_js import (
    JsArray,
    JsString,
    JsValue,
    adapt_truthy_always_false_callback,
    adapt_truthy_always_true_callback,
    adapt_truthy_dynamic_callback,
    adapt_truthy_number_callback,
    adapt_truthy_string_callback,
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
    def number_truth(
        context: ErasedCallableContext,
        var arguments: Tuple[Float64],
    ) raises -> Float64:
        _ = context
        return arguments[0]

    @staticmethod
    def string_truth(
        context: ErasedCallableContext,
        var arguments: Tuple[Float64],
    ) raises -> JsString:
        _ = context
        return JsString("") if arguments[0] == 0 else JsString("present")

    @staticmethod
    def dynamic_truth(
        context: ErasedCallableContext,
        var arguments: Tuple[Float64],
    ) raises -> JsValue:
        _ = context
        return JsValue(arguments[0])

    @staticmethod
    def present_truth(
        context: ErasedCallableContext,
        var arguments: Tuple[Float64],
    ) raises -> Tuple[Float64]:
        _ = context
        return (arguments[0],)

    @staticmethod
    def absent_truth(
        context: ErasedCallableContext,
        var arguments: Tuple[Float64],
    ) raises -> None:
        _ = context
        _ = arguments

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

    var number_truth = adapt_truthy_number_callback(
        RaisingCallable[Tuple[Float64], Float64](
            environment(0, total), CallbackEnvironment.number_truth
        )
    )
    assert_equal(number_truth.call((0.0,)), False)
    assert_equal(number_truth.call((2.0,)), True)

    var string_truth = adapt_truthy_string_callback(
        RaisingCallable[Tuple[Float64], JsString](
            environment(0, total), CallbackEnvironment.string_truth
        )
    )
    assert_equal(string_truth.call((0.0,)), False)
    assert_equal(string_truth.call((2.0,)), True)

    var dynamic_truth = adapt_truthy_dynamic_callback(
        RaisingCallable[Tuple[Float64], JsValue](
            environment(0, total), CallbackEnvironment.dynamic_truth
        )
    )
    assert_equal(dynamic_truth.call((0.0,)), False)
    assert_equal(dynamic_truth.call((2.0,)), True)

    var present_truth = adapt_truthy_always_true_callback(
        RaisingCallable[Tuple[Float64], Tuple[Float64]](
            environment(0, total), CallbackEnvironment.present_truth
        )
    )
    assert_equal(present_truth.call((0.0,)), True)

    var absent_truth = adapt_truthy_always_false_callback(
        RaisingCallable[Tuple[Float64], NoneType](
            environment(0, total), CallbackEnvironment.absent_truth
        )
    )
    assert_equal(absent_truth.call((2.0,)), False)
