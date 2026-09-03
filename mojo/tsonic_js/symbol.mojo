from std.memory import ArcPointer

from .string import JsString


@fieldwise_init
struct _JsSymbolState:
    var description: Optional[JsString]


struct JsSymbol(ImplicitlyCopyable, Writable):
    var _state: ArcPointer[_JsSymbolState]

    def __init__(out self):
        self._state = ArcPointer(_JsSymbolState(None))

    def __init__(out self, description: JsString):
        self._state = ArcPointer(
            _JsSymbolState(Optional[JsString](description))
        )

    def same(self, other: Self) -> Bool:
        return self._state is other._state

    def description(self) -> Optional[JsString]:
        return self._state[].description.copy()

    def write_to(self, mut writer: Some[Writer]):
        writer.write("Symbol(")
        if self._state[].description:
            writer.write(self._state[].description.value())
        writer.write(")")


def symbol_new() -> JsSymbol:
    return JsSymbol()


def symbol_new(description: JsString) -> JsSymbol:
    return JsSymbol(description)
