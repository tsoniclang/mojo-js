from std.collections import List
from std.memory import ArcPointer

from .array import JsArray
from .string import JsString
from .value import JsValue


alias RegExpIndexPair = Tuple[Float64, Float64]


@fieldwise_init
struct _JsNamedGroupEntry(Copyable):
    var name: JsString
    var value: Optional[JsString]


struct JsRegExpNamedGroups(ImplicitlyCopyable):
    var _entries: ArcPointer[List[_JsNamedGroupEntry]]

    def __init__(out self):
        self._entries = ArcPointer(List[_JsNamedGroupEntry]())

    def __init__(out self, var entries: List[_JsNamedGroupEntry]):
        self._entries = ArcPointer(entries^)

    def get(self, name: JsString) -> Optional[JsString]:
        for entry in self._entries[]:
            if entry.name == name:
                return entry.value.copy()
        return None

    def get(self, name: String) -> Optional[JsString]:
        return self.get(JsString(name))

    def set(mut self, name: JsString, value: Optional[JsString]):
        for index in range(len(self._entries[])):
            if self._entries[][index].name == name:
                self._entries[][index].value = value
                return
        self._entries[].append(_JsNamedGroupEntry(name, value))

    def set(mut self, name: String, value: Optional[JsString]):
        self.set(JsString(name), value)

    def delete(mut self, name: JsString) -> Bool:
        var next = List[_JsNamedGroupEntry]()
        var removed = False
        for entry in self._entries[]:
            if entry.name == name:
                removed = True
            else:
                next.append(entry.copy())
        self._entries[] = next^
        return removed

    def _native(self) raises -> RegExpNamedGroups:
        var entries = List[_NativeNamedGroupEntry]()
        for entry in self._entries[]:
            entries.append(
                _NativeNamedGroupEntry(
                    entry.name.to_native_strict(),
                    Optional[String](entry.value.value().to_native_strict())
                    if entry.value
                    else None,
                )
            )
        return RegExpNamedGroups(entries^)


@fieldwise_init
struct _NativeNamedGroupEntry(Copyable):
    var name: String
    var value: Optional[String]


struct RegExpNamedGroups(ImplicitlyCopyable):
    var _entries: ArcPointer[List[_NativeNamedGroupEntry]]

    def __init__(out self):
        self._entries = ArcPointer(List[_NativeNamedGroupEntry]())

    def __init__(out self, var entries: List[_NativeNamedGroupEntry]):
        self._entries = ArcPointer(entries^)

    def get(self, name: String) -> Optional[String]:
        for entry in self._entries[]:
            if entry.name == name:
                return entry.value.copy()
        return None

    def set(mut self, name: String, value: Optional[String]):
        for index in range(len(self._entries[])):
            if self._entries[][index].name == name:
                self._entries[][index].value = value
                return
        self._entries[].append(_NativeNamedGroupEntry(name, value))

    def delete(mut self, name: String) -> Bool:
        var next = List[_NativeNamedGroupEntry]()
        var removed = False
        for entry in self._entries[]:
            if entry.name == name:
                removed = True
            else:
                next.append(entry.copy())
        self._entries[] = next^
        return removed


@fieldwise_init
struct _NamedIndexEntry(Copyable):
    var name: JsString
    var value: Optional[RegExpIndexPair]


struct JsRegExpNamedIndices(ImplicitlyCopyable):
    var _entries: ArcPointer[List[_NamedIndexEntry]]

    def __init__(out self):
        self._entries = ArcPointer(List[_NamedIndexEntry]())

    def __init__(out self, var entries: List[_NamedIndexEntry]):
        self._entries = ArcPointer(entries^)

    def get(self, name: JsString) -> Optional[RegExpIndexPair]:
        for entry in self._entries[]:
            if entry.name == name:
                return entry.value.copy()
        return None

    def get(self, name: String) -> Optional[RegExpIndexPair]:
        return self.get(JsString(name))

    def set(mut self, name: JsString, value: Optional[RegExpIndexPair]):
        for index in range(len(self._entries[])):
            if self._entries[][index].name == name:
                self._entries[][index].value = value
                return
        self._entries[].append(_NamedIndexEntry(name, value))

    def set(mut self, name: String, value: Optional[RegExpIndexPair]):
        self.set(JsString(name), value)

    def delete(mut self, name: JsString) -> Bool:
        var next = List[_NamedIndexEntry]()
        var removed = False
        for entry in self._entries[]:
            if entry.name == name:
                removed = True
            else:
                next.append(entry.copy())
        self._entries[] = next^
        return removed

    def _native(self) raises -> RegExpNamedIndices:
        var entries = List[_NativeNamedIndexEntry]()
        for entry in self._entries[]:
            entries.append(
                _NativeNamedIndexEntry(
                    entry.name.to_native_strict(), entry.value
                )
            )
        return RegExpNamedIndices(entries^)


@fieldwise_init
struct _NativeNamedIndexEntry(Copyable):
    var name: String
    var value: Optional[RegExpIndexPair]


