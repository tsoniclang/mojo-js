import assert from "node:assert/strict";
import { mkdirSync, writeFileSync } from "node:fs";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { canonicalIntlOptions, equivalentLocaleResult, referenceDate, referenceResolvedLocale } from "./locale-reference.mjs";

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
  { collation: "phonebk" }, { collation: "PHONEBK" },
  { collation: "bogus" }, { collation: "search" },
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
  { calendar: "BUDDHIST", numberingSystem: "ARAB" },
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
const numberOptions = [
  undefined, {}, { style: "percent" }, { style: "currency", currency: "USD" },
  { style: "currency", currency: "jpy" }, { style: "currency", currency: "KWD" },
  { style: "currency", currency: "XXX", currencyDisplay: "code" },
  { style: "currency", currency: "CAD", currencyDisplay: "narrowSymbol" },
  { style: "currency", currency: "EUR", currencyDisplay: "name", currencySign: "accounting" },
  { style: "currency", currency: "USD", currencySign: "accounting", signDisplay: "always" },
  { useGrouping: false }, { useGrouping: true }, { minimumIntegerDigits: 5 },
  { minimumFractionDigits: 4 }, { maximumFractionDigits: 1 }, { minimumFractionDigits: 2, maximumFractionDigits: 4 },
  { minimumSignificantDigits: 3 }, { maximumSignificantDigits: 2 },
  { minimumFractionDigits: 2, minimumSignificantDigits: 3, roundingPriority: "morePrecision" },
  { maximumFractionDigits: 2, maximumSignificantDigits: 3, roundingPriority: "lessPrecision" },
  { minimumFractionDigits: 101, maximumSignificantDigits: 3 },
  { minimumFractionDigits: 2, maximumFractionDigits: 2, roundingIncrement: 5 },
  { minimumFractionDigits: 2, trailingZeroDisplay: "stripIfInteger" },
  { notation: "scientific" }, { notation: "engineering" },
  { notation: "compact" }, { notation: "compact", compactDisplay: "long" },
  { numberingSystem: "arab" }, { numberingSystem: "ARAB" }, { numberingSystem: "mathsans" },
  { numberingSystem: "bogus" },
];
for (const signDisplay of ["auto", "always", "never", "exceptZero", "negative"]) numberOptions.push({ signDisplay });
for (const roundingMode of ["ceil", "floor", "expand", "trunc", "halfCeil", "halfFloor", "halfExpand", "halfTrunc", "halfEven"]) {
  numberOptions.push({ roundingMode, maximumFractionDigits: 1 });
}
for (const locale of ["en-US", "de-DE", "fr-FR", "hi-IN", "ar-EG", "ja-JP", "en-US-u-nu-arab", ["zz", "en-US"]]) {
  for (const selected of numberOptions) {
    for (const value of [0, "-0", "NaN", "Infinity", "-Infinity", 1, -1, 1.25, -1.25, 0.125, 1234.56, 1e21, 1e-8]) {
      cases.push({ operation: "number", value, locales: locale, options: selected });
    }
    for (const value of ["9007199254740993", "-9223372036854775808", "18446744073709551615"]) {
      cases.push({ operation: "number", value, numericKind: "integer", locales: locale, options: selected });
    }
  }
}
for (const selected of [null, { style: "currency" }, { currency: "US" }, { currency: "US€" }, { currency: "USD\0" },
  { currencyDisplay: "" }, { currencySign: "" }, { minimumIntegerDigits: 0 }, { maximumFractionDigits: 101 },
  { minimumFractionDigits: 3, maximumFractionDigits: 2 }, { maximumSignificantDigits: 22 },
  { roundingIncrement: 3 }, { roundingIncrement: 5, maximumSignificantDigits: 2 },
  { roundingIncrement: 5, minimumFractionDigits: 1, maximumFractionDigits: 2 },
  { roundingMode: "" }, { roundingPriority: "" }, { trailingZeroDisplay: "" }, { signDisplay: "" },
  { useGrouping: "bogus" }, { numberingSystem: "a" }, { localeMatcher: "" }]) {
  cases.push({ operation: "number", value: 1.25, locales: "en-US", options: selected });
}
for (const locale of [null, "invalid_tag", ["en-US", "invalid_tag"]]) {
  cases.push({ operation: "number", value: 42, locales: locale });
}
for (const locale of ["en-US", "de-DE", "ar-EG", "ja-JP", "en-US-u-nu-arab"]) {
  for (const selected of numberOptions) {
    cases.push({ operation: "numberResolved", locales: locale, options: selected });
    for (const value of ["-0", "NaN", "-Infinity", -1234.5, 0.001, 12000]) {
      cases.push({ operation: "numberFormat", value, locales: locale, options: selected });
      cases.push({ operation: "numberParts", value, locales: locale, options: selected });
    }
    cases.push({ operation: "numberParts", value: "9007199254740993", numericKind: "integer", locales: locale, options: selected });
  }
}
for (const locale of dateLocales) {
  for (const selected of [...dateOptions, { dateStyle: "full", timeStyle: "long" }]) {
    const options = { timeZone: "UTC", ...selected };
    cases.push({ operation: "dateResolvedBase", locales: locale, options });
    for (const value of [0, 1710064800123]) {
      cases.push({ operation: "dateFormat", value, locales: locale, options });
      cases.push({ operation: "dateParts", value, locales: locale, options });
    }
  }
}
for (const locale of ["en", "de", "sv", "th", "de-u-co-phonebk", "en-u-kn-kf-upper"]) {
  for (const selected of options) {
    cases.push({ operation: "collatorResolved", locales: locale, options: selected });
    cases.push({ operation: "collatorCompare", value: "file2", right: "file10", locales: locale, options: selected });
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
let localeDataVariations = 0;
for (const [index, original] of cases.entries()) {
  let expected;
  try {
    const invalidPrototypeDate = ["date", "time", "datetime"].includes(original.operation) &&
      Number.isNaN(new Date(original.value).getTime());
    const entry = { ...original, options: invalidPrototypeDate ? original.options : canonicalIntlOptions(original.options) };
    if (entry.operation === "lower" || entry.operation === "upper") Intl.getCanonicalLocales(entry.locales);
    const number = entry.numericKind === "integer" ? BigInt(entry.value) : Number(entry.value);
    const value = entry.operation === "numberFormat" ? new Intl.NumberFormat(entry.locales, entry.options).format(number)
      : entry.operation === "numberParts" ? new Intl.NumberFormat(entry.locales, entry.options).formatToParts(number)
        : entry.operation === "numberResolved" ? new Intl.NumberFormat(entry.locales, entry.options).resolvedOptions()
          : entry.operation === "dateFormat" ? new Intl.DateTimeFormat(entry.locales, entry.options).format(Number(entry.value))
            : entry.operation === "dateParts" ? new Intl.DateTimeFormat(entry.locales, entry.options).formatToParts(Number(entry.value))
              : entry.operation === "dateResolvedBase" ? dateResolvedBase(entry)
                : entry.operation === "collatorResolved" ? collatorResolved(entry)
                  : entry.operation === "collatorCompare" ? Math.sign(new Intl.Collator(entry.locales, entry.options).compare(entry.value, entry.right))
      : entry.operation === "number" ? number.toLocaleString(entry.locales, entry.options)
      : ["date", "time", "datetime"].includes(entry.operation) ? referenceDate(entry)
          : entry.operation === "lower" ? entry.value.toLocaleLowerCase(entry.locales)
      : entry.operation === "upper" ? entry.value.toLocaleUpperCase(entry.locales)
        : entry.operation === "defaultLower" ? entry.value.toLowerCase()
          : entry.operation === "defaultUpper" ? entry.value.toUpperCase()
            : Math.sign(entry.value.localeCompare(entry.right, entry.locales, entry.options));
    expected = JSON.stringify(value);
  } catch {
    expected = "!error";
  }
  if (!equivalentLocaleResult(original, expected, lines[index])) failures.push({ entry: original, expected, actual: lines[index] });
  else if (lines[index] !== expected) localeDataVariations += 1;
}
assert.deepEqual(failures, []);
console.log(`Locale string/date/number oracle: ${cases.length}/${cases.length}; permitted date-literal data variations: ${localeDataVariations}`);

function dateResolvedBase(entry) {
  const result = new Intl.DateTimeFormat(entry.locales, entry.options).resolvedOptions();
  return { locale: referenceResolvedLocale(entry, result, Intl.DateTimeFormat), calendar: result.calendar, numberingSystem: result.numberingSystem, timeZone: result.timeZone };
}

function collatorResolved(entry) {
  const result = new Intl.Collator(entry.locales, entry.options).resolvedOptions();
  return { ...result, locale: referenceResolvedLocale(entry, result, Intl.Collator) };
}
