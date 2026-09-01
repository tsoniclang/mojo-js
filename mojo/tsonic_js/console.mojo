from tsonic_runtime import Null, Undefined

from .string import JsString
from .value import JsValue


def _console_write_value(value: JsValue):
    if value.isa[Undefined]():
        print("undefined", end="")
    elif value.isa[Null]():
        print("null", end="")
    elif value.isa[Bool]():
        print("true" if value[Bool] else "false", end="")
    elif value.isa[Float64]():
        print(value[Float64], end="")
    else:
        print(value[JsString], end="")


def _console_write(label: String, *data: JsValue):
    if label:
        print(label, end="")
    for index in range(len(data)):
        if index != 0:
            print(" ", end="")
        _console_write_value(data[index])
    print()


def console_debug(*data: JsValue):
    _console_write("", *data)


def console_error(*data: JsValue):
    _console_write("", *data)


def console_info(*data: JsValue):
    _console_write("", *data)


def console_log(*data: JsValue):
    _console_write("", *data)


def console_warn(*data: JsValue):
    _console_write("", *data)
