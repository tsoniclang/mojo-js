from std.collections import List
from ...array import JsArray
from .groups import JsRegExpNamedIndices, RegExpIndexPair, RegExpNamedIndices


struct JsRegExpIndicesArray(ImplicitlyCopyable, Sized):
    var _values: JsArray[Optional[RegExpIndexPair]]
    var _groups: Optional[JsRegExpNamedIndices]

    def __init__(
        out self,
        values: JsArray[Optional[RegExpIndexPair]],
        groups: Optional[JsRegExpNamedIndices],
    ):
        self._values = values
        self._groups = groups

    def __len__(self) -> Int:
        return len(self._values)

    def js_length(self) -> Float64:
        return Float64(len(self))

    def get_index(self, index: Float64) -> Optional[RegExpIndexPair]:
        var value = self._values.get_index(index)
        return value.value().copy() if value else None

    def set_index(mut self, index: Float64, value: Optional[RegExpIndexPair]):
        self._values.set(Int(index), value)

    def groups(self) -> Optional[JsRegExpNamedIndices]:
        return self._groups

    def iter_values(self) -> List[Optional[RegExpIndexPair]]:
        var result = List[Optional[RegExpIndexPair]]()
        for index in range(len(self)):
            result.append(self.get_index(Float64(index)))
        return result^

    def _native(self) raises -> RegExpIndicesArray:
        return RegExpIndicesArray(
            self._values,
            Optional[RegExpNamedIndices](
                self._groups.value()._native()
            ) if self._groups else None,
        )


struct RegExpIndicesArray(ImplicitlyCopyable, Sized):
    var _values: JsArray[Optional[RegExpIndexPair]]
    var _groups: Optional[RegExpNamedIndices]

    def __init__(
        out self,
        values: JsArray[Optional[RegExpIndexPair]],
        groups: Optional[RegExpNamedIndices],
    ):
        self._values = values
        self._groups = groups

    def __len__(self) -> Int:
        return len(self._values)

    def js_length(self) -> Float64:
        return Float64(len(self))

    def get_index(self, index: Float64) -> Optional[RegExpIndexPair]:
        var value = self._values.get_index(index)
        return value.value().copy() if value else None

    def set_index(mut self, index: Float64, value: Optional[RegExpIndexPair]):
        self._values.set(Int(index), value)

    def groups(self) -> Optional[RegExpNamedIndices]:
        return self._groups

    def iter_values(self) -> List[Optional[RegExpIndexPair]]:
        var result = List[Optional[RegExpIndexPair]]()
        for index in range(len(self)):
            result.append(self.get_index(Float64(index)))
        return result^
