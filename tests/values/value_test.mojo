from std.collections import List
from std.memory import ArcPointer
from std.testing import assert_equal, assert_false, assert_true
from tsonic_js import (
    JsString,
    JsValue,
    js_truthy,
    js_value_from_array_values,
    js_value_from_object_entries,
    js_value_from_json_projection,
    js_value_structured_clone,
    js_value_to_string,
    json_parse,
    json_stringify,
    json_stringify_with_replacer_and_space_number,
    json_stringify_with_space_string,
    object_entries,
    object_has_own,
    object_is,
    object_keys,
    object_values,
    symbol_new,
)
from tsonic_js.value import _JsValueBuilder
from tsonic_runtime import (
    ErasedCallableContext,
    Location,
    RaisingCallable,
    allocate_callable_environment,
    destroy_callable_environment,
)
from tsonic_runtime.callable import ErasedCallableEnvironment

from tsonic_js import boolean_to_string, boolean_value_of


@fieldwise_init
struct JsonReplacerEnvironment:
    var calls: Location[Int]

    @staticmethod
    def replace(
        context: ErasedCallableContext,
        var arguments: Tuple[String, JsValue],
    ) raises -> JsValue:
        var environment = context.unsafe_bitcast[JsonReplacerEnvironment]()
        environment[].calls.write(environment[].calls.read() + 1)
        if arguments[0] == "drop":
            return JsValue.undefined()
        if arguments[0] == "projected":
            return arguments[1].object_get(JsString("key")).value()
        return arguments[1]

    @staticmethod
    def destroy(context: ErasedCallableContext):
        destroy_callable_environment[JsonReplacerEnvironment](context)


@fieldwise_init
struct JsonProjectionEnvironment:
    var calls: Location[Int]

    @staticmethod
    def project(
        context: ErasedCallableContext,
        var arguments: Tuple[String],
    ) raises -> JsValue:
        var environment = context.unsafe_bitcast[JsonProjectionEnvironment]()
        environment[].calls.write(environment[].calls.read() + 1)
        var keys = List[JsString]()
        keys.append(JsString("key"))
        var values = List[JsValue]()
        values.append(JsValue(JsString(arguments[0])))
        return js_value_from_object_entries(keys^, values^)

    @staticmethod
    def destroy(context: ErasedCallableContext):
        destroy_callable_environment[JsonProjectionEnvironment](context)


def json_replacer_environment(
    calls: Location[Int],
) -> ArcPointer[ErasedCallableEnvironment]:
    return allocate_callable_environment(
        JsonReplacerEnvironment(calls), JsonReplacerEnvironment.destroy
    )


def json_projection(calls: Location[Int]) -> JsValue:
    var environment = allocate_callable_environment(
        JsonProjectionEnvironment(calls), JsonProjectionEnvironment.destroy
    )
    return js_value_from_json_projection(
        RaisingCallable[Tuple[String], JsValue](
            environment, JsonProjectionEnvironment.project
        )
    )


