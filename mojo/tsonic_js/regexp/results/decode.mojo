from std.collections import List
from ...array import JsArray
from ...string import JsString
from ...value import JsValue
from .matches import (
    JsRegExpExecArray,
    JsRegExpMatchArray,
    JsRegExpStringIterator,
)
from .groups import (
    JsRegExpNamedGroups,
    JsRegExpNamedIndices,
    RegExpIndexPair,
    _JsNamedGroupEntry,
    _NamedIndexEntry,
    _optional_number,
    _optional_string,
)
from .indices import JsRegExpIndicesArray


def _parse_exact_match(value: JsValue) raises -> Optional[JsRegExpMatchArray]:
    if value.is_null():
        return None
    var values_value = _required_object_field(value, "values")
    var values = List[Optional[JsString]]()
    for index in range(values_value.array_length()):
        var item = values_value.array_at(index)
        values.append(
            None if item.is_null() else Optional[JsString](item.string_value())
        )
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
    var match_result = _parse_exact_match(value)
    return Optional[JsRegExpExecArray](
        JsRegExpExecArray(match_result.value())
    ) if match_result else None


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
                None if item.is_null() else Optional[JsString](
                    item.string_value()
                ),
            )
        )
    return Optional[JsRegExpNamedGroups](JsRegExpNamedGroups(entries^))


def _parse_named_indices(
    value: JsValue,
) raises -> Optional[JsRegExpNamedIndices]:
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
