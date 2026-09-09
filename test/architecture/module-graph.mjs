import assert from "node:assert/strict";
import { existsSync, readFileSync, readdirSync } from "node:fs";
import { dirname, resolve } from "node:path";

export function modules(directory) {
  return readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    const path = resolve(directory, entry.name);
    return entry.isDirectory() ? modules(path) : entry.name.endsWith(".mojo") ? [path] : [];
  });
}

export function assertAcyclicImports(directory) {
  const graph = new Map();
  for (const path of modules(directory)) {
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
    assert.ok(!active.has(path), `Import cycle at ${path}`);
    if (complete.has(path) || !graph.has(path)) return;
    active.add(path);
    for (const dependency of graph.get(path)) visit(dependency);
    active.delete(path);
    complete.add(path);
  }
  for (const path of graph.keys()) visit(path);
}
