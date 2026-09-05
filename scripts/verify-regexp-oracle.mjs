import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import { spawnSync } from "node:child_process";
import { resolve } from "node:path";

const vectors = JSON.parse(await readFile(new URL("../test/regexp-oracle.json", import.meta.url), "utf8"));
const executable = process.argv[2];
if (executable === undefined) throw new Error("The compiled Mojo RegExp oracle driver is required.");

for (const vector of vectors) {
  const expression = new RegExp(vector.pattern, vector.flags);
  const firstTest = expression.test(vector.input);
  assert.equal(firstTest, vector.test, JSON.stringify(vector));
  const expected = [String(firstTest), String(expression.lastIndex)];
  expected.push(String(expression.test(vector.input)), String(expression.lastIndex));
  expression.lastIndex = 0;
  const search = vector.input.search(expression);
  assert.equal(search, vector.search, JSON.stringify(vector));
  expected.push(String(search), String(expression.lastIndex));
  const native = spawnSync(resolve(executable), [vector.pattern, vector.flags, vector.input], {
    encoding: "utf8", timeout: 15_000,
  });
  assert.equal(native.error, undefined, JSON.stringify(vector));
  assert.equal(native.status, 0, `${JSON.stringify(vector)}: ${native.stderr}`);
  assert.equal(native.stderr, "", JSON.stringify(vector));
  assert.deepEqual(native.stdout.trimEnd().split("\n"), expected, JSON.stringify(vector));
}

console.log(`ECMAScript RegExp native differential: ${vectors.length}/${vectors.length}`);
