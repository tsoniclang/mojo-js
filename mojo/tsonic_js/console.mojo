from .value import JsValue


fn _console_write(label: String, *data: JsValue):
    if label:
        print(label, end="")
    for index in range(len(data)):
        if index != 0:
            print(" ", end="")
        print(data[index], end="")
    print()


fn console_debug(*data: JsValue):
    _console_write("", *data)


fn console_error(*data: JsValue):
    _console_write("", *data)


fn console_info(*data: JsValue):
    _console_write("", *data)


fn console_log(*data: JsValue):
    _console_write("", *data)


fn console_warn(*data: JsValue):
    _console_write("", *data)
