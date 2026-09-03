import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

const vectors = JSON.parse(await readFile(new URL("../test/regexp-oracle.json", import.meta.url), "utf8"));

for (const vector of vectors) {
  const expression = new RegExp(vector.pattern, vector.flags);
  assert.equal(expression.test(vector.input), vector.test, JSON.stringify(vector));
  expression.lastIndex = 0;
  assert.equal(vector.input.search(expression), vector.search, JSON.stringify(vector));
}

console.log(`ECMAScript RegExp oracle: ${vectors.length}/${vectors.length}`);
