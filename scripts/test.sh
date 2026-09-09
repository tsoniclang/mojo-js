#!/usr/bin/env bash
set -euo pipefail

PIXI_BIN="${PIXI_BIN:-pixi}"
NATIVE_BUILD=".temp/native-tests"

node --test test/architecture/*.test.mjs

"${PIXI_BIN}" run mojo format --quiet mojo tests
git diff --exit-code -- mojo tests

mkdir -p "${NATIVE_BUILD}"
CONDA_PREFIX="$(${PIXI_BIN} run printenv CONDA_PREFIX)"
native_object="$("${PIXI_BIN}" run bash ../mojo-runtime/scripts/build-native.sh)"
for source in regexp_bridge unicode_normalization_bridge date_timezone; do
  "${PIXI_BIN}" run bash -c 'exec "${CONDA_PREFIX:?}/bin/gcc" "$@"' -- -O3 -fPIC -std=c11 \
    -I"${CONDA_PREFIX}/include/quickjs" \
    -I"${CONDA_PREFIX}/include" \
    -c "mojo/tsonic_js.native/${source}.c" \
    -o "${NATIVE_BUILD}/${source}.o"
done

link_arguments=(
  -Xlinker "$native_object"
  -Xlinker -lstdc++
  -Xlinker "${NATIVE_BUILD}/regexp_bridge.o"
  -Xlinker "${NATIVE_BUILD}/unicode_normalization_bridge.o"
  -Xlinker "${NATIVE_BUILD}/date_timezone.o"
  -Xlinker "${CONDA_PREFIX}/lib/quickjs/libquickjs.a"
  -Xlinker "-L${CONDA_PREFIX}/lib"
  -Xlinker -ldl
  -Xlinker -licudata
  -Xlinker -licuuc
  -Xlinker -licui18n
  -Xlinker -lm
  -Xlinker -lpthread
)

"${PIXI_BIN}" run mojo build -j 2 -I mojo -I ../mojo-runtime/mojo \
  "${link_arguments[@]}" test/oracle/regexp_driver.mojo -o "${NATIVE_BUILD}/regexp_oracle"
node scripts/verify-regexp-oracle.mjs "${NATIVE_BUILD}/regexp_oracle"

"${PIXI_BIN}" run mojo build -j 2 -I mojo -I ../mojo-runtime/mojo \
  "${link_arguments[@]}" test/oracle/array_driver.mojo -o "${NATIVE_BUILD}/array_oracle"
node scripts/verify-array-oracle.mjs "${NATIVE_BUILD}/array_oracle"

"${PIXI_BIN}" run mojo build -j 2 -I mojo -I ../mojo-runtime/mojo \
  "${link_arguments[@]}" test/oracle/console_driver.mojo -o "${NATIVE_BUILD}/console_oracle"
node scripts/verify-console-oracle.mjs "${NATIVE_BUILD}/console_oracle"

"${PIXI_BIN}" run mojo build -j 2 -I mojo -I ../mojo-runtime/mojo \
  "${link_arguments[@]}" test/oracle/date_driver.mojo -o "${NATIVE_BUILD}/date_oracle"
node scripts/verify-date-oracle.mjs "${NATIVE_BUILD}/date_oracle"

failed=0
for test_file in tests/*.mojo; do
  test_name="$(basename "${test_file}" .mojo)"
  if "${PIXI_BIN}" run mojo build \
    -j 2 \
    -I mojo \
    -I ../mojo-runtime/mojo \
    "${link_arguments[@]}" \
    "${test_file}" \
    -o "${NATIVE_BUILD}/${test_name}" && "${NATIVE_BUILD}/${test_name}"; then
    printf 'PASS %s\n' "$test_file"
  else
    printf 'FAIL %s\n' "$test_file"
    failed=1
  fi
done

if ! bash scripts/test-native-limits.sh; then failed=1; fi
exit "$failed"
