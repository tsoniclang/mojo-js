from .value import JsValue
from std.collections import List
from std.io import FileDescriptor
from std.memory import bitcast
from std.sys import stderr, stdout
from tsonic_runtime.number_string import source_number_to_string


def _console_write_value(value: JsValue, output: FileDescriptor):
    if value.is_undefined():
        print("undefined", end="", file=output)
    elif value.is_null():
        print("null", end="", file=output)
    elif value.is_bool():
        print("true" if value._bool_value() else "false", end="", file=output)
    elif value.is_number():
        var number = value._number_value()
        var text = "-0" if number == 0 and bitcast[.uint64](
            number
        ) != 0 else source_number_to_string(number)
        print(text, end="", file=output)
    elif value.is_string():
        print(value._string_value(), end="", file=output)
    elif value.is_array():
        print("[Array]", end="", file=output)
    else:
        print("[object Object]", end="", file=output)


def _console_write(data: List[JsValue], output: FileDescriptor):
    for index in range(len(data)):
        if index != 0:
            print(" ", end="", file=output)
        _console_write_value(data[index], output)
    print(file=output)


def console_debug(data: List[JsValue]):
    _console_write(data, stdout)


def console_error(data: List[JsValue]):
    _console_write(data, stderr)


def console_info(data: List[JsValue]):
    _console_write(data, stdout)


def console_log(data: List[JsValue]):
    _console_write(data, stdout)


def console_warn(data: List[JsValue]):
    _console_write(data, stderr)
