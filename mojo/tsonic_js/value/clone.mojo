from std.collections import Dict, List
from ..string import JsString
from .model import JsValue
from .builder import _JsValueBuilder


@fieldwise_init
struct _PendingClone(Copyable):
    var source: JsValue
    var target: Int
    var length: Int


struct _Clone:
    var builder: _JsValueBuilder
    var identities: Dict[UInt, Int]
    var nodes: Dict[Tuple[UInt, Int], Int]
    var retained: List[JsValue]
    var pending: List[_PendingClone]

    def __init__(out self):
        self.builder = _JsValueBuilder()
        self.identities = Dict[UInt, Int]()
        self.nodes = Dict[Tuple[UInt, Int], Int]()
        self.retained = List[JsValue]()
        self.pending = List[_PendingClone]()

    def reserve(mut self, value: JsValue) raises -> Int:
        if len(value._nodes[]) > 1048576 or value._index < 0 or value._index >= len(value._nodes[]):
            raise Error("JavaScript value graph contains an invalid node reference")
        var key = (UInt(Int(value._nodes.ptr())), value._index)
        if key in self.nodes:
            return self.nodes[key]
        var target = 0
        if value.is_undefined():
            target = self.builder.append_undefined()
        elif value.is_null():
            target = self.builder.append_null()
        elif value.is_bool():
            target = self.builder.append_bool(value._bool_value())
        elif value.is_number():
            target = self.builder.append_number(value._number_value())
        elif value.is_string():
            target = self.builder.append_string(value._string_value())
        elif value.is_symbol() or value.is_json_projection():
            raise Error("JavaScript symbols and executable projections cannot be structured-cloned")
        elif value.is_array() or value.is_object():
            if not value._nodes[][value._index].source_view and not value._nodes[][value._index].identity:
                raise Error("JavaScript aggregate has no allocation identity")
            var identity = value._identity_address()
            if identity in self.identities:
                target = self.identities[identity]
                if self.builder.value(target)._kind() != value._kind():
                    raise Error("One source allocation has conflicting aggregate kinds")
                return target
            if not value._nodes[][value._index].source_view and value.is_object() and (
                len(value._nodes[][value._index].keys) != len(value._nodes[][value._index].children)
            ):
                raise Error("JavaScript object keys and values have different lengths")
            var length = value.array_length() if value.is_array() else value.object_length()
            if length < 0 or length > 4194304:
                raise Error("JavaScript value graph exceeds its edge budget")
            if value.is_array():
                target = self.builder.append_array(List[Int]())
            else:
                var keys = List[JsString](capacity=length)
                for index in range(length):
                    keys.append(value.object_key(index))
                target = self.builder.append_object(keys^, List[Int]())
            self.identities[identity] = target
            self.pending.append(_PendingClone(value, target, length))
        else:
            raise Error("JavaScript value has no closed data clone contract")
        self.nodes[key] = target
        self.retained.append(value)
        return target

    def finish(mut self, value: JsValue) raises -> JsValue:
        var root = self.reserve(value)
        var cursor = 0
        var edges = 0
        while cursor < len(self.pending):
            var record = self.pending[cursor].copy()
            cursor += 1
            if record.length > 4194304 - edges:
                raise Error("JavaScript value graph exceeds its edge budget")
            edges += record.length
            var children = List[Int](capacity=record.length)
            for index in range(record.length):
                if record.source.is_array() and not record.source.array_has(index):
                    children.append(-1)
                    continue
                var child = record.source.array_at(index) if record.source.is_array() else record.source.object_value(index)
                children.append(self.reserve(child))
            self.builder.set_aggregate_children(record.target, children^)
        return self.builder.value(root)


def js_value_structured_clone(value: JsValue) raises -> JsValue:
    var clone = _Clone()
    return clone.finish(value)
