import assert from "node:assert/strict";
import { existsSync, readFileSync, readdirSync } from "node:fs";
import { dirname, resolve } from "node:path";
import test from "node:test";
import { fileURLToPath } from "node:url";

const runtime = resolve(dirname(fileURLToPath(import.meta.url)), "../../mojo/tsonic_js");
const regexp = resolve(runtime, "regexp");

function modules(directory) {
  return readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    const path = resolve(directory, entry.name);
    return entry.isDirectory() ? modules(path) : entry.name.endsWith(".mojo") ? [path] : [];
  });
}

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
  const graph = new Map();
  for (const path of modules(regexp)) {
    const dependencies = [];
    for (const match of readFileSync(path, "utf8").matchAll(/^from\s+(\.+)([\w.]+)\s+import/gmu)) {
      const base = resolve(dirname(path), ...Array(match[1].length - 1).fill(".."), ...match[2].split("."));
      const dependency = existsSync(`${base}.mojo`) ? `${base}.mojo` : resolve(base, "__init__.mojo");
      assert.ok(existsSync(dependency), `${path}: ${match[0]}`);
      dependencies.push(dependency);
    }
    graph.set(path, dependencies);
  }
  const active = new Set();
  const complete = new Set();
  function visit(path) {
    assert.ok(!active.has(path), `RegExp import cycle at ${path}`);
    if (complete.has(path) || !graph.has(path)) return;
    active.add(path);
    for (const dependency of graph.get(path)) visit(dependency);
    active.delete(path);
    complete.add(path);
  }
  for (const path of graph.keys()) visit(path);
});
