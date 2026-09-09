import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { mkdtempSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const executable = process.argv[2];
assert.ok(executable, "Expected a compiled native array oracle");
const words = new Set();
const buffer = new ArrayBuffer(8);
const view = new DataView(buffer);
for (const value of [0, -0, NaN, Infinity, -Infinity, Number.MIN_VALUE,
  Number.MAX_VALUE, Number.MIN_SAFE_INTEGER, Number.MAX_SAFE_INTEGER,
  1e-7, 1e-6, 1e20, 1e21, 0.1, 1.1, 1.5, 1000000000000000100]) {
  view.setFloat64(0, value);
  const bits = view.getBigUint64(0);
  for (const offset of [-2n, -1n, 0n, 1n, 2n]) {
    words.add(BigInt.asUintN(64, bits + offset));
  }
}
let state = 0x4d6f6a6f61727261n;
for (let index = 0; index < 8192; index += 1) {
  state = BigInt.asUintN(64, state * 6364136223846793005n + 1442695040888963407n);
  words.add(state);
}
const cases = [...words];
const directory = mkdtempSync(".temp/array-oracle-");
const input = join(directory, "binary64.txt");
writeFileSync(input, `${cases.map((bits) => bits.toString(16).padStart(16, "0")).join("\n")}\n`);
const output = execFileSync(executable, [input], {
  encoding: "utf8", timeout: 30000, maxBuffer: 2 * 1024 * 1024,
}).trimEnd().split("\n");
assert.equal(output.length, cases.length);
const mismatches = [];
for (const [index, bits] of cases.entries()) {
  view.setBigUint64(0, bits);
  const expected = [view.getFloat64(0)].join();
  if (output[index] !== expected) {
    mismatches.push({ bits: bits.toString(16), expected, actual: output[index] });
  }
}
assert.deepEqual(mismatches, []);
console.log(`Array binary64 stringification: ${cases.length}/${cases.length}, zero mismatches`);
