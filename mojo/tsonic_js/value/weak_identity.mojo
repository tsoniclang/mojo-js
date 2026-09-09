from tsonic_runtime import WeakReferenceIdentity
from .model import JsValue


struct JsValueWeakIdentity(ImplicitlyCopyable):
    var _kind: Int
    var _identity: Optional[WeakReferenceIdentity]

    def __init__(out self, value: JsValue):
        self._kind = value._kind()
        self._identity = None
        if value.is_array() or value.is_object() or value.is_json_projection():
            self._identity = Optional[WeakReferenceIdentity](value.weak_identity())

    def is_alive(self) -> Bool:
        return Bool(self._identity) and self._identity.value().is_alive()

    def matches(self, value: JsValue) -> Bool:
        return self.is_alive() and value._kind() == self._kind and self._identity.value().address == value._identity_address()
