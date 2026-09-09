import assert from "node:assert/strict";
import { mkdirSync, writeFileSync } from "node:fs";
import path from "node:path";
import { spawnSync } from "node:child_process";

const executable = process.argv[2];
assert.ok(executable, "Expected the compiled locale oracle");
const cases = [];
const locales = [
  "en", "tr", "az", "lt", "el", "de", "sv", "ja", "th", "zz",
  "en-US-u-kn-true-kf-upper", "de-DE-u-co-phonebk", ["zz", "tr"], ["tr", "en"], [],
  "en-u-ks-level1", "en-u-co-search", "en-u-kf-bogus", "en-t-en-US-h0-hybrid",
];
for (const operation of ["lower", "upper", "defaultLower", "defaultUpper"]) {
  for (const value of ["", "Iİiı", "Straße", "ΟΣ ΟΣΑ", "I\u0301J\u0301", "\uD800A\uDFFF", "😀 Éé", "A\0B"]) {
    for (const locale of locales) cases.push({ operation, value, locales: locale });
  }
}
const options = [
  undefined, {}, { numeric: true }, { numeric: false }, { sensitivity: "base" },
  { sensitivity: "accent" }, { sensitivity: "case" }, { sensitivity: "variant" },
  { caseFirst: "upper" }, { caseFirst: "lower" }, { caseFirst: "false" },
  { ignorePunctuation: true }, { ignorePunctuation: false }, { usage: "search" },
  { collation: "phonebk" }, { collation: "bogus" }, { collation: "search" },
  { localeMatcher: "lookup", numeric: true, sensitivity: "base" },
];
for (const locale of locales) {
  for (const selected of options) {
    for (const [value, right] of [["file2", "file10"], ["ä", "a"], ["a-b", "ab"], ["A", "a"], ["\uD800", "\uDC00"], ["é", "e\u0301"]]) {
      cases.push({ operation: "compare", value, right, locales: locale, options: selected });
    }
  }
}
for (const locale of [null, "", "en_US", "abcd", "i-klingon", "x-private", "en-GB-oed", "de-1901-1901", "en-u-kn-u-kf", "en-u-a1-foo", "en-t-h0", "en\0-us", ["en", "bad_tag"], ["en", 3]]) {
  for (const operation of ["lower", "upper", "compare"]) cases.push({ operation, value: "I", right: "i", locales: locale });
}
for (const selected of [null, { sensitivity: "" }, { caseFirst: "" }, { usage: "invalid" }, { localeMatcher: "" }, { collation: "" }, { collation: "a" }, { collation: "phone_book" }]) {
  cases.push({ operation: "compare", value: "a", right: "b", locales: "en", options: selected });
}
const directory = path.resolve(".temp/locale-oracle");
const dateLocales = ["en-US", "en-GB", "de-DE", "fr-FR", "ja-JP", "ar-EG", "th-TH", "en-US-u-hc-h24", "en-US-u-ca-buddhist", "en-US-u-nu-arab", ["zz", "de-DE"]];
const dateOptions = [
  {}, { year: "numeric", month: "2-digit", day: "2-digit" },
  { weekday: "long", year: "numeric", month: "long", day: "numeric" },
  { era: "short", year: "2-digit", month: "short", day: "2-digit" },
  { hour: "numeric", minute: "numeric", second: "numeric" },
  { hour: "2-digit", minute: "2-digit", second: "2-digit", fractionalSecondDigits: 3 },
  { hour12: true }, { hour12: false }, { hourCycle: "h11" }, { hourCycle: "h12" },
  { hourCycle: "h23" }, { hourCycle: "h24" }, { hour12: false, hourCycle: "h12" },
  { calendar: "gregory", numberingSystem: "latn" },
  { calendar: "japanese", numberingSystem: "arab" },
  { calendar: "bogus", numberingSystem: "bogus" },
];
for (const operation of ["date", "time", "datetime"]) {
  for (const locale of dateLocales) {
    for (const selected of dateOptions) {
      for (const value of [0, -2208988800000, 1710064800123]) {
        cases.push({ operation, value, locales: locale, options: { timeZone: "UTC", ...selected } });
      }
    }
    for (const style of ["full", "long", "medium", "short"]) {
      const selected = operation === "date" ? { dateStyle: style }
        : operation === "time" ? { timeStyle: style } : { dateStyle: style, timeStyle: style };
      for (const hour12 of [undefined, true, false]) {
        cases.push({ operation, value: 1710064800123, locales: locale, options: { timeZone: "UTC", ...selected, hour12 } });
      }
    }
  }
  for (const timeZone of ["UTC", "utc", "America/New_York", "america/new_york", "Europe/Berlin", "Asia/Kolkata", "+05:30", "-01", "+0530"]) {
    for (const value of [0, 1710053999000, 1710054000000, 1730611799000, 1730615400000]) {
      cases.push({ operation, value, locales: "en-US", options: { timeZone } });
    }
  }
  for (const value of [-8640000000000000, -14831769600000, 8640000000000000]) {
    cases.push({ operation, value, locales: "en-US", options: { timeZone: "UTC" } });
  }
  for (const selected of [null, { timeZone: "" }, { timeZone: "Etc/Unknown" }, { timeZone: "UTC\0tail" },
    { timeZone: "+24:00" }, { timeZone: "+01:60" }, { timeZone: "No/Such_Zone" }, { timeZone: "Asia/Kolkata" },
    { hourCycle: "" }, { calendar: "a" }, { numberingSystem: "" }, { year: "" },
    { dateStyle: "" }, { dateStyle: "short", year: "numeric" }, { timeStyle: "short", hour: "numeric" },
    { fractionalSecondDigits: 0 }, { fractionalSecondDigits: 4 }, { localeMatcher: "" }]) {
    cases.push({ operation, value: 0, locales: "en-US", options: selected });
  }
  for (const locale of [null, "not_a_tag", ["en-US", "invalid_tag"]]) {
    cases.push({ operation, value: 0, locales: locale });
    cases.push({ operation, value: "invalid date", locales: locale, options: null });
  }
}
mkdirSync(directory, { recursive: true });
const input = path.join(directory, "cases.jsonl");
writeFileSync(input, cases.map((entry) => JSON.stringify(entry)).join("\n") + "\n");
const actual = spawnSync(executable, [input], { encoding: "utf8", timeout: 30000, maxBuffer: 8 * 1024 * 1024 });
assert.equal(actual.error, undefined);
assert.equal(actual.status, 0, actual.stderr);
assert.equal(actual.stderr, "");
const lines = actual.stdout.trimEnd().split("\n");
assert.equal(lines.length, cases.length);
const failures = [];
for (const [index, entry] of cases.entries()) {
  let expected;
  try {
    const value = entry.operation === "date" ? new Date(entry.value).toLocaleDateString(entry.locales, entry.options)
      : entry.operation === "time" ? new Date(entry.value).toLocaleTimeString(entry.locales, entry.options)
        : entry.operation === "datetime" ? new Date(entry.value).toLocaleString(entry.locales, entry.options)
          : entry.operation === "lower" ? entry.value.toLocaleLowerCase(entry.locales)
      : entry.operation === "upper" ? entry.value.toLocaleUpperCase(entry.locales)
        : entry.operation === "defaultLower" ? entry.value.toLowerCase()
          : entry.operation === "defaultUpper" ? entry.value.toUpperCase()
            : Math.sign(entry.value.localeCompare(entry.right, entry.locales, entry.options));
    expected = JSON.stringify(value);
  } catch {
    expected = "!error";
  }
  if (lines[index] !== expected) failures.push({ entry, expected, actual: lines[index] });
}
assert.deepEqual(failures, []);
console.log(`Locale string/date oracle: ${cases.length}/${cases.length}`);
