#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
output_root="${project_root}/.temp/native-tests"
manifest="${project_root}/mojo/tsonic_js.runtime.json"
prefix="${CONDA_PREFIX:?Run the native build inside the pinned Pixi environment}"

unit_text="$(node --input-type=module -e '
  import { readFileSync } from "node:fs";
  const manifest = JSON.parse(readFileSync(process.argv[1], "utf8"));
  for (const unit of manifest.translationUnits) {
    if (unit.language !== "c" || unit.standard !== "c11") {
      throw new Error("The JS runtime native builder requires its declared C11 units");
    }
    console.log(unit.path);
  }
' "$manifest")"
mapfile -t units <<<"$unit_text"
objects=()
for unit in "${units[@]}"; do
  relative="${unit#tsonic_js.native/}"
  object="${output_root}/${relative%.c}.o"
  mkdir -p "$(dirname "$object")"
  "$prefix/bin/gcc" -O3 -fPIC -std=c11 -I"$prefix/include" -I"$prefix/include/quickjs" \
    -c "${project_root}/mojo/${unit}" -o "$object"
  objects+=("$object")
done
for object in "${objects[@]}"; do printf '%s\n%s\n' -Xlinker "$object"; done
node --input-type=module -e '
  import { readFileSync } from "node:fs";
  import path from "node:path";
  const manifest = JSON.parse(readFileSync(process.argv[1], "utf8"));
  const prefix = process.argv[2];
  for (const library of manifest.staticLibraries) {
    console.log("-Xlinker");
    console.log(path.join(prefix, library));
  }
  console.log("-Xlinker");
  console.log(`-L${path.join(prefix, "lib")}`);
  for (const library of manifest.dynamicLibraries) {
    console.log("-Xlinker");
    console.log(`-l${library}`);
  }
' "$manifest" "$prefix"
