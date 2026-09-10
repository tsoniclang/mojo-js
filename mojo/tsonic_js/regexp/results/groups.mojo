from ...string import JsString
from std.collections import List
from std.memory import ArcPointer
from ...value import JsValue


comptime RegExpIndexPair = Tuple[Float64, Float64]


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
                    Optional[String](
                        entry.value.value().to_native_strict()
                    ) if entry.value else None,
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


def _optional_number(value: JsValue) raises -> Optional[Float64]:
    return None if value.is_null() else Optional[Float64](value.number_value())


def _optional_string(value: JsValue) raises -> Optional[JsString]:
    return None if value.is_null() else Optional[JsString](value.string_value())
