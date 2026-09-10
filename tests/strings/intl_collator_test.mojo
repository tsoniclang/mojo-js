from std.testing import assert_equal, assert_true, assert_false
from tsonic_runtime import WeakReferenceIdentity
from tsonic_js import IntlCollator, JsString, JsValue, json_parse


def data(source: String) raises -> JsValue:
    return json_parse(JsString(source))


def released_owner() raises -> WeakReferenceIdentity:
    var collator = IntlCollator(data('"en"'))
    return collator.weak_identity()


def main() raises:
    var german = IntlCollator(
        data('"de"'), data('{"numeric":true,"sensitivity":"base"}')
    )
    var retained_alias = german
    assert_equal(german, retained_alias)
    assert_true(german.weak_identity().same(retained_alias.weak_identity()))
    assert_equal(german.compare("ä", "a"), 0.0)
    for _ in range(64):
        assert_true(retained_alias.compare("file2", "file10") < 0.0)
    var swedish = IntlCollator(data('"sv"'), data('{"sensitivity":"base"}'))
    assert_true(swedish.compare("ä", "a") > 0.0)
    var resolved = german.resolved_options()
    assert_equal(resolved.get_locale(), "de")
    assert_equal(resolved.get_usage(), "sort")
    assert_equal(resolved.get_sensitivity(), "base")
    assert_equal(resolved.get_numeric(), True)
    assert_equal(resolved.get_collation(), "default")
    var saved = resolved
    saved.set_numeric(False)
    saved.set_locale("changed")
    assert_equal(resolved.get_numeric(), False)
    assert_equal(resolved.get_locale(), "changed")
    assert_equal(german.resolved_options().get_numeric(), True)
    assert_equal(german.resolved_options().get_locale(), "de")
    var extension = IntlCollator(data('"en-u-kn"'))
    assert_equal(extension.resolved_options().get_numeric(), True)
    assert_true("kn" in extension.resolved_options().get_locale())
    var override = IntlCollator(data('"en-u-kn"'), data('{"numeric":false}'))
    assert_equal(override.resolved_options().get_numeric(), False)
    assert_false("kn" in override.resolved_options().get_locale())
    var search = IntlCollator(
        data('"de"'),
        data('{"usage":"search","ignorePunctuation":true,"caseFirst":"upper"}'),
    )
    assert_equal(search.resolved_options().get_usage(), "search")
    assert_equal(search.resolved_options().get_collation(), "default")
    assert_equal(search.resolved_options().get_ignore_punctuation(), True)
    assert_equal(search.resolved_options().get_case_first(), "upper")
    assert_equal(search.compare("a-b", "ab"), 0.0)
    var phonebook = IntlCollator(data('"de-u-co-phonebk"'))
    assert_equal(phonebook.resolved_options().get_collation(), "phonebk")
    var lone = data('"\\ud800"').string_value()
    assert_equal(german.compare_units(lone, lone), 0.0)
    assert_false(released_owner().is_alive())
    var invalid = False
    try:
        _ = IntlCollator(data('"bad_tag"'))
    except:
        invalid = True
    assert_true(invalid)
