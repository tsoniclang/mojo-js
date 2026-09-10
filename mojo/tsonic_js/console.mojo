from .value import JsValue
from .inspection import inspect_value
from std.collections import List
from std.io import FileDescriptor
from std.sys import stderr, stdout


def _console_write_value(value: JsValue, output: FileDescriptor):
    if value.is_string():
        print(value._string_value(), end="", file=output)
    else:
        print(inspect_value(value), end="", file=output)


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
