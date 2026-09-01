from tsonic_runtime import (
    ErasedCallableContext,
    RaisingCallable,
    allocate_callable_environment,
    destroy_callable_environment,
)

from .string import JsString
from .value import JsValue, js_truthy


@fieldwise_init
struct _NumberTruthinessAdapter[Arguments: Movable & Deinitable]:
    var callable: RaisingCallable[Self.Arguments, Float64]

    @staticmethod
    def invoke(
        context: ErasedCallableContext,
        var arguments: Self.Arguments,
    ) raises -> Bool:
        var pointer = context.unsafe_bitcast[
            _NumberTruthinessAdapter[Self.Arguments]
        ]()
        var value = pointer[].callable.call(arguments^)
        return value != 0 and value == value

    @staticmethod
    def destroy(context: ErasedCallableContext):
        destroy_callable_environment[_NumberTruthinessAdapter[Self.Arguments]](
            context
        )


def adapt_truthy_number_callback[
    Arguments: Movable & Deinitable
](
    value: RaisingCallable[Arguments, Float64],
) -> RaisingCallable[
    Arguments, Bool
]:
    comptime Adapter = _NumberTruthinessAdapter[Arguments]
    var environment = allocate_callable_environment(
        Adapter(value), Adapter.destroy
    )
    return RaisingCallable[Arguments, Bool](environment, Adapter.invoke)


@fieldwise_init
struct _StringTruthinessAdapter[Arguments: Movable & Deinitable]:
    var callable: RaisingCallable[Self.Arguments, JsString]

    @staticmethod
    def invoke(
        context: ErasedCallableContext,
        var arguments: Self.Arguments,
    ) raises -> Bool:
        var pointer = context.unsafe_bitcast[
            _StringTruthinessAdapter[Self.Arguments]
        ]()
        return len(pointer[].callable.call(arguments^)) != 0

    @staticmethod
    def destroy(context: ErasedCallableContext):
        destroy_callable_environment[_StringTruthinessAdapter[Self.Arguments]](
            context
        )


def adapt_truthy_string_callback[
    Arguments: Movable & Deinitable
](
    value: RaisingCallable[Arguments, JsString],
) -> RaisingCallable[
    Arguments, Bool
]:
    comptime Adapter = _StringTruthinessAdapter[Arguments]
    var environment = allocate_callable_environment(
        Adapter(value), Adapter.destroy
    )
    return RaisingCallable[Arguments, Bool](environment, Adapter.invoke)


@fieldwise_init
struct _DynamicTruthinessAdapter[Arguments: Movable & Deinitable]:
    var callable: RaisingCallable[Self.Arguments, JsValue]

    @staticmethod
    def invoke(
        context: ErasedCallableContext,
        var arguments: Self.Arguments,
    ) raises -> Bool:
        var pointer = context.unsafe_bitcast[
            _DynamicTruthinessAdapter[Self.Arguments]
        ]()
        return js_truthy(pointer[].callable.call(arguments^))

    @staticmethod
    def destroy(context: ErasedCallableContext):
        destroy_callable_environment[_DynamicTruthinessAdapter[Self.Arguments]](
            context
        )


def adapt_truthy_dynamic_callback[
    Arguments: Movable & Deinitable
](
    value: RaisingCallable[Arguments, JsValue],
) -> RaisingCallable[
    Arguments, Bool
]:
    comptime Adapter = _DynamicTruthinessAdapter[Arguments]
    var environment = allocate_callable_environment(
        Adapter(value), Adapter.destroy
    )
    return RaisingCallable[Arguments, Bool](environment, Adapter.invoke)


@fieldwise_init
struct _PresentTruthinessAdapter[
    Arguments: Movable & Deinitable,
    Result: Movable & Deinitable,
]:
    var callable: RaisingCallable[Self.Arguments, Self.Result]

    @staticmethod
    def invoke(
        context: ErasedCallableContext,
        var arguments: Self.Arguments,
    ) raises -> Bool:
        var pointer = context.unsafe_bitcast[
            _PresentTruthinessAdapter[Self.Arguments, Self.Result]
        ]()
        _ = pointer[].callable.call(arguments^)
        return True

    @staticmethod
    def destroy(context: ErasedCallableContext):
        destroy_callable_environment[
            _PresentTruthinessAdapter[Self.Arguments, Self.Result]
        ](context)


def adapt_truthy_always_true_callback[
    Arguments: Movable & Deinitable,
    Result: Movable & Deinitable,
](
    value: RaisingCallable[Arguments, Result],
) -> RaisingCallable[
    Arguments, Bool
]:
    comptime Adapter = _PresentTruthinessAdapter[Arguments, Result]
    var environment = allocate_callable_environment(
        Adapter(value), Adapter.destroy
    )
    return RaisingCallable[Arguments, Bool](environment, Adapter.invoke)


@fieldwise_init
struct _AbsentTruthinessAdapter[
    Arguments: Movable & Deinitable,
    Result: Movable & Deinitable,
]:
    var callable: RaisingCallable[Self.Arguments, Self.Result]

    @staticmethod
    def invoke(
        context: ErasedCallableContext,
        var arguments: Self.Arguments,
    ) raises -> Bool:
        var pointer = context.unsafe_bitcast[
            _AbsentTruthinessAdapter[Self.Arguments, Self.Result]
        ]()
        _ = pointer[].callable.call(arguments^)
        return False

    @staticmethod
    def destroy(context: ErasedCallableContext):
        destroy_callable_environment[
            _AbsentTruthinessAdapter[Self.Arguments, Self.Result]
        ](context)


def adapt_truthy_always_false_callback[
    Arguments: Movable & Deinitable,
    Result: Movable & Deinitable,
](
    value: RaisingCallable[Arguments, Result],
) -> RaisingCallable[
    Arguments, Bool
]:
    comptime Adapter = _AbsentTruthinessAdapter[Arguments, Result]
    var environment = allocate_callable_environment(
        Adapter(value), Adapter.destroy
    )
    return RaisingCallable[Arguments, Bool](environment, Adapter.invoke)
