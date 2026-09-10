import assert from "node:assert/strict";
import { existsSync, readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import test from "node:test";
import { fileURLToPath } from "node:url";
import { assertAcyclicImports, modules } from "./module-graph.mjs";

const runtime = resolve(dirname(fileURLToPath(import.meta.url)), "../../mojo/tsonic_js");
const regexp = resolve(runtime, "regexp");

test("RegExp engine, protocols and results have one implementation per declaration", () => {
  for (const former of ["regexp", "regexp_bridge", "regexp_results", "regexp_callbacks", "regexp_callbacks_exact", "regexp_callbacks_native"]) {
    assert.equal(existsSync(resolve(runtime, `${former}.mojo`)), false, former);
  }
  const declarations = new Map();
  for (const path of modules(regexp)) {
    const source = readFileSync(path, "utf8");
    assert.ok(source.split("\n").length <= 600, path);
    for (const match of source.matchAll(/^(?:struct|def|comptime)\s+([A-Za-z_]\w*)/gmu)) {
      const owner = declarations.get(match[1]);
      assert.ok(owner === undefined || owner === path, `${match[1]} in ${owner} and ${path}`);
      declarations.set(match[1], path);
    }
  }
  for (const [name, path] of [
    ["JsRegExp", "core.mojo"],
    ["_RegExpBridge", "engine/bridge.mojo"],
    ["RegExpNativeResult", "protocols/records.mojo"],
    ["JsRegExpExecArray", "results/matches.mojo"],
    ["_parse_exact_exec", "results/decode.mojo"],
  ]) assert.equal(declarations.get(name), resolve(regexp, path));
});

test("RegExp internal imports are resolvable and acyclic", () => {
  assertAcyclicImports(regexp);
});
