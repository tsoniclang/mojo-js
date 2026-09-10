from std.collections import List
from std.memory import ArcPointer
from tsonic_runtime import WeakReferenceIdentity


@fieldwise_init
struct JsByteView(ImplicitlyCopyable):
    var storage: ArcPointer[List[UInt8]]
    var offset: Int
    var length: Int
    var identity: ArcPointer[Bool]

    def validate(self) raises:
        if self.offset < 0 or self.length < 0 or self.offset > len(self.storage[]) - self.length:
            raise Error("JavaScript byte view is outside its backing storage")

    def get(self, index: Int) raises -> UInt8:
        self.validate()
        if index < 0 or index >= self.length:
            raise Error("JavaScript byte view index is out of range")
        return self.storage[][self.offset + index]

    def set(self, index: Int, value: UInt8) raises:
        self.validate()
        if index < 0 or index >= self.length:
            raise Error("JavaScript byte view index is out of range")
        self.storage[][self.offset + index] = value

    def storage_identity(self) -> UInt:
        return UInt(Int(self.storage.ptr()))

    def weak_identity(self) -> WeakReferenceIdentity:
        return WeakReferenceIdentity(self.identity)
