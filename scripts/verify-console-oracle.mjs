import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";

const executable = process.argv[2];
assert.ok(executable, "Expected a compiled native console oracle");
const actual = spawnSync(executable, [], { encoding: "utf8", timeout: 10000 });
const expected = spawnSync(process.execPath, ["-e", `
  console.log(0, 1, -0, 1.5, 1e21, NaN, Infinity, -Infinity);
  console.info("info", true);
  console.debug("debug", false);
  console.warn("warn", 1);
  console.error("error", -0);
`], { encoding: "utf8", timeout: 10000 });
assert.equal(actual.error, undefined);
assert.equal(actual.status, 0, actual.stderr);
assert.equal(expected.status, 0, expected.stderr);
assert.equal(actual.stdout, expected.stdout);
assert.equal(actual.stderr, expected.stderr);
console.log("Console scalar/channel parity: 5/5 calls, exact stdout/stderr");
