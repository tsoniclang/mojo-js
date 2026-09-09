from std.memory.arc_pointer import WeakPointer
from .model import JsValue, _JsonProjectionState


struct JsValueWeakIdentity(ImplicitlyCopyable):
    var _kind: Int
    var _aggregate: WeakPointer[Bool]
    var _projection: WeakPointer[_JsonProjectionState]

    def __init__(out self, value: JsValue):
        self._kind = value._kind()
        self._aggregate = WeakPointer[Bool]()
        self._projection = WeakPointer[_JsonProjectionState]()
        var node = value._storage()
        var index = value._node_index()
        if value.is_array() or value.is_object():
            if node[][index].identity:
                self._aggregate = WeakPointer[Bool](downgrade=node[][index].identity.value())
        elif value.is_json_projection():
            if node[][index].json_projection:
                self._projection = WeakPointer[_JsonProjectionState](downgrade=node[][index].json_projection.value())

    def is_alive(self) -> Bool:
        return self._aggregate.strong_count() != 0 or self._projection.strong_count() != 0

    def matches(self, value: JsValue) -> Bool:
        if value._kind() != self._kind:
            return False
        var nodes = value._storage()
        var index = value._node_index()
        if value.is_array() or value.is_object():
            var retained = self._aggregate.try_upgrade()
            var identity = nodes[][index].identity
            return Bool(retained) and Bool(identity) and retained.value() is identity.value()
        if value.is_json_projection():
            var retained = self._projection.try_upgrade()
            var identity = nodes[][index].json_projection
            return Bool(retained) and Bool(identity) and retained.value() is identity.value()
        return False
