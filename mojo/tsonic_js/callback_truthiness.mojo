from tsonic_runtime import (
    ErasedCallableContext,
    RaisingCallable,
    allocate_callable_environment,
    destroy_callable_environment,
)

from .string import JsString
from .value import JsValue, js_truthy


@fieldwise_init
struct _NumberTruthinessAdapter[
    Arguments: Movable & Deinitable,
    CallbackError: AnyType,
]:
    var callable: RaisingCallable[Self.Arguments, Float64, Self.CallbackError]

    @staticmethod
    def invoke(
        context: ErasedCallableContext,
        var arguments: Self.Arguments,
    ) raises Self.CallbackError -> Bool:
        var pointer = context.unsafe_bitcast[
            _NumberTruthinessAdapter[Self.Arguments, Self.CallbackError]
        ]()
        var value = pointer[].callable.call(arguments^)
        return value != 0 and value == value

    @staticmethod
    def destroy(context: ErasedCallableContext):
        destroy_callable_environment[
            _NumberTruthinessAdapter[Self.Arguments, Self.CallbackError]
        ](context)


def adapt_truthy_number_callback[
    Arguments: Movable & Deinitable,
    CallbackError: AnyType,
](
    value: RaisingCallable[Arguments, Float64, CallbackError],
) -> RaisingCallable[Arguments, Bool, CallbackError]:
    comptime Adapter = _NumberTruthinessAdapter[Arguments, CallbackError]
    var environment = allocate_callable_environment(
        Adapter(value), Adapter.destroy
    )
    return RaisingCallable[Arguments, Bool, CallbackError](
        environment, Adapter.invoke
    )


@fieldwise_init
struct _StringTruthinessAdapter[
    Arguments: Movable & Deinitable,
    CallbackError: AnyType,
]:
    var callable: RaisingCallable[Self.Arguments, JsString, Self.CallbackError]

    @staticmethod
    def invoke(
        context: ErasedCallableContext,
        var arguments: Self.Arguments,
    ) raises Self.CallbackError -> Bool:
        var pointer = context.unsafe_bitcast[
            _StringTruthinessAdapter[Self.Arguments, Self.CallbackError]
        ]()
        return len(pointer[].callable.call(arguments^)) != 0

    @staticmethod
    def destroy(context: ErasedCallableContext):
        destroy_callable_environment[
            _StringTruthinessAdapter[Self.Arguments, Self.CallbackError]
        ](context)


def adapt_truthy_string_callback[
    Arguments: Movable & Deinitable,
    CallbackError: AnyType,
](
    value: RaisingCallable[Arguments, JsString, CallbackError],
) -> RaisingCallable[Arguments, Bool, CallbackError]:
    comptime Adapter = _StringTruthinessAdapter[Arguments, CallbackError]
    var environment = allocate_callable_environment(
        Adapter(value), Adapter.destroy
    )
    return RaisingCallable[Arguments, Bool, CallbackError](
        environment, Adapter.invoke
    )


@fieldwise_init
struct _NativeStringTruthinessAdapter[
    Arguments: Movable & Deinitable,
    CallbackError: AnyType,
]:
    var callable: RaisingCallable[Self.Arguments, String, Self.CallbackError]

    @staticmethod
    def invoke(
        context: ErasedCallableContext,
        var arguments: Self.Arguments,
    ) raises Self.CallbackError -> Bool:
        var pointer = context.unsafe_bitcast[
            _NativeStringTruthinessAdapter[Self.Arguments, Self.CallbackError]
        ]()
        return pointer[].callable.call(arguments^).byte_length() != 0

    @staticmethod
    def destroy(context: ErasedCallableContext):
        destroy_callable_environment[
            _NativeStringTruthinessAdapter[Self.Arguments, Self.CallbackError]
        ](context)


def adapt_truthy_native_string_callback[
    Arguments: Movable & Deinitable,
    CallbackError: AnyType,
](
    value: RaisingCallable[Arguments, String, CallbackError],
) -> RaisingCallable[Arguments, Bool, CallbackError]:
    comptime Adapter = _NativeStringTruthinessAdapter[Arguments, CallbackError]
    var environment = allocate_callable_environment(
        Adapter(value), Adapter.destroy
    )
    return RaisingCallable[Arguments, Bool, CallbackError](
        environment, Adapter.invoke
    )


