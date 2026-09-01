from .value import JsValue


def _console_write_value(value: JsValue):
    if value.is_undefined():
        print("undefined", end="")
    elif value.is_null():
        print("null", end="")
    elif value.is_bool():
        print("true" if value._bool_value() else "false", end="")
    elif value.is_number():
        print(value._number_value(), end="")
    elif value.is_string():
        print(value._string_value(), end="")
    elif value.is_array():
        print("[Array]", end="")
    else:
        print("[object Object]", end="")


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
