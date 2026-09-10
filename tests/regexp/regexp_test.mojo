from std.memory import ArcPointer
from std.testing import assert_equal, assert_false, assert_true

from tsonic_js import (
    JsRegExp,
    JsString,
    regexp_call,
    regexp_construct,
    regexp_escape,
    string_normalize,
    string_replace_all_callback_1,
)
from tsonic_runtime import (
    ErasedCallableContext,
    RaisingCallable,
    allocate_callable_environment,
    destroy_callable_environment,
)
from tsonic_runtime.callable import ErasedCallableEnvironment


@fieldwise_init
struct ReplacementEnvironment:
    var prefix: String

    @staticmethod
    def replace(
        context: ErasedCallableContext,
        var arguments: Tuple[String],
    ) raises -> String:
        var environment = context.unsafe_bitcast[ReplacementEnvironment]()
        return environment[].prefix + arguments[0] + ">"

    @staticmethod
    def destroy(context: ErasedCallableContext):
        destroy_callable_environment[ReplacementEnvironment](context)


def replacement_environment() -> ArcPointer[ErasedCallableEnvironment]:
    return allocate_callable_environment(
        ReplacementEnvironment("<"), ReplacementEnvironment.destroy
    )


def assert_oracle_vectors() raises:
    var plain = regexp_construct("abc")
    assert_true(plain.test_native("xxabcxx"))
    assert_equal(plain.search_native("xxabcxx"), 2)

    var dot_all = regexp_construct("a.c", "s")
    assert_true(dot_all.test_native("a\nc"))

    var lookbehind = regexp_construct("(?<=a)b")
    assert_equal(lookbehind.search_native("zab"), 2)

    var backreference = regexp_construct("(a)\\1")
    assert_true(backreference.test_native("zaaz"))

    var greek = regexp_construct("\\p{Script=Greek}+", "u")
    assert_equal(greek.search_native("aαβz"), 1)

    var unicode_sets = regexp_construct("[\\p{ASCII}&&\\p{Letter}]+", "v")
    assert_equal(unicode_sets.search_native("éAb9"), 1)

    var astral = regexp_construct(".", "u")
    assert_true(astral.test_native("😀"))

    var missing = regexp_construct("missing")
    assert_false(missing.test_native("present"))
    assert_equal(missing.search_native("present"), -1)


def assert_construction_and_state() raises:
    var expression = regexp_construct("a+", "gim")
    assert_equal(expression.source(), "a+")
    assert_equal(expression.flags(), "gim")
    assert_true(expression.global_())
    assert_true(expression.ignore_case())
    assert_true(expression.multiline())
    assert_equal(expression.to_string(), "/a+/gim")

    var execution = expression.exec_native("xxaa").value()
    assert_equal(execution.first(), "aa")
    assert_equal(execution.index(), 2)
    assert_equal(execution.input(), "xxaa")
    assert_equal(expression.last_index(), 4)

    var called = regexp_call(expression)
    called.set_last_index(1)
    assert_equal(expression.last_index(), 1)

    var clone = regexp_construct(expression)
    assert_equal(clone.last_index(), 0)
    assert_equal(clone.source(), expression.source())

    var sticky = regexp_construct("b", "y")
    sticky.set_last_index(2)
    assert_equal(sticky.exec_native("aab").value().index(), 2)
    assert_equal(sticky.last_index(), 3)
    assert_false(Bool(sticky.exec_native("aab")))
    assert_equal(sticky.last_index(), 0)

    var rejected = False
    try:
        _ = regexp_construct("a", "gg")
    except:
        rejected = True
    assert_true(rejected)


def assert_results_and_string_protocols() raises:
    var detailed = regexp_construct("(?<word>[a-z]+)([0-9]+)?", "d")
    var execution = detailed.exec_native("42alpha").value()
    assert_equal(execution.first(), "alpha")
    assert_equal(execution.get_index(1).value(), "alpha")
    assert_false(Bool(execution.get_index(2)))
    assert_equal(execution.groups().value().get("word").value(), "alpha")
    var full_span = execution.indices().value().get_index(0).value()
    assert_equal(full_span[0], 2)
    assert_equal(full_span[1], 7)

    var global_expression = regexp_construct("a", "g")
    var matched = global_expression.match_native("aba").value()
    assert_equal(len(matched), 2)
    assert_equal(matched.get_index(0).value(), "a")
    assert_equal(matched.get_index(1).value(), "a")

    var all = regexp_construct("a(.)", "g").match_all_native("abac")
    var all_values = all.iter_values()
    assert_equal(len(all_values), 2)
    assert_equal(all_values[0].first(), "ab")
    assert_equal(all_values[1].get_index(1).value(), "c")

    var separator = regexp_construct("(-)")
    var split = separator.split_native("a-b")
    assert_equal(len(split), 3)
    assert_equal(split.get(0).value(), "a")
    assert_equal(split.get(1).value(), "-")
    assert_equal(split.get(2).value(), "b")

    var replacement = regexp_construct("(?<letter>a)(b)", "g")
    assert_equal(
        replacement.replace_all_native("ab-ab", "[$<letter>][$2][$&][$$]"),
        "[a][b][ab][$]-[a][b][ab][$]",
    )

    var non_global_rejected = False
    try:
        _ = regexp_construct("a").replace_all_native("aba", "x")
    except:
        non_global_rejected = True
    assert_true(non_global_rejected)

    var callback_result = string_replace_all_callback_1(
        "aba",
        regexp_construct("a", "g"),
        RaisingCallable[Tuple[String], String](
            replacement_environment(), ReplacementEnvironment.replace
        ),
    )
    assert_equal(callback_result^.unwrap(), "<a>b<a>")


def assert_utf16_and_unicode_normalization() raises:
    var legacy = JsRegExp(JsString("."), JsString("d"))
    var legacy_match = legacy.exec(JsString("😀")).value()
    assert_equal(len(legacy_match.first()), 1)
    var legacy_span = legacy_match.indices().value().get_index(0).value()
    assert_equal(legacy_span[0], 0)
    assert_equal(legacy_span[1], 1)

    var unicode = JsRegExp(JsString("."), JsString("du"))
    var unicode_match = unicode.exec(JsString("😀")).value()
    assert_equal(len(unicode_match.first()), 2)
    var unicode_span = unicode_match.indices().value().get_index(0).value()
    assert_equal(unicode_span[0], 0)
    assert_equal(unicode_span[1], 2)

    var escaped = regexp_escape("a-b.c")
    var literal = regexp_construct(escaped)
    assert_true(literal.test_native("a-b.c"))
    assert_false(literal.test_native("axbxc"))

    assert_equal(string_normalize("é", "NFC"), "é")
    assert_equal(string_normalize("é", "NFD"), "é")
    assert_equal(string_normalize("①", "NFKC"), "1")
    assert_equal(string_normalize("ﬁ", "NFKD"), "fi")
    assert_equal(string_normalize("😀", "NFC"), "😀")

    var invalid_form_rejected = False
    try:
        _ = string_normalize("value", "INVALID")
    except:
        invalid_form_rejected = True
    assert_true(invalid_form_rejected)


def main() raises:
    assert_oracle_vectors()
    assert_construction_and_state()
    assert_results_and_string_protocols()
    assert_utf16_and_unicode_normalization()
