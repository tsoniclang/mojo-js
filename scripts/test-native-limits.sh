#!/usr/bin/env bash
set -euo pipefail

PIXI_BIN="${PIXI_BIN:-pixi}"
output_file="$(mktemp)"
trap 'rm -f "${output_file}"' EXIT

assert_missing_module() {
  local source_file="$1"
  local module_name="$2"
  if "${PIXI_BIN}" run mojo build "${source_file}" >"${output_file}" 2>&1; then
    printf 'expected the pinned Mojo standard library to reject %s\n' "${module_name}" >&2
    exit 1
  fi
  grep -F "unable to locate module '${module_name}'" "${output_file}" >/dev/null
}

assert_missing_module test/native-limits/regexp.mojo regex
assert_missing_module test/native-limits/unicode-normalization.mojo unicode_normalization
