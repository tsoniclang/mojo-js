#!/usr/bin/env bash
set -euo pipefail

PIXI_BIN="${PIXI_BIN:-pixi}"
NATIVE_BUILD=".temp/native-tests"
BUILD_TIMEOUT="${MOJO_TEST_BUILD_TIMEOUT:-180s}"
RUN_TIMEOUT="${MOJO_TEST_RUN_TIMEOUT:-60s}"

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

failed=0
for oracle in regexp array console date locale; do
  if timeout "$BUILD_TIMEOUT" "${PIXI_BIN}" run mojo build -j 2 -I mojo -I ../mojo-runtime/mojo \
    "${link_arguments[@]}" "test/oracle/${oracle}_driver.mojo" -o "${NATIVE_BUILD}/${oracle}_oracle" && \
    timeout "$RUN_TIMEOUT" node "scripts/verify-${oracle}-oracle.mjs" "${NATIVE_BUILD}/${oracle}_oracle"; then
    printf 'PASS oracle/%s\n' "$oracle"
  else
    printf 'FAIL oracle/%s\n' "$oracle"
    failed=1
  fi
done

if timeout "$BUILD_TIMEOUT" "${PIXI_BIN}" run bash -c 'exec "${CONDA_PREFIX:?}/bin/gcc" "$@"' -- -O2 -std=c11 \
  tests/native/intl_test.c "${NATIVE_BUILD}"/intl/*.o \
  -L"${CONDA_PREFIX}/lib" -licui18n -licuuc -licudata -o "${NATIVE_BUILD}/intl_native" && \
  timeout "$RUN_TIMEOUT" "${NATIVE_BUILD}/intl_native"; then
  printf 'PASS tests/native/intl_test.c\n'
else
  printf 'FAIL tests/native/intl_test.c\n'
  failed=1
fi

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
  if timeout "$BUILD_TIMEOUT" "${PIXI_BIN}" run mojo build \
    -j 2 \
    -I mojo \
    -I ../mojo-runtime/mojo \
    "${link_arguments[@]}" \
    "${test_file}" \
    -o "${NATIVE_BUILD}/${test_name}" && timeout "$RUN_TIMEOUT" "${NATIVE_BUILD}/${test_name}"; then
    printf 'PASS %s\n' "$test_file"
  else
    printf 'FAIL %s\n' "$test_file"
    failed=1
  fi
done

if ! bash scripts/test-native-limits.sh; then failed=1; fi
exit "$failed"
