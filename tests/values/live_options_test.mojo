from std.collections import List
from std.memory import ArcPointer
from std.testing import assert_equal, assert_true
from tsonic_runtime import Callable, ErasedCallableContext, RaisingCallable, WeakReferenceIdentity, allocate_callable_environment, destroy_callable_environment
from tsonic_js import IntlCollator, IntlDateTimeFormat, IntlNumberFormat, JsString, JsValue, js_value_from_source_object, json_parse
from tsonic_js.intl.date_options import DateOptions
from tsonic_js.intl.number_options import NumberOptions
from tsonic_js.intl.options import CollationOptions


@fieldwise_init
struct OptionOwner:
    var values: JsValue
    var reads: List[String]


@fieldwise_init
struct OptionView:
    var owner: ArcPointer[OptionOwner]

    @staticmethod
    def length(_context: ErasedCallableContext, var _arguments: Tuple[]) -> Int:
        return 0

    @staticmethod
    def key(_context: ErasedCallableContext, var _arguments: Tuple[Int]) -> JsString:
        return JsString()

    @staticmethod
    def value(_context: ErasedCallableContext, var _arguments: Tuple[Int]) -> JsValue:
        return JsValue()

    @staticmethod
    def property(context: ErasedCallableContext, var arguments: Tuple[JsString]) raises -> JsValue:
        var owner = context.unsafe_bitcast[Self]()[].owner
        var name = arguments[0].to_native_strict()
        owner[].reads.append(name)
        return owner[].values.property_get(arguments[0])

    @staticmethod
    def destroy(context: ErasedCallableContext):
        destroy_callable_environment[Self](context)


def options(owner: ArcPointer[OptionOwner]) -> JsValue:
    var context = allocate_callable_environment(OptionView(owner), OptionView.destroy)
    return js_value_from_source_object(
        WeakReferenceIdentity(owner),
        Callable[Tuple[], Int](context, OptionView.length),
        Callable[Tuple[Int], JsString](context, OptionView.key),
        Callable[Tuple[Int], JsValue](context, OptionView.value),
        property_reader=RaisingCallable[Tuple[JsString], JsValue](context, OptionView.property),
    )


def assert_reads(owner: ArcPointer[OptionOwner], expected: String) raises:
    var names = expected.split("|")
    assert_equal(len(owner[].reads), len(names))
    for index in range(len(names)):
        assert_equal(owner[].reads[index], names[index])


def first_read(owner: ArcPointer[OptionOwner], name: String) raises -> Int:
    var position = -1
    for index in range(len(owner[].reads)):
        if owner[].reads[index] == name:
            assert_equal(position, -1)
            position = index
    assert_true(position >= 0)
    return position


def main() raises:
    var number = ArcPointer(OptionOwner(json_parse(JsString('{"style":"currency","currency":"usd","numberingSystem":"latn"}')), List[String]()))
    var number_settings = NumberOptions(options(number))
    assert_equal(number_settings.numbering, "latn")
    _ = first_read(number, "numberingSystem")
    _ = first_read(number, "currency")
    assert_true(first_read(number, "trailingZeroDisplay") < first_read(number, "compactDisplay"))
    assert_true(first_read(number, "compactDisplay") < first_read(number, "useGrouping"))
    var date = ArcPointer(OptionOwner(json_parse(JsString('{"calendar":"gregory","numberingSystem":"latn","timeZone":"UTC","year":"numeric"}')), List[String]()))
    var date_settings = DateOptions(options(date), "date", "date")
    assert_equal(date_settings.zone, "UTC")
    assert_reads(date, "localeMatcher|calendar|numberingSystem|hour12|hourCycle|timeZone|weekday|era|year|month|day|dayPeriod|hour|minute|second|fractionalSecondDigits|timeZoneName|formatMatcher|dateStyle|timeStyle")
    var collator = ArcPointer(OptionOwner(json_parse(JsString('{"collation":"phonebk","numeric":true,"caseFirst":"upper","sensitivity":"base"}')), List[String]()))
    var collator_settings = CollationOptions(options(collator))
    assert_equal(collator_settings.numeric, 1)
    assert_reads(collator, "usage|localeMatcher|collation|numeric|caseFirst|sensitivity|ignorePunctuation")
    number[].reads.clear()
    var number_formatter = IntlNumberFormat(JsValue(JsString("en")), options(number))
    var number_reads = len(number[].reads)
    number[].values = json_parse(JsString('{"style":"percent"}'))
    assert_equal(number_formatter.format(12.5), "$12.50")
    _ = number_formatter.format_to_parts(12.5)
    _ = number_formatter.resolved_options()
    assert_equal(len(number[].reads), number_reads)
    date[].reads.clear()
    var date_formatter = IntlDateTimeFormat(JsValue(JsString("en")), options(date))
    var date_reads = len(date[].reads)
    date[].values = json_parse(JsString('{"year":"2-digit"}'))
    assert_equal(date_formatter.format(0.0), "1970")
    _ = date_formatter.format_to_parts(0.0)
    _ = date_formatter.resolved_options()
    assert_equal(len(date[].reads), date_reads)
    collator[].reads.clear()
    var retained_collator = IntlCollator(JsValue(JsString("en")), options(collator))
    var collator_reads = len(collator[].reads)
    collator[].values = json_parse(JsString('{"numeric":false}'))
    assert_true(retained_collator.compare("file2", "file10") < 0)
    _ = retained_collator.resolved_options()
    assert_equal(len(collator[].reads), collator_reads)
