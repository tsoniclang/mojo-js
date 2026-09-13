from std.collections import List
from std.memory import ArcPointer
from std.testing import assert_equal
from tsonic_runtime import (
    Callable,
    ErasedCallableContext,
    RaisingCallable,
    WeakReferenceIdentity,
    allocate_callable_environment,
    destroy_callable_environment,
)
from tsonic_js import (
    JsString,
    JsValue,
    js_value_from_source_array,
    js_value_from_source_object,
    json_stringify_with_space_number,
)


@fieldwise_init
struct ArrayOwner:
    var values: List[JsValue]


@fieldwise_init
struct ArrayView:
    var owner: ArcPointer[ArrayOwner]

    @staticmethod
    def length(context: ErasedCallableContext, var _arguments: Tuple[]) -> Int:
        return len(context.unsafe_bitcast[Self]()[].owner[].values)

    @staticmethod
    def has(context: ErasedCallableContext, var arguments: Tuple[Int]) -> Bool:
        return arguments[0] >= 0 and arguments[0] < len(
            context.unsafe_bitcast[Self]()[].owner[].values
        )

    @staticmethod
    def value(
        context: ErasedCallableContext, var arguments: Tuple[Int]
    ) -> JsValue:
        return context.unsafe_bitcast[Self]()[].owner[].values[arguments[0]]

    @staticmethod
    def destroy(context: ErasedCallableContext):
        destroy_callable_environment[Self](context)


@fieldwise_init
struct ItemView:
    var owner: ArcPointer[ArrayOwner]
    var identity: ArcPointer[Bool]

    @staticmethod
    def object_length(
        _context: ErasedCallableContext, var _arguments: Tuple[]
    ) -> Int:
        return 0

    @staticmethod
    def object_key(
        _context: ErasedCallableContext, var _arguments: Tuple[Int]
    ) -> JsString:
        return JsString()

    @staticmethod
    def object_value(
        _context: ErasedCallableContext, var _arguments: Tuple[Int]
    ) -> JsValue:
        return JsValue()

    @staticmethod
    def shrink(
        context: ErasedCallableContext, var _arguments: Tuple[String]
    ) raises -> JsValue:
        context.unsafe_bitcast[Self]()[].owner[].values.clear()
        return JsValue(9.0)

    @staticmethod
    def destroy(context: ErasedCallableContext):
        destroy_callable_environment[Self](context)


def main() raises:
    var owner = ArcPointer(ArrayOwner(List[JsValue]()))
    var environment = allocate_callable_environment(
        ArrayView(owner), ArrayView.destroy
    )
    var array = js_value_from_source_array(
        WeakReferenceIdentity(owner),
        Callable[Tuple[], Int](environment, ArrayView.length),
        Callable[Tuple[Int], Bool](environment, ArrayView.has),
        Callable[Tuple[Int], JsValue](environment, ArrayView.value),
    )
    var item_owner = ArcPointer(False)
    var item_environment = allocate_callable_environment(
        ItemView(owner, item_owner), ItemView.destroy
    )
    var item = js_value_from_source_object(
        WeakReferenceIdentity(item_owner),
        "",
        Callable[Tuple[], Int](item_environment, ItemView.object_length),
        Callable[Tuple[Int], JsString](item_environment, ItemView.object_key),
        Callable[Tuple[Int], JsValue](item_environment, ItemView.object_value),
        RaisingCallable[Tuple[String], JsValue](
            item_environment, ItemView.shrink
        ),
    )
    owner[].values.append(item)
    owner[].values.append(JsValue(1.0))
    assert_equal(
        json_stringify_with_space_number(array, 2).value().to_native_strict(),
        "[\n  9,\n  null\n]",
    )
    assert_equal(array.array_length(), 0)
