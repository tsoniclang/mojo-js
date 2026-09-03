#!/usr/bin/env bash
set -euo pipefail

PIXI_BIN="${PIXI_BIN:-pixi}"
NATIVE_BUILD=".temp/native-tests"

"${PIXI_BIN}" run mojo format --quiet mojo tests
git diff --exit-code -- mojo tests

node scripts/verify-regexp-oracle.mjs

mkdir -p "${NATIVE_BUILD}"
CONDA_PREFIX="$(${PIXI_BIN} run printenv CONDA_PREFIX)"
for source in regexp_bridge unicode_normalization_bridge; do
  "${PIXI_BIN}" run cc -O3 -fPIC -std=c11 \
    -I"${CONDA_PREFIX}/include/quickjs" \
    -I"${CONDA_PREFIX}/include" \
    -c "mojo/tsonic_js.native/${source}.c" \
    -o "${NATIVE_BUILD}/${source}.o"
done

link_arguments=(
  -Xlinker "${NATIVE_BUILD}/regexp_bridge.o"
  -Xlinker "${NATIVE_BUILD}/unicode_normalization_bridge.o"
  -Xlinker "${CONDA_PREFIX}/lib/quickjs/libquickjs.a"
  -Xlinker "-L${CONDA_PREFIX}/lib"
  -Xlinker -ldl
  -Xlinker -licudata
  -Xlinker -licuuc
  -Xlinker -lm
  -Xlinker -lpthread
)

for test_file in tests/*.mojo; do
  test_name="$(basename "${test_file}" .mojo)"
  "${PIXI_BIN}" run mojo build \
    -j 2 \
    -I mojo \
    -I ../mojo-runtime/mojo \
    "${link_arguments[@]}" \
    "${test_file}" \
    -o "${NATIVE_BUILD}/${test_name}"
  "${NATIVE_BUILD}/${test_name}"
done

bash scripts/test-native-limits.sh
