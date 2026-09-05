from std.sys import argv

from tsonic_js import regexp_construct


def main() raises:
    var arguments = argv()
    if len(arguments) != 4:
        raise Error("Expected RegExp pattern, flags, and input")
    var expression = regexp_construct(
        String(arguments[1]), String(arguments[2])
    )
    var input = String(arguments[3])
    print("true" if expression.test_native(input) else "false")
    print(Int(expression.last_index()))
    print("true" if expression.test_native(input) else "false")
    print(Int(expression.last_index()))
    expression.set_last_index(0)
    print(Int(expression.search_native(input)))
    print(Int(expression.last_index()))