@fieldwise_init
struct _DynamicTruthinessAdapter[
    Arguments: Movable & Deinitable,
    CallbackError: AnyType,
]:
    var callable: RaisingCallable[Self.Arguments, JsValue, Self.CallbackError]

    @staticmethod
    def invoke(
        context: ErasedCallableContext,
        var arguments: Self.Arguments,
    ) raises Self.CallbackError -> Bool:
        var pointer = context.unsafe_bitcast[
            _DynamicTruthinessAdapter[Self.Arguments, Self.CallbackError]
        ]()
        return js_truthy(pointer[].callable.call(arguments^))

    @staticmethod
    def destroy(context: ErasedCallableContext):
        destroy_callable_environment[
            _DynamicTruthinessAdapter[Self.Arguments, Self.CallbackError]
        ](context)


def adapt_truthy_dynamic_callback[
    Arguments: Movable & Deinitable,
    CallbackError: AnyType,
](
    value: RaisingCallable[Arguments, JsValue, CallbackError],
) -> RaisingCallable[Arguments, Bool, CallbackError]:
    comptime Adapter = _DynamicTruthinessAdapter[Arguments, CallbackError]
    var environment = allocate_callable_environment(
        Adapter(value), Adapter.destroy
    )
    return RaisingCallable[Arguments, Bool, CallbackError](
        environment, Adapter.invoke
    )


@fieldwise_init
struct _PresentTruthinessAdapter[
    Arguments: Movable & Deinitable,
    Result: Movable & Deinitable,
    CallbackError: AnyType,
]:
    var callable: RaisingCallable[
        Self.Arguments, Self.Result, Self.CallbackError
    ]

    @staticmethod
    def invoke(
        context: ErasedCallableContext,
        var arguments: Self.Arguments,
    ) raises Self.CallbackError -> Bool:
        var pointer = context.unsafe_bitcast[
            _PresentTruthinessAdapter[
                Self.Arguments, Self.Result, Self.CallbackError
            ]
        ]()
        _ = pointer[].callable.call(arguments^)
        return True

    @staticmethod
    def destroy(context: ErasedCallableContext):
        destroy_callable_environment[
            _PresentTruthinessAdapter[
                Self.Arguments, Self.Result, Self.CallbackError
            ]
        ](context)


def adapt_truthy_always_true_callback[
    Arguments: Movable & Deinitable,
    Result: Movable & Deinitable,
    CallbackError: AnyType,
](
    value: RaisingCallable[Arguments, Result, CallbackError],
) -> RaisingCallable[
    Arguments, Bool, CallbackError
]:
    comptime Adapter = _PresentTruthinessAdapter[
        Arguments, Result, CallbackError
    ]
    var environment = allocate_callable_environment(
        Adapter(value), Adapter.destroy
    )
    return RaisingCallable[Arguments, Bool, CallbackError](
        environment, Adapter.invoke
    )


@fieldwise_init
struct _AbsentTruthinessAdapter[
    Arguments: Movable & Deinitable,
    Result: Movable & Deinitable,
    CallbackError: AnyType,
]:
    var callable: RaisingCallable[
        Self.Arguments, Self.Result, Self.CallbackError
    ]

    @staticmethod
    def invoke(
        context: ErasedCallableContext,
        var arguments: Self.Arguments,
    ) raises Self.CallbackError -> Bool:
        var pointer = context.unsafe_bitcast[
            _AbsentTruthinessAdapter[
                Self.Arguments, Self.Result, Self.CallbackError
            ]
        ]()
        _ = pointer[].callable.call(arguments^)
        return False

    @staticmethod
    def destroy(context: ErasedCallableContext):
        destroy_callable_environment[
            _AbsentTruthinessAdapter[
                Self.Arguments, Self.Result, Self.CallbackError
            ]
        ](context)


def adapt_truthy_always_false_callback[
    Arguments: Movable & Deinitable,
    Result: Movable & Deinitable,
    CallbackError: AnyType,
](
    value: RaisingCallable[Arguments, Result, CallbackError],
) -> RaisingCallable[
    Arguments, Bool, CallbackError
]:
    comptime Adapter = _AbsentTruthinessAdapter[
        Arguments, Result, CallbackError
    ]
    var environment = allocate_callable_environment(
        Adapter(value), Adapter.destroy
    )
    return RaisingCallable[Arguments, Bool, CallbackError](
        environment, Adapter.invoke
    )
