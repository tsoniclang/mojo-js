from std.memory import bitcast
from std.pathlib import Path
from std.sys import argv
from tsonic_js import JsArray, array_join_native


def main() raises:
    var arguments = argv()
    if len(arguments) != 2:
        raise Error("Expected the exact input-bit-pattern file")
    var source = Path(arguments[1]).read_text()
    for line in source.splitlines():
        var text = String(line)
        if text.byte_length() != 16:
            raise Error("Expected a 16-digit binary64 hexadecimal word")
        var bits = UInt64(0)
        for byte in text.as_bytes():
            var digit = UInt64(byte - Byte(48))
            if byte >= Byte(97) and byte <= Byte(102):
                digit = UInt64(byte - Byte(87))
            elif byte < Byte(48) or byte > Byte(57):
                raise Error("Invalid hexadecimal digit")
            bits = (bits << 4) | digit
        print(array_join_native(JsArray[Float64]([bitcast[DType.float64](bits)])))
