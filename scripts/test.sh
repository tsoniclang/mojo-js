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
js_native_output="$("${PIXI_BIN}" run bash scripts/build-native.sh)"
mapfile -t js_native_arguments <<<"${js_native_output}"

link_arguments=(
  -Xlinker "$native_object"
  -Xlinker -lstdc++
  "${js_native_arguments[@]}"
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

"${PIXI_BIN}" run mojo build -j 2 -I mojo -I ../mojo-runtime/mojo \
  "${link_arguments[@]}" test/oracle/locale_driver.mojo -o "${NATIVE_BUILD}/locale_oracle"
node scripts/verify-locale-oracle.mjs "${NATIVE_BUILD}/locale_oracle"

"${PIXI_BIN}" run bash -c 'exec "${CONDA_PREFIX:?}/bin/gcc" "$@"' -- -O2 -std=c11 \
  tests/native/intl_test.c "${NATIVE_BUILD}"/intl/*.o \
  -L"${CONDA_PREFIX}/lib" -licui18n -licuuc -licudata -o "${NATIVE_BUILD}/intl_native"
"${NATIVE_BUILD}/intl_native"

failed=0
test_inventory="$(find tests -type f -name '*.mojo' -print)"
if [[ -z "$test_inventory" ]]; then
  printf 'No native JavaScript proofs found\n' >&2
  exit 1
fi
mapfile -t test_files < <(printf '%s\n' "$test_inventory" | LC_ALL=C sort)
for test_file in "${test_files[@]}"; do
  test_name="${test_file#tests/}"
  test_name="${test_name%.mojo}"
  mkdir -p "$(dirname "${NATIVE_BUILD}/${test_name}")"
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
