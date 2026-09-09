from tsonic_runtime import RaisingCallable
from ...string import JsString
from ...value import JsValue


comptime _E0[E: AnyType] = RaisingCallable[Tuple[], JsString, E]


comptime _E1[E: AnyType] = RaisingCallable[Tuple[JsString], JsString, E]


comptime _E2[E: AnyType] = RaisingCallable[
    Tuple[JsString, JsValue], JsString, E
]


comptime _E3[E: AnyType] = RaisingCallable[
    Tuple[JsString, JsValue, JsValue], JsString, E
]


comptime _E4[E: AnyType] = RaisingCallable[
    Tuple[JsString, JsValue, JsValue, JsValue], JsString, E
]


comptime _E5[E: AnyType] = RaisingCallable[
    Tuple[JsString, JsValue, JsValue, JsValue, JsValue], JsString, E
]


comptime _E6[E: AnyType] = RaisingCallable[
    Tuple[JsString, JsValue, JsValue, JsValue, JsValue, JsValue], JsString, E
]


comptime _E7[E: AnyType] = RaisingCallable[
    Tuple[JsString, JsValue, JsValue, JsValue, JsValue, JsValue, JsValue],
    JsString,
    E,
]


comptime _E8[E: AnyType] = RaisingCallable[
    Tuple[
        JsString,
        JsValue,
        JsValue,
        JsValue,
        JsValue,
        JsValue,
        JsValue,
        JsValue,
    ],
    JsString,
    E,
]