def main() raises:
    assert_equal(boolean_to_string(True).to_native_strict(), "true")
    assert_false(boolean_value_of(False))
    var number = JsValue(Float64(4.5))
    assert_true(number.is_number())
    assert_equal(number.number_value(), 4.5)
    assert_true(js_truthy(number))

    var text = JsValue(JsString("text"))
    assert_true(text.is_string())
    assert_equal(text.string_value().to_native_strict(), "text")
    assert_false(js_truthy(JsValue(JsString())))

    var missing = JsValue.undefined()
    assert_true(missing.is_undefined())
    assert_false(js_truthy(missing))
    assert_true(
        object_is(
            JsValue(Float64(FloatLiteral.nan)),
            JsValue(Float64(FloatLiteral.nan)),
        )
    )
    assert_false(object_is(JsValue(-0.0), JsValue(0.0)))
    var identity_symbol = symbol_new(JsString("identity"))
    assert_true(object_is(JsValue(identity_symbol), JsValue(identity_symbol)))
    assert_false(
        object_is(
            JsValue(identity_symbol),
            JsValue(symbol_new(JsString("identity"))),
        )
    )

    var parsed = json_parse(
        JsString('{"plain":1,"2":"two","1":true,"nested":[null,"😀"]}')
    )
    assert_true(parsed.is_object())
    assert_true(object_has_own(parsed, JsString("nested")))
    var keys = object_keys(parsed)
    assert_equal(keys[0].to_native_strict(), "1")
    assert_equal(keys[1].to_native_strict(), "2")
    assert_equal(keys[2].to_native_strict(), "plain")
    assert_equal(keys[3].to_native_strict(), "nested")
    assert_equal(len(object_values(parsed)), 4)
    assert_equal(len(object_entries(parsed)), 4)

    var encoded = json_stringify(parsed)
    assert_true(Bool(encoded))
    assert_equal(
        encoded.value().to_native_strict(),
        '{"1":true,"2":"two","plain":1,"nested":[null,"😀"]}',
    )
    assert_false(Bool(json_stringify(JsValue.undefined())))
    assert_false(Bool(json_stringify(JsValue(symbol_new(JsString("value"))))))

    var json_keys = List[JsString]()
    json_keys.append(JsString("keep"))
    json_keys.append(JsString("drop"))
    var json_values = List[JsValue]()
    json_values.append(JsValue(1.0))
    json_values.append(JsValue(2.0))
    var json_object = js_value_from_object_entries(json_keys^, json_values^)
    var replacer_calls = Location[Int](0)
    var pretty = json_stringify_with_replacer_and_space_number(
        json_object,
        RaisingCallable[Tuple[String, JsValue], JsValue](
            json_replacer_environment(replacer_calls),
            JsonReplacerEnvironment.replace,
        ),
        2,
    )
    assert_equal(pretty.value().to_native_strict(), '{\n  "keep": 1\n}')
    assert_equal(replacer_calls.read(), 3)

    var projection_calls = Location[Int](0)
    var projection = json_projection(projection_calls)
    assert_true(object_is(projection, projection))
    assert_false(object_is(projection, json_projection(Location[Int](0))))
    assert_equal(
        json_stringify(projection).value().to_native_strict(), '{"key":""}'
    )
    assert_equal(projection_calls.read(), 1)

    var projection_keys = List[JsString]()
    projection_keys.append(JsString("nested"))
    var projection_values = List[JsValue]()
    projection_values.append(projection)
    assert_equal(
        json_stringify(
            js_value_from_object_entries(projection_keys^, projection_values^)
        )
        .value()
        .to_native_strict(),
        '{"nested":{"key":"nested"}}',
    )
    assert_equal(projection_calls.read(), 2)

    var projected_keys = List[JsString]()
    projected_keys.append(JsString("projected"))
    var projected_values = List[JsValue]()
    projected_values.append(projection)
    var projected_replacer_calls = Location[Int](0)
    assert_equal(
        json_stringify_with_replacer_and_space_number(
            js_value_from_object_entries(projected_keys^, projected_values^),
            RaisingCallable[Tuple[String, JsValue], JsValue](
                json_replacer_environment(projected_replacer_calls),
                JsonReplacerEnvironment.replace,
            ),
            0,
        )
        .value()
        .to_native_strict(),
        '{"projected":"projected"}',
    )
    assert_equal(projected_replacer_calls.read(), 2)
    assert_equal(projection_calls.read(), 3)

    try:
        _ = js_value_structured_clone(projection)
        raise Error("JSON projection unexpectedly structured-cloned")
    except error:
        assert_equal(
            String(error),
            "JavaScript JSON projections cannot be structured-cloned",
        )

    var shared_object = json_parse(JsString('{"shared":true}'))
    var shared_keys = List[JsString]()
    shared_keys.append(JsString("first"))
    shared_keys.append(JsString("second"))
    var shared_values = List[JsValue]()
    shared_values.append(shared_object)
    shared_values.append(shared_object)
    var shared_container = js_value_from_object_entries(
        shared_keys^, shared_values^
    )
    assert_true(shared_container.object_value(0).same_identity(shared_object))
    assert_true(
        shared_container.object_value(0).same_identity(
            shared_container.object_value(1)
        )
    )
    var shared_clone = js_value_structured_clone(shared_container)
    assert_true(
        shared_clone.object_value(0).same_identity(shared_clone.object_value(1))
    )
    assert_false(shared_clone.object_value(0).same_identity(shared_object))

    var array_values = List[JsValue]()
    array_values.append(JsValue(1.0))
    array_values.append(JsValue.undefined())
    var pretty_array = json_stringify_with_space_string(
        js_value_from_array_values(array_values^),
        JsString("abcdefghijk"),
    )
    assert_equal(
        pretty_array.value().to_native_strict(),
        "[\nabcdefghij1,\nabcdefghijnull\n]",
    )
    assert_equal(
        js_value_to_string(JsValue.undefined()).to_native_strict(), "undefined"
    )
    assert_equal(js_value_to_string(JsValue.null()).to_native_strict(), "null")
    assert_equal(js_value_to_string(JsValue(True)).to_native_strict(), "true")
    assert_equal(js_value_to_string(JsValue(4.5)).to_native_strict(), "4.5")
    assert_equal(
        js_value_to_string(JsValue(JsString("text"))).to_native_strict(), "text"
    )
    assert_equal(String(JsValue(JsString("written"))), "written")
    assert_equal(
        js_value_to_string(parsed).to_native_strict(), "[object Object]"
    )
    assert_equal(
        js_value_to_string(
            json_parse(JsString('[null,"value",[1],{}]'))
        ).to_native_strict(),
        ",value,1,[object Object]",
    )

    var graph = _JsValueBuilder()
    var shared = graph.append_string(JsString("shared"))
    var children = List[Int]()
    children.append(shared)
    children.append(shared)
    var original = graph.value(graph.append_array(children^))
    var cloned = js_value_structured_clone(original)
    assert_false(cloned.same_identity(original))
    assert_true(cloned.array_at(0).same_identity(cloned.array_at(1)))
    assert_false(cloned.array_at(0).same_identity(original.array_at(0)))
    assert_equal(cloned.array_at(0).string_value().to_native_strict(), "shared")

    var unrelated = _JsValueBuilder()
    _ = unrelated.append_symbol(symbol_new(JsString("not reachable")))
    var reachable = unrelated.value(
        unrelated.append_string(JsString("reachable"))
    )
    assert_equal(
        js_value_structured_clone(reachable).string_value().to_native_strict(),
        "reachable",
    )

    var symbol_graph = _JsValueBuilder()
    var symbol = symbol_graph.value(
        symbol_graph.append_symbol(symbol_new(JsString("identity")))
    )
    try:
        _ = js_value_structured_clone(symbol)
        raise Error("symbol unexpectedly structured-cloned")
    except error:
        assert_equal(
            String(error), "JavaScript symbols cannot be structured-cloned"
        )

    try:
        _ = json_parse(JsString('{"broken":}'))
        raise Error("invalid JSON unexpectedly parsed")
    except error:
        assert_equal(String(error), "invalid JSON value")
