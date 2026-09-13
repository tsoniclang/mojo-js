import assert from "node:assert/strict";
import test from "node:test";
import { canonicalIntlOptions, equivalentLocaleResult, referenceDate, referenceDateTimeFormat, referenceResolvedLocale } from "../../scripts/locale-reference.mjs";

test("date reference applies prototype defaults without dropping explicit hour cycles", () => {
  for (const [hourCycle, expectedHour] of [["h11", "0"], ["h12", "12"], ["h23", "00"], ["h24", "24"]]) {
    const entry = { operation: "time", value: 0, locales: "en-US", options: { timeZone: "UTC", hourCycle } };
    assert.equal(referenceDate(entry).split(":")[0], expectedHour);
  }
  assert.equal(referenceDate({ operation: "date", value: "invalid", locales: "bad_tag", options: null }), "Invalid Date");
  assert.throws(() => referenceDate({ operation: "time", value: 0, options: { dateStyle: "full" } }), TypeError);
  for (const hour12 of [false, true]) {
    const options = { timeZone: "UTC", hour: "numeric", hour12 };
    const baseline = new Intl.DateTimeFormat("en-US-u-ca-buddhist-nu-arab", options);
    for (const cycle of ["h11", "h12", "h23", "h24"]) {
      const actual = referenceDateTimeFormat(`en-US-u-ca-buddhist-hc-${cycle}-nu-arab`, options);
      assert.equal(actual.format(0), baseline.format(0));
      assert.equal(actual.resolvedOptions().calendar, "buddhist");
      assert.equal(actual.resolvedOptions().numberingSystem, "arab");
    }
  }
});

test("resolved locale retains only requested supported keywords not overridden by options", () => {
  const resolved = { locale: "de-u-co-phonebk", collation: "phonebk", numeric: false, caseFirst: "false" };
  assert.equal(referenceResolvedLocale({ locales: "de", options: { collation: "phonebk" } }, resolved, Intl.Collator), "de");
  assert.equal(referenceResolvedLocale({ locales: "de-x-u-co-phonebk" }, resolved, Intl.Collator), "de");
  assert.equal(referenceResolvedLocale({ locales: "de-u-co-phonebk", options: { collation: "PHONEBK" } }, resolved, Intl.Collator), "de-u-co-phonebk");
  assert.equal(referenceResolvedLocale({ locales: "de-u-co-phonebk", options: { usage: "search" } }, { ...resolved, collation: "default" }, Intl.Collator), "de");
  const date = { locale: "en-US", calendar: "gregory", numberingSystem: "latn" };
  assert.equal(referenceResolvedLocale({ locales: "en-US-u-hc-h24", options: { hourCycle: "h24" } }, date, Intl.DateTimeFormat), "en-US-u-hc-h24");
  assert.equal(referenceResolvedLocale({ locales: "en-US-u-hc-h24", options: { hour12: true } }, date, Intl.DateTimeFormat), "en-US");
  assert.deepEqual(canonicalIntlOptions({ calendar: "BUDDHIST", numberingSystem: "ARAB" }), { calendar: "buddhist", numberingSystem: "arab" });
});

test("locale-data comparison preserves digits punctuation multiplicity part types and non-date strings", () => {
  const expected = JSON.stringify("12:00 AM");
  assert.ok(equivalentLocaleResult({ operation: "time" }, expected, JSON.stringify("12:00\u202fAM")));
  for (const invalid of ["0:00 AM", "12:00  AM", "12:00AM", "12.00 AM", "12:00 PM"]) {
    assert.equal(equivalentLocaleResult({ operation: "time" }, expected, JSON.stringify(invalid)), false);
  }
  assert.equal(equivalentLocaleResult({ operation: "lower" }, expected, JSON.stringify("12:00\u202fAM")), false);
  assert.equal(equivalentLocaleResult({ operation: "dateParts" }, '[{"type":"hour","value":"1"}]', '[{"type":"minute","value":"1"}]'), false);
  assert.equal(equivalentLocaleResult({ operation: "date" }, "!error", '"Invalid Date"'), false);
});
