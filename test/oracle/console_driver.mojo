from tsonic_js import (
    JsString,
    JsValue,
    console_debug,
    console_error,
    console_info,
    console_log,
    console_warn,
)


def main():
    var values: List[JsValue] = [
        JsValue(Float64(0)),
        JsValue(Float64(1)),
        JsValue(Float64(-0.0)),
        JsValue(Float64(1.5)),
        JsValue(Float64(1e21)),
        JsValue(Float64(FloatLiteral.nan)),
        JsValue(Float64(FloatLiteral.infinity)),
        JsValue(Float64(FloatLiteral.negative_infinity)),
    ]
    console_log(values)
    console_info([JsValue(JsString("info")), JsValue(True)])
    console_debug([JsValue(JsString("debug")), JsValue(False)])
    console_warn([JsValue(JsString("warn")), JsValue(Float64(1))])
    console_error([JsValue(JsString("error")), JsValue(Float64(-0.0))])
