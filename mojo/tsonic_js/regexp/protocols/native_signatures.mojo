from tsonic_runtime import RaisingCallable
from ...value import JsValue


comptime _N0[E: AnyType] = RaisingCallable[Tuple[], String, E]


comptime _N1[E: AnyType] = RaisingCallable[Tuple[String], String, E]


comptime _N2[E: AnyType] = RaisingCallable[Tuple[String, JsValue], String, E]


comptime _N3[E: AnyType] = RaisingCallable[
    Tuple[String, JsValue, JsValue], String, E
]


comptime _N4[E: AnyType] = RaisingCallable[
    Tuple[String, JsValue, JsValue, JsValue], String, E
]


comptime _N5[E: AnyType] = RaisingCallable[
    Tuple[String, JsValue, JsValue, JsValue, JsValue], String, E
]


comptime _N6[E: AnyType] = RaisingCallable[
    Tuple[String, JsValue, JsValue, JsValue, JsValue, JsValue], String, E
]


comptime _N7[E: AnyType] = RaisingCallable[
    Tuple[String, JsValue, JsValue, JsValue, JsValue, JsValue, JsValue],
    String,
    E,
]


comptime _N8[E: AnyType] = RaisingCallable[
    Tuple[
        String,
        JsValue,
        JsValue,
        JsValue,
        JsValue,
        JsValue,
        JsValue,
        JsValue,
    ],
    String,
    E,
]
