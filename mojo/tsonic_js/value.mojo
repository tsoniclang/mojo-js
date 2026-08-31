from std.utils import Variant
from tsonic_runtime import Null, Undefined

from .string import JsString


comptime JsPrimitiveValue = Variant[
    Undefined,
    Null,
    Bool,
    Float64,
    JsString,
]
