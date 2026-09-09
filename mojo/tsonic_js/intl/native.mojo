from std.collections import List
from std.ffi import c_int, c_size_t, external_call


struct IntlResult(Movable):
    var pointer: OptionalPointer[NoneType, MutUntrackedOrigin]

    def __init__(out self, pointer: OptionalPointer[NoneType, MutUntrackedOrigin]):
        self.pointer = pointer

    def __del__(deinit self):
        if self.pointer:
            external_call["tsonic_js_intl_free", NoneType](self.pointer.value())

    def check(self) raises:
        if not self.pointer:
            raise Error("Unable to allocate internationalization result")
        if external_call["tsonic_js_intl_failed", c_int](self.pointer.value()):
            var message = external_call[
                "tsonic_js_intl_error", Pointer[UInt8, ImmUntrackedOrigin],
            ](self.pointer.value())
            raise Error(String(unsafe_from_utf8_ptr=message))

    def text(self) raises -> String:
        self.check()
        var text = external_call[
            "tsonic_js_intl_text", OptionalPointer[UInt8, ImmUntrackedOrigin],
        ](self.pointer.value())
        if not text:
            raise Error("Internationalization result has no text")
        return String(unsafe_from_utf8_ptr=text.value())

    def units(self) raises -> List[UInt16]:
        self.check()
        var length = Int(external_call["tsonic_js_intl_length", c_size_t](self.pointer.value()))
        var source = external_call[
            "tsonic_js_intl_units", OptionalPointer[UInt16, ImmUntrackedOrigin],
        ](self.pointer.value())
        var result = List[UInt16](capacity=length)
        if length != 0 and not source:
            raise Error("Internationalization result has no code-unit storage")
        for index in range(length):
            result.append(source.value()[index])
        return result^

    def order(self) raises -> Float64:
        self.check()
        return Float64(external_call["tsonic_js_intl_order", c_int](self.pointer.value()))
