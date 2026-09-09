import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";

const executable = process.argv[2];
assert.ok(executable, "Expected a compiled native Date oracle");
const reference = `
  function describe(date) {
    for (const method of [
      "getTime", "getFullYear", "getMonth", "getDate", "getDay", "getHours",
      "getMinutes", "getSeconds", "getMilliseconds", "getTimezoneOffset",
    ]) console.log(String(date[method]()));
    console.log(Number.isNaN(date.getTime()) ? "Invalid Date" : date.toISOString());
    if (!Number.isNaN(date.getTime())) {
      console.log(String(Date.parse(date.toUTCString())));
      console.log(String(Date.parse(date.toString())));
    }
  }
  for (const timestamp of [
    0, -86400000, 951782400000, 1710053999000, 1710054000000,
    1730613599000, 1730613600000, 1325239199000, 1325239200000, NaN,
  ]) describe(new Date(timestamp));
  for (const text of [
    "2024-03-10T02:30:00", "2024-11-03T01:30:00",
    "2011-12-30T12:00:00", "2000-02-29", "2000-02-29T00:00:00",
  ]) describe(new Date(text));
  describe(new Date(2024, 2, 10, 2, 30));
  describe(new Date(2024, 10, 3, 1, 30));
  describe(new Date(2011, 11, 30, 12));
  const setters = new Date("2024-03-10T00:30:00");
  setters.setHours(2); describe(setters);
  setters.setMinutes(50, 30, 0); describe(setters);
  setters.setMonth(10, 3); setters.setHours(1, 30, 0, 0); describe(setters);
  setters.setFullYear(2025); describe(setters);
  setters.setTime(NaN); setters.setFullYear(2000); describe(setters);
`;
for (const timezone of ["UTC", "America/New_York", "Asia/Kolkata", "Pacific/Apia"]) {
  const options = {
    encoding: "utf8", timeout: 15000, maxBuffer: 1024 * 1024,
    env: { ...process.env, TZ: timezone },
  };
  const expected = spawnSync(process.execPath, ["-e", reference], options);
  const actual = spawnSync(executable, [], options);
  assert.equal(expected.error, undefined);
  assert.equal(expected.status, 0, expected.stderr);
  assert.equal(actual.error, undefined);
  assert.equal(actual.status, 0, actual.stderr);
  assert.equal(actual.stdout, expected.stdout, timezone);
  assert.equal(actual.stderr, "", timezone);
}
console.log("Date native/oracle parity: 4 timezones, DST gaps/overlaps and supplied fields");