struct RegExpNamedIndices(ImplicitlyCopyable):
    var _entries: ArcPointer[List[_NativeNamedIndexEntry]]

    def __init__(out self):
        self._entries = ArcPointer(List[_NativeNamedIndexEntry]())

    def __init__(out self, var entries: List[_NativeNamedIndexEntry]):
        self._entries = ArcPointer(entries^)

    def get(self, name: String) -> Optional[RegExpIndexPair]:
        for entry in self._entries[]:
            if entry.name == name:
                return entry.value.copy()
        return None

    def set(mut self, name: String, value: Optional[RegExpIndexPair]):
        for index in range(len(self._entries[])):
            if self._entries[][index].name == name:
                self._entries[][index].value = value
                return
        self._entries[].append(_NativeNamedIndexEntry(name, value))

    def delete(mut self, name: String) -> Bool:
        var next = List[_NativeNamedIndexEntry]()
        var removed = False
        for entry in self._entries[]:
            if entry.name == name:
                removed = True
            else:
                next.append(entry.copy())
        self._entries[] = next^
        return removed


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
        return self._values.iter_values()

    def _native(self) raises -> RegExpIndicesArray:
        return RegExpIndicesArray(
            self._values,
            Optional[RegExpNamedIndices](self._groups.value()._native())
            if self._groups
            else None,
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
        return self._values.iter_values()


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
        return self._values.iter_values()

    def _native(self) raises -> RegExpMatchArray:
        var values = List[Optional[String]]()
        for value in self._values.values():
            values.append(
                Optional[String](value.value().to_native_strict())
                if value
                else None
            )
        return RegExpMatchArray(
            JsArray[Optional[String]](values^),
            self._index,
            Optional[String](self._input.value().to_native_strict())
            if self._input
            else None,
            Optional[RegExpNamedGroups](self._groups.value()._native())
            if self._groups
            else None,
            Optional[RegExpIndicesArray](self._indices.value()._native())
            if self._indices
            else None,
        )


struct JsRegExpExecArray(ImplicitlyCopyable, Sized):
    var _match: JsRegExpMatchArray

    def __init__(out self, match: JsRegExpMatchArray):
        self._match = match

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
        return self._values.iter_values()


struct RegExpExecArray(ImplicitlyCopyable, Sized):
    var _match: RegExpMatchArray

    def __init__(out self, match: RegExpMatchArray):
        self._match = match

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
        return self._values.iter_values()


struct RegExpStringIterator(ImplicitlyCopyable):
    var _values: JsArray[RegExpExecArray]

    def __init__(out self, values: JsArray[RegExpExecArray]):
        self._values = values

    def iter_values(self) -> List[RegExpExecArray]:
        return self._values.iter_values()


def _parse_exact_match(value: JsValue) raises -> Optional[JsRegExpMatchArray]:
    if value.is_null():
        return None
    var values_value = _required_object_field(value, "values")
    var values = List[Optional[JsString]]()
    for index in range(values_value.array_length()):
        var item = values_value.array_at(index)
        values.append(None if item.is_null() else Optional[JsString](item.string_value()))
    var index_value = _optional_number(_required_object_field(value, "index"))
    var input = _optional_string(_required_object_field(value, "input"))
    var groups = _parse_groups(_required_object_field(value, "groups"))
    var indices = _parse_indices(_required_object_field(value, "indices"))
    return Optional[JsRegExpMatchArray](
        JsRegExpMatchArray(
            JsArray[Optional[JsString]](values^),
            index_value,
            input,
            groups,
            indices,
        )
    )


def _parse_exact_exec(value: JsValue) raises -> Optional[JsRegExpExecArray]:
    var match = _parse_exact_match(value)
    return (
        Optional[JsRegExpExecArray](JsRegExpExecArray(match.value()))
        if match
        else None
    )


def _parse_exact_match_all(value: JsValue) raises -> JsRegExpStringIterator:
    var matches = List[JsRegExpExecArray]()
    for index in range(value.array_length()):
        matches.append(_parse_exact_exec(value.array_at(index)).value())
    return JsRegExpStringIterator(JsArray[JsRegExpExecArray](matches^))


def _parse_groups(value: JsValue) raises -> Optional[JsRegExpNamedGroups]:
    if value.is_null():
        return None
    var entries = List[_JsNamedGroupEntry]()
    for index in range(value.object_length()):
        var item = value.object_value(index)
        entries.append(
            _JsNamedGroupEntry(
                value.object_key(index),
                None if item.is_null() else Optional[JsString](item.string_value()),
            )
        )
    return Optional[JsRegExpNamedGroups](JsRegExpNamedGroups(entries^))


def _parse_named_indices(value: JsValue) raises -> Optional[JsRegExpNamedIndices]:
    if value.is_null():
        return None
    var entries = List[_NamedIndexEntry]()
    for index in range(value.object_length()):
        entries.append(
            _NamedIndexEntry(
                value.object_key(index),
                _parse_index_pair(value.object_value(index)),
            )
        )
    return Optional[JsRegExpNamedIndices](JsRegExpNamedIndices(entries^))


def _parse_indices(value: JsValue) raises -> Optional[JsRegExpIndicesArray]:
    if value.is_null():
        return None
    var values_value = _required_object_field(value, "values")
    var values = List[Optional[RegExpIndexPair]]()
    for index in range(values_value.array_length()):
        values.append(_parse_index_pair(values_value.array_at(index)))
    return Optional[JsRegExpIndicesArray](
        JsRegExpIndicesArray(
            JsArray[Optional[RegExpIndexPair]](values^),
            _parse_named_indices(_required_object_field(value, "groups")),
        )
    )


def _parse_index_pair(value: JsValue) raises -> Optional[RegExpIndexPair]:
    if value.is_null():
        return None
    if value.array_length() != 2:
        raise Error("JavaScript RegExp index pair has invalid arity")
    return Optional[RegExpIndexPair](
        (
            value.array_at(0).number_value(),
            value.array_at(1).number_value(),
        )
    )


def _required_object_field(value: JsValue, name: String) raises -> JsValue:
    var field = value.object_get(JsString(name))
    if not field:
        raise Error("JavaScript RegExp result is missing field " + name)
    return field.value()


def _optional_number(value: JsValue) raises -> Optional[Float64]:
    return None if value.is_null() else Optional[Float64](value.number_value())


def _optional_string(value: JsValue) raises -> Optional[JsString]:
    return None if value.is_null() else Optional[JsString](value.string_value())
