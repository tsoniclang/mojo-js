from std.collections import List
from ...array import JsArray
from ...string import JsString
from .groups import JsRegExpNamedGroups, RegExpNamedGroups
from .indices import JsRegExpIndicesArray, RegExpIndicesArray


struct JsRegExpMatchArray(ImplicitlyCopyable, Sized):
    var _values: JsArray[Optional[JsString]]
    var _index: Optional[Float64]
    var _input: Optional[JsString]
    var _groups: Optional[JsRegExpNamedGroups]
    var _indices: Optional[JsRegExpIndicesArray]

    def __init__(
        out self,
        values: JsArray[Optional[JsString]],
        index: Optional[Float64],
        input: Optional[JsString],
        groups: Optional[JsRegExpNamedGroups],
        indices: Optional[JsRegExpIndicesArray],
    ):
        self._values = values
        self._index = index
        self._input = input
        self._groups = groups
        self._indices = indices

    def __len__(self) -> Int:
        return len(self._values)

    def js_length(self) -> Float64:
        return Float64(len(self))

    def get_index(self, index: Float64) -> Optional[JsString]:
        var value = self._values.get_index(index)
        return value.value().copy() if value else None

    def set_index(mut self, index: Float64, value: Optional[JsString]):
        self._values.set(Int(index), value)

    def first(self) -> JsString:
        return self.get_index(0).value()

    def index(self) -> Optional[Float64]:
        return self._index

    def input(self) -> Optional[JsString]:
        return self._input

    def groups(self) -> Optional[JsRegExpNamedGroups]:
        return self._groups

    def indices(self) -> Optional[JsRegExpIndicesArray]:
        return self._indices

    def iter_values(self) -> List[Optional[JsString]]:
        var result = List[Optional[JsString]]()
        for index in range(len(self)):
            result.append(self.get_index(Float64(index)))
        return result^

    def _native(self) raises -> RegExpMatchArray:
        var values = List[Optional[String]]()
        for value in self.iter_values():
            values.append(
                Optional[String](
                    value.value().to_native_strict()
                ) if value else None
            )
        return RegExpMatchArray(
            JsArray[Optional[String]](values^),
            self._index,
            Optional[String](
                self._input.value().to_native_strict()
            ) if self._input else None,
            Optional[RegExpNamedGroups](
                self._groups.value()._native()
            ) if self._groups else None,
            Optional[RegExpIndicesArray](
                self._indices.value()._native()
            ) if self._indices else None,
        )


struct JsRegExpExecArray(ImplicitlyCopyable, Sized):
    var _match: JsRegExpMatchArray

    def __init__(out self, match_result: JsRegExpMatchArray):
        self._match = match_result

    def __len__(self) -> Int:
        return len(self._match)

    def js_length(self) -> Float64:
        return Float64(len(self))

    def get_index(self, index: Float64) -> Optional[JsString]:
        return self._match.get_index(index)

    def set_index(mut self, index: Float64, value: Optional[JsString]):
        self._match.set_index(index, value)

    def first(self) -> JsString:
        return self._match.first()

    def index(self) -> Float64:
        return self._match.index().value()

    def input(self) -> JsString:
        return self._match.input().value()

    def groups(self) -> Optional[JsRegExpNamedGroups]:
        return self._match.groups()

    def indices(self) -> Optional[JsRegExpIndicesArray]:
        return self._match.indices()

    def iter_values(self) -> List[Optional[JsString]]:
        return self._match.iter_values()

    def _native(self) raises -> RegExpExecArray:
        return RegExpExecArray(self._match._native())


struct RegExpMatchArray(ImplicitlyCopyable, Sized):
    var _values: JsArray[Optional[String]]
    var _index: Optional[Float64]
    var _input: Optional[String]
    var _groups: Optional[RegExpNamedGroups]
    var _indices: Optional[RegExpIndicesArray]

    def __init__(
        out self,
        values: JsArray[Optional[String]],
        index: Optional[Float64],
        input: Optional[String],
        groups: Optional[RegExpNamedGroups],
        indices: Optional[RegExpIndicesArray],
    ):
        self._values = values
        self._index = index
        self._input = input
        self._groups = groups
        self._indices = indices

    def __len__(self) -> Int:
        return len(self._values)

    def js_length(self) -> Float64:
        return Float64(len(self))

    def get_index(self, index: Float64) -> Optional[String]:
        var value = self._values.get_index(index)
        return value.value().copy() if value else None

    def set_index(mut self, index: Float64, value: Optional[String]):
        self._values.set(Int(index), value)

    def first(self) -> String:
        return self.get_index(0).value()

    def index(self) -> Optional[Float64]:
        return self._index

    def input(self) -> Optional[String]:
        return self._input

    def groups(self) -> Optional[RegExpNamedGroups]:
        return self._groups

    def indices(self) -> Optional[RegExpIndicesArray]:
        return self._indices

    def iter_values(self) -> List[Optional[String]]:
        var result = List[Optional[String]]()
        for index in range(len(self)):
            result.append(self.get_index(Float64(index)))
        return result^


struct RegExpExecArray(ImplicitlyCopyable, Sized):
    var _match: RegExpMatchArray

    def __init__(out self, match_result: RegExpMatchArray):
        self._match = match_result

    def __len__(self) -> Int:
        return len(self._match)

    def js_length(self) -> Float64:
        return Float64(len(self))

    def get_index(self, index: Float64) -> Optional[String]:
        return self._match.get_index(index)

    def set_index(mut self, index: Float64, value: Optional[String]):
        self._match.set_index(index, value)

    def first(self) -> String:
        return self._match.first()

    def index(self) -> Float64:
        return self._match.index().value()

    def input(self) -> String:
        return self._match.input().value()

    def groups(self) -> Optional[RegExpNamedGroups]:
        return self._match.groups()

    def indices(self) -> Optional[RegExpIndicesArray]:
        return self._match.indices()

    def iter_values(self) -> List[Optional[String]]:
        return self._match.iter_values()


struct JsRegExpStringIterator(ImplicitlyCopyable):
    var _values: JsArray[JsRegExpExecArray]

    def __init__(out self, values: JsArray[JsRegExpExecArray]):
        self._values = values

    def iter_values(self) -> List[JsRegExpExecArray]:
        var result = List[JsRegExpExecArray]()
        for value in self._values._elements[]:
            result.append(value.value())
        return result^


struct RegExpStringIterator(ImplicitlyCopyable):
    var _values: JsArray[RegExpExecArray]

    def __init__(out self, values: JsArray[RegExpExecArray]):
        self._values = values

    def iter_values(self) -> List[RegExpExecArray]:
        var result = List[RegExpExecArray]()
        for value in self._values._elements[]:
            result.append(value.value())
        return result^
