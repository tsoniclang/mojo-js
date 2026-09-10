import assert from "node:assert/strict";
import { existsSync, readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import test from "node:test";
import { assertAcyclicImports, modules } from "./module-graph.mjs";

const runtime = resolve(dirname(fileURLToPath(import.meta.url)), "../../mojo/tsonic_js");
const root = resolve(runtime, "date");

test("Date separates arithmetic, parsing, timezone and mutable values", () => {
  assert.equal(existsSync(resolve(runtime, "date.mojo")), false);
  for (const path of modules(root)) {
    assert.ok(readFileSync(path, "utf8").split("\n").length <= 600, path);
  }
  assert.match(readFileSync(resolve(root, "model.mojo"), "utf8"), /struct JsDate\(ImplicitlyCopyable\)/u);
  assert.doesNotMatch(readFileSync(resolve(root, "arithmetic.mojo"), "utf8"), /external_call|timezone|from.*model import/u);
  assert.doesNotMatch(readFileSync(resolve(root, "model.mojo"), "utf8"), /= Float64\(FloatLiteral.nan\)/u);
  assertAcyclicImports(root);
});
