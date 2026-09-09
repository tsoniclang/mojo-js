from std.collections import List
from std.memory import bitcast
from ..string import JsString
from .model import JsValue, _UNDEFINED, _NULL, _BOOL, _NUMBER, _STRING, _ARRAY, _OBJECT
from .builder import _JsValueBuilder
from .clone import js_value_structured_clone


comptime _BYTE_LIMIT = 16 * 1024 * 1024
comptime _NODE_LIMIT = 1048576
comptime _MAGIC = UInt32(0x3256474A)


struct _Writer:
    var bytes: List[UInt8]

    def __init__(out self):
        self.bytes = List[UInt8]()

    def integer(mut self, value: UInt64, width: Int) raises:
        if len(self.bytes) > _BYTE_LIMIT - width:
            raise Error("Structured clone transport exceeds its byte limit")
        for index in range(width):
            self.bytes.append(UInt8((value >> (index * 8)) & 255))

    def string(mut self, value: JsString) raises:
        self.integer(UInt64(len(value)), 4)
        for index in range(len(value)):
            self.integer(UInt64(value.code_unit_at(index).value()), 2)


struct _Reader:
    var bytes: List[UInt8]
    var offset: Int

    def __init__(out self, var bytes: List[UInt8]) raises:
        if len(bytes) > _BYTE_LIMIT:
            raise Error("Structured clone transport exceeds its byte limit")
        self.bytes = bytes^
        self.offset = 0

    def integer(mut self, width: Int) raises -> UInt64:
        if self.offset > len(self.bytes) - width:
            raise Error("Truncated structured clone transport")
        var result = UInt64(0)
        for index in range(width):
            result |= UInt64(self.bytes[self.offset + index]) << (index * 8)
        self.offset += width
        return result

    def string(mut self) raises -> JsString:
        var count = Int(self.integer(4))
        if count > (len(self.bytes) - self.offset) // 2:
            raise Error("Truncated structured clone string")
        var units = List[UInt16](capacity=count)
        for index in range(count):
            units.append(UInt16(self.integer(2)))
        return JsString(code_units=units^)


def encode_structured_clone(value: JsValue) raises -> List[UInt8]:
    var clone = js_value_structured_clone(value)
    var storage = clone._storage()
    var writer = _Writer()
    writer.integer(UInt64(_MAGIC), 4)
    writer.integer(UInt64(len(storage[])), 4)
    writer.integer(UInt64(clone._node_index()), 4)
    for node in storage[]:
        writer.integer(UInt64(node.kind), 1)
        if node.kind == _BOOL:
            writer.integer(UInt64(node.bool_value), 1)
        elif node.kind == _NUMBER:
            writer.integer(bitcast[.uint64](node.number_value), 8)
        elif node.kind == _STRING:
            writer.string(node.string_value)
        elif node.kind == _ARRAY or node.kind == _OBJECT:
            writer.integer(UInt64(len(node.children)), 4)
            for index in range(len(node.children)):
                if node.kind == _OBJECT:
                    writer.string(node.keys[index])
                writer.integer(UInt64(0xFFFFFFFF) if node.children[index] == -1 else UInt64(node.children[index]), 4)
        elif node.kind != _UNDEFINED and node.kind != _NULL:
            raise Error("Value has no structured clone transport representation")
    return writer.bytes^


def decode_structured_clone(var bytes: List[UInt8]) raises -> JsValue:
    var reader = _Reader(bytes^)
    if reader.integer(4) != UInt64(_MAGIC):
        raise Error("Structured clone transport version mismatch")
    var count = Int(reader.integer(4))
    var root = Int(reader.integer(4))
    if count == 0 or count > _NODE_LIMIT or root >= count or count > len(reader.bytes) - reader.offset:
        raise Error("Structured clone transport has an invalid node inventory")
    var builder = _JsValueBuilder()
    for index in range(count):
        var kind = Int(reader.integer(1))
        if kind == _UNDEFINED:
            _ = builder.append_undefined()
        elif kind == _NULL:
            _ = builder.append_null()
        elif kind == _BOOL:
            var value = reader.integer(1)
            if value > 1:
                raise Error("Structured clone transport has an invalid boolean")
            _ = builder.append_bool(value != 0)
        elif kind == _NUMBER:
            _ = builder.append_number(bitcast[.float64](reader.integer(8)))
        elif kind == _STRING:
            _ = builder.append_string(reader.string())
        elif kind == _ARRAY or kind == _OBJECT:
            var size = Int(reader.integer(4))
            if size > 4194304 or size > (len(reader.bytes) - reader.offset) // 4:
                raise Error("Structured clone transport has an invalid aggregate size")
            var children = List[Int](capacity=size)
            var keys = List[JsString](capacity=size if kind == _OBJECT else 0)
            for child_index in range(size):
                if kind == _OBJECT:
                    keys.append(reader.string())
                var child = Int(reader.integer(4))
                if kind == _ARRAY and child == 0xFFFFFFFF:
                    children.append(-1)
                    continue
                if child >= count:
                    raise Error("Structured clone transport has an invalid reference")
                children.append(child)
            if kind == _ARRAY:
                _ = builder.append_array(children^)
            else:
                _ = builder.append_object(keys^, children^)
        else:
            raise Error("Structured clone transport has an unknown value kind")
    if reader.offset != len(reader.bytes):
        raise Error("Structured clone transport contains trailing bytes")
    return builder.value(root)
