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
    const value = entry.operation === "lower" ? entry.value.toLocaleLowerCase(entry.locales)
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
console.log(`Locale string oracle: ${cases.length}/${cases.length}`);
