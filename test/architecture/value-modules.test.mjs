import assert from "node:assert/strict";
import { existsSync, readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import test from "node:test";
import { assertAcyclicImports, modules } from "./module-graph.mjs";

const runtime = resolve(dirname(fileURLToPath(import.meta.url)), "../../mojo/tsonic_js");
const root = resolve(runtime, "value");

test("closed JavaScript values separate representation, construction and protocols", () => {
  assert.equal(existsSync(resolve(runtime, "value.mojo")), false);
  const owners = new Map();
  for (const path of modules(root)) {
    const source = readFileSync(path, "utf8");
    assert.ok(source.split("\n").length <= 600, path);
    for (const match of source.matchAll(/^(?:struct|def|comptime)\s+([A-Za-z_]\w*)/gmu)) {
      assert.ok(!owners.has(match[1]), match[1]);
      owners.set(match[1], path);
    }
  }
  for (const [name, owner] of [
    ["JsValue", "model"], ["_JsValueNode", "model"],
    ["_JsValueBuilder", "builder"], ["_append_js_value_graph", "graph"],
    ["js_value_structured_clone", "clone"],
    ["js_value_from_object_entries", "factories"],
    ["_js_value_from_tagged_callback_argument", "tagged"],
  ]) assert.equal(owners.get(name), resolve(root, `${owner}.mojo`));
  const entrypoint = readFileSync(resolve(root, "__init__.mojo"), "utf8");
  assert.doesNotMatch(entrypoint, /^(?:struct|def|comptime)\s/mu);
  assert.match(entrypoint, /_JsValueBuilder/u);
  assert.match(entrypoint, /_js_value_from_tagged_callback_argument/u);
  assertAcyclicImports(root);
});
