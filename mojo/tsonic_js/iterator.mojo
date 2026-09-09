from std.builtin.rebind import downcast
from std.iter import Iterable, Iterator, StopIteration
from std.utils import Variant
from .iterator_result import JsIteratorReturn, JsIteratorYield
from .value import JsValue
from tsonic_runtime.callable import (
    Callable,
    ErasedCallableContext,
    allocate_callable_environment,
    destroy_callable_environment,
)


struct JsIterator[T: AnyType](Equatable, ImplicitlyCopyable, Iterable, Iterator):
    comptime Element = downcast[Self.T, Copyable & Deinitable]
    comptime IteratorType[
        iterable_mut: Bool, //, iterable_origin: Origin[mut=iterable_mut]
    ]: Iterator = Self

    var _read: Callable[Tuple[], Optional[Self.Element]]

    def __init__(
        out self, read: Callable[Tuple[], Optional[Self.Element]]
    ):
        self._read = read

    def __eq__(self, other: Self) -> Bool:
        return self._read.same(other._read)

    def __iter__(ref self) -> Self.IteratorType[origin_of(self)]:
        return self

    def __next__(mut self) raises StopIteration -> Self.Element:
        var value = self.next_optional()
        if not value:
            raise StopIteration()
        return value.value().copy()

    def next_optional(self) -> Optional[Self.Element]:
        return self._read.call(())

    def iter_values(self) -> Self:
        return self

    def next(self) -> Variant[JsIteratorYield[Self.T], JsIteratorReturn[JsValue]]:
        var value = self.next_optional()
        if value:
            return Variant[JsIteratorYield[Self.T], JsIteratorReturn[JsValue]](
                JsIteratorYield[Self.T](value.value().copy())
            )
        return Variant[JsIteratorYield[Self.T], JsIteratorReturn[JsValue]](
            JsIteratorReturn[JsValue](JsValue())
        )

    def next(self, value: JsValue) -> Variant[JsIteratorYield[Self.T], JsIteratorReturn[JsValue]]:
        return self.next()


@fieldwise_init
struct _IteratorEnvironment[
    T: Copyable & Deinitable,
    State: Movable & Deinitable,
    read: def(mut State) thin -> Optional[T],
]:
    var source: Self.State
    var exhausted: Bool

    @staticmethod
    def invoke(
        context: ErasedCallableContext, var arguments: Tuple[]
    ) -> Optional[Self.T]:
        var pointer = context.unsafe_bitcast[Self]()
        if pointer[].exhausted:
            return None
        var result = Self.read(pointer[].source)
        if not result:
            pointer[].exhausted = True
        return result^

    @staticmethod
    def destroy(context: ErasedCallableContext):
        destroy_callable_environment[Self](context)


def make_iterator[
    T: Copyable & Deinitable,
    State: Movable & Deinitable,
    read: def(mut State) thin -> Optional[T],
](var state: State) -> JsIterator[T]:
    comptime Environment = _IteratorEnvironment[T, State, read]
    var environment = allocate_callable_environment(
        Environment(state^, False), Environment.destroy
    )
    return JsIterator[T](
        Callable[Tuple[], Optional[T]](environment, Environment.invoke)
    )
