from std.collections import List, Set
from std.hashlib import hash
from std.memory import ArcPointer
from std.testing import assert_equal, assert_false, assert_true
from tsonic_runtime import (
    Callable,
    ErasedCallableContext,
    Location,
    RaisingCallable,
    WeakReferenceIdentity,
    allocate_callable_environment,
    destroy_callable_environment,
)
from tsonic_js import (
    JsString,
    JsValue,
    json_parse,
    json_stringify,
    json_stringify_with_property_list,
    json_stringify_with_property_list_and_space_number,
    json_stringify_with_property_list_and_space_string,
    js_value_from_source_object,
    object_keys,
)


@fieldwise_init
struct GetterOwner:
    var reads: Location[Int]


@fieldwise_init
struct GetterView:
    var owner: ArcPointer[GetterOwner]

    @staticmethod
    def length(_context: ErasedCallableContext, var _arguments: Tuple[]) -> Int:
        return 1

    @staticmethod
    def key(
        _context: ErasedCallableContext, var _arguments: Tuple[Int]
    ) -> JsString:
        return JsString("own")

    @staticmethod
    def value(
        _context: ErasedCallableContext, var _arguments: Tuple[Int]
    ) -> JsValue:
        return JsValue(1.0)

    @staticmethod
    def property(
        context: ErasedCallableContext, var arguments: Tuple[JsString]
    ) raises -> JsValue:
        if arguments[0] != JsString("inherited"):
            return JsValue()
        var environment = context.unsafe_bitcast[Self]()
        environment[].owner[].reads.write(
            environment[].owner[].reads.read() + 1
        )
        return JsValue(2.0)

    @staticmethod
    def destroy(context: ErasedCallableContext):
        destroy_callable_environment[Self](context)


def getter_value(reads: Location[Int]) -> JsValue:
    var owner = ArcPointer(GetterOwner(reads))
    var environment = allocate_callable_environment(
        GetterView(owner), GetterView.destroy
    )
    return js_value_from_source_object(
        WeakReferenceIdentity(owner),
        "",
        Callable[Tuple[], Int](environment, GetterView.length),
        Callable[Tuple[Int], JsString](environment, GetterView.key),
        Callable[Tuple[Int], JsValue](environment, GetterView.value),
        property_reader=RaisingCallable[Tuple[JsString], JsValue](
            environment, GetterView.property
        ),
    )


def main() raises:
    var object = json_parse(JsString('{"id":1,"label":"x","drop":3}'))
    var properties = json_parse(JsString('["label","id","label","absent"]'))
    assert_equal(
        json_stringify_with_property_list(object, properties)
        .value()
        .to_native_strict(),
        '{"label":"x","id":1}',
    )
    assert_equal(
        json_stringify_with_property_list_and_space_number(
            object, properties, 2
        )
        .value()
        .to_native_strict(),
        '{\n  "label": "x",\n  "id": 1\n}',
    )
    assert_equal(
        json_stringify_with_property_list_and_space_string(
            object, properties, JsString(" ")
        )
        .value()
        .to_native_strict(),
        '{\n "label": "x",\n "id": 1\n}',
    )

    var numeric = json_parse(JsString('{"0":"zero","1":"one","2":"two"}'))
    var numeric_keys = json_parse(JsString('[2,"1",2,1,false,null,{},-0]'))
    assert_equal(
        json_stringify_with_property_list(numeric, numeric_keys)
        .value()
        .to_native_strict(),
        '{"2":"two","1":"one","0":"zero"}',
    )
    var nested = json_parse(
        JsString('{"own":{"keep":2,"drop":3},"keep":4,"drop":5}')
    )
    var nested_keys = json_parse(JsString('["own","keep"]'))
    assert_equal(
        json_stringify_with_property_list(nested, nested_keys)
        .value()
        .to_native_strict(),
        '{"own":{"keep":2},"keep":4}',
    )
    var array = json_parse(JsString('[{"keep":1,"drop":2},3]'))
    assert_equal(
        json_stringify_with_property_list(
            array, json_parse(JsString('["keep"]'))
        )
        .value()
        .to_native_strict(),
        '[{"keep":1},3]',
    )
    assert_equal(
        json_stringify_with_property_list(array, json_parse(JsString("[]")))
        .value()
        .to_native_strict(),
        "[{},3]",
    )

    var reads = Location[Int](0)
    var getter = getter_value(reads)
    assert_equal(object_keys(getter)[0], JsString("own"))
    assert_equal(json_stringify(getter).value().to_native_strict(), '{"own":1}')
    assert_equal(reads.read(), 0)
    assert_equal(
        json_stringify_with_property_list(
            getter, json_parse(JsString('["inherited","own","inherited"]'))
        )
        .value()
        .to_native_strict(),
        '{"inherited":2,"own":1}',
    )
    assert_equal(reads.read(), 1)
    assert_false(getter.object_has_own(JsString("inherited")))

    var units = List[UInt16]()
    units.append(0xD800)
    var first = JsString(code_units=units.copy())
    var second = JsString(code_units=units^)
    assert_equal(hash(first), hash(second))
    var set = Set[JsString]()
    set.add(first)
    set.add(second)
    assert_equal(len(set), 1)
    assert_true(second in set)
