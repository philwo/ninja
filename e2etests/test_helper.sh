#!/bin/sh
# Shared test helper library for ninja e2e tests.
# Source this file at the top of every test script:
#   . "$(dirname "$0")/../test_helper.sh"
#
# Supports both ninja and siso binaries. Auto-detects siso when the binary
# name starts with "siso", or when SISO_MODE=1 is set in the environment.

set -e

# --- Setup ---

# Accept ninja binary from $1 or $NINJA env var
if [ -n "$1" ]; then
  NINJA="$1"
fi

if [ -z "${NINJA}" ]; then
  echo "FATAL: ninja binary path not set (pass as \$1 or set \$NINJA)" >&2
  exit 1
fi

# Make NINJA an absolute path
case "${NINJA}" in
  /*) ;;
  *)  NINJA="$(cd "$(dirname "${NINJA}")" && pwd)/$(basename "${NINJA}")" ;;
esac

export NINJA

# --- Siso mode detection ---

_SISO_MODE=0
case "$(basename "${NINJA}")" in
  siso*) _SISO_MODE=1 ;;
esac
# Allow explicit override via environment
if [ "${SISO_MODE:-}" = "1" ]; then
  _SISO_MODE=1
elif [ "${SISO_MODE:-}" = "0" ]; then
  _SISO_MODE=0
fi

# Accept temp dir from $2 or create one
if [ -n "$2" ]; then
  TEST_DIR="$2"
else
  TEST_DIR="$(mktemp -d)"
fi

# --- Color support ---

if [ "${NINJA_TEST_COLOR:-0}" = "1" ]; then
  _CLR_GREEN=$(printf '\033[0;32m')
  _CLR_RED=$(printf '\033[0;31m')
  _CLR_DIM=$(printf '\033[2m')
  _CLR_RESET=$(printf '\033[0m')
else
  _CLR_GREEN=''
  _CLR_RED=''
  _CLR_DIM=''
  _CLR_RESET=''
fi

_FAIL_DUMPED=0

_pass_assert() {
  printf '%s✓ %s%s\n' "${_CLR_GREEN}" "$1" "${_CLR_RESET}" >&2
}

# --- Cleanup ---

cleanup() {
  if [ "${NINJA_TEST_DEBUG:-0}" = "1" ] && [ "${_FAIL_DUMPED}" = "0" ]; then
    if [ -s "${_NINJA_STDOUT}" ]; then
      printf '%s--- stdout ---%s\n' "${_CLR_DIM}" "${_CLR_RESET}" >&2
      sed 's/^/  /' "${_NINJA_STDOUT}" >&2
    fi
    if [ -s "${_NINJA_STDERR}" ]; then
      printf '%s--- stderr ---%s\n' "${_CLR_DIM}" "${_CLR_RESET}" >&2
      sed 's/^/  /' "${_NINJA_STDERR}" >&2
    fi
  fi
  cd /
  rm -rf "${TEST_DIR}"
}
trap cleanup EXIT

cd "${TEST_DIR}"

# --- Siso config setup ---

if [ "${_SISO_MODE}" = "1" ]; then
  # Siso requires a Starlark config. Create a minimal no-op config so that
  # siso can find its exec root when searching upward from the working dir.
  mkdir -p "${TEST_DIR}/build/config/siso"
  cat > "${TEST_DIR}/build/config/siso/main.star" <<'SISO_STAR'
load("@builtin//encoding.star", "json")
load("@builtin//struct.star", "module")

def init(ctx):
    return module(
        "config",
        step_config = json.encode({}),
        filegroups = {},
        handlers = {},
    )
SISO_STAR
fi

# Print test description from the "# Test: ..." comment on line 2
_test_desc=$(sed -n '2s/^# Test: *//p' "$0")
if [ -n "${_test_desc}" ]; then
  printf '%s# %s%s\n' "${_CLR_DIM}" "${_test_desc}" "${_CLR_RESET}" >&2
fi

# Files used to capture ninja output
_NINJA_STDOUT="${TEST_DIR}/.ninja_test_stdout"
_NINJA_STDERR="${TEST_DIR}/.ninja_test_stderr"
NINJA_EXIT=0

# --- Core function ---

# Filter siso-specific diagnostic lines from stdout, keeping only build
# output that a ninja binary would produce (progress lines, command output,
# "ninja: ..." messages, etc.).
_filter_siso_stdout() {
  sed \
    -e '/^loading/d' \
    -e '/^load /d' \
    -e '/^schedule /d' \
    -e '/^build start:/d' \
    -e '/^build finished/d' \
    -e '/^local:[0-9]/d' \
    -e '/^fs: ops:/d' \
    -e '/^shutdown /d' \
    -e '/^[	 ]*$/d' \
    "$1" > "$2"
}

_run_siso_ninja() {
  # Translate ninja flags to siso equivalents and exec.
  # All test arguments are simple tokens (no spaces/special chars).
  _siso_args="-offline"
  for _arg in "$@"; do
    case "${_arg}" in
      -j[0-9]*)  _siso_args="${_siso_args} -j ${_arg#-j}" ;;
      -k[0-9]*)  _siso_args="${_siso_args} -k ${_arg#-k}" ;;
      *)         _siso_args="${_siso_args} ${_arg}" ;;
    esac
  done
  eval "\"${NINJA}\" ninja ${_siso_args}"
}

run_ninja() {
  if [ "${_SISO_MODE}" = "1" ]; then
    printf '%s$ siso ninja %s%s\n' "${_CLR_DIM}" "$*" "${_CLR_RESET}" >&2
    set +e
    _run_siso_ninja "$@" >"${_NINJA_STDOUT}.raw" 2>"${_NINJA_STDERR}"
    NINJA_EXIT=$?
    set -e
    _filter_siso_stdout "${_NINJA_STDOUT}.raw" "${_NINJA_STDOUT}"
  else
    printf '%s$ ninja %s%s\n' "${_CLR_DIM}" "$*" "${_CLR_RESET}" >&2
    set +e
    "${NINJA}" "$@" >"${_NINJA_STDOUT}" 2>"${_NINJA_STDERR}"
    NINJA_EXIT=$?
    set -e
  fi
}

# --- Assertion helpers ---

fail() {
  _FAIL_DUMPED=1
  printf '%s✗ %s%s\n' "${_CLR_RED}" "$1" "${_CLR_RESET}" >&2
  if [ -s "${_NINJA_STDOUT}" ]; then
    printf '%s--- stdout ---%s\n' "${_CLR_DIM}" "${_CLR_RESET}" >&2
    sed 's/^/  /' "${_NINJA_STDOUT}" >&2
  fi
  if [ -s "${_NINJA_STDERR}" ]; then
    printf '%s--- stderr ---%s\n' "${_CLR_DIM}" "${_CLR_RESET}" >&2
    sed 's/^/  /' "${_NINJA_STDERR}" >&2
  fi
  exit 1
}

assert_exit_success() {
  if [ "${NINJA_EXIT}" -ne 0 ]; then
    fail "expected exit 0, got ${NINJA_EXIT}"
  fi
  _pass_assert "exit code is 0"
}

assert_exit_failure() {
  if [ "${NINJA_EXIT}" -eq 0 ]; then
    fail "expected non-zero exit, got 0"
  fi
  _pass_assert "exit code is non-zero"
}

assert_exit_code() {
  if [ "${NINJA_EXIT}" -ne "$1" ]; then
    fail "expected exit $1, got ${NINJA_EXIT}"
  fi
  _pass_assert "exit code is $1"
}

assert_stdout_contains() {
  if ! grep -qF -e "$1" "${_NINJA_STDOUT}"; then
    fail "stdout does not contain '$1'"
  fi
  _pass_assert "stdout contains '$1'"
}

assert_stderr_contains() {
  if ! grep -qF -e "$1" "${_NINJA_STDERR}"; then
    fail "stderr does not contain '$1'"
  fi
  _pass_assert "stderr contains '$1'"
}

assert_stdout_not_contains() {
  if grep -qF -e "$1" "${_NINJA_STDOUT}"; then
    fail "stdout should not contain '$1'"
  fi
  _pass_assert "stdout does not contain '$1'"
}

assert_stderr_not_contains() {
  if grep -qF -e "$1" "${_NINJA_STDERR}"; then
    fail "stderr should not contain '$1'"
  fi
  _pass_assert "stderr does not contain '$1'"
}

assert_contains_regex() {
  if ! grep -qE -e "$1" "$2"; then
    fail "file '$2' does not match regex '$1'"
  fi
  _pass_assert "file '$2' matches regex '$1'"
}

assert_stdout_regex() {
  if ! grep -qE -e "$1" "${_NINJA_STDOUT}"; then
    fail "stdout does not match regex '$1'"
  fi
  _pass_assert "stdout matches regex '$1'"
}

assert_stdout_line_count() {
  _actual_lines="$(wc -l < "${_NINJA_STDOUT}")"
  # Trim whitespace (some wc implementations pad the output)
  _actual_lines="$(echo "${_actual_lines}" | tr -d ' ')"
  if [ "${_actual_lines}" -ne "$1" ]; then
    fail "expected stdout to have $1 line(s), got ${_actual_lines}"
  fi
  _pass_assert "stdout has $1 line(s)"
}

assert_stderr_regex() {
  if ! grep -qE -e "$1" "${_NINJA_STDERR}"; then
    fail "stderr does not match regex '$1'"
  fi
  _pass_assert "stderr matches regex '$1'"
}

assert_output_contains() {
  # Check combined stdout+stderr
  if ! grep -qF -e "$1" "${_NINJA_STDOUT}" && ! grep -qF -e "$1" "${_NINJA_STDERR}"; then
    fail "neither stdout nor stderr contains '$1'"
  fi
  _pass_assert "output contains '$1'"
}

assert_output_regex() {
  # Check combined stdout+stderr with regex
  if ! grep -qE -e "$1" "${_NINJA_STDOUT}" && ! grep -qE -e "$1" "${_NINJA_STDERR}"; then
    fail "neither stdout nor stderr matches regex '$1'"
  fi
  _pass_assert "output matches regex '$1'"
}

assert_file_exists() {
  if [ ! -f "$1" ]; then
    fail "file '$1' does not exist"
  fi
  _pass_assert "file '$1' exists"
}

assert_file_not_exists() {
  if [ -f "$1" ]; then
    fail "file '$1' should not exist"
  fi
  _pass_assert "file '$1' does not exist"
}

assert_dir_exists() {
  if [ ! -d "$1" ]; then
    fail "directory '$1' does not exist"
  fi
  _pass_assert "directory '$1' exists"
}

assert_file_contains() {
  if [ ! -f "$1" ]; then
    fail "file '$1' does not exist (expected to contain '$2')"
  fi
  if ! grep -qF -e "$2" "$1"; then
    fail "file '$1' does not contain '$2'"
  fi
  _pass_assert "file '$1' contains '$2'"
}

assert_file_content_equals() {
  if [ ! -f "$1" ]; then
    fail "file '$1' does not exist"
  fi
  _actual="$(cat "$1")"
  if [ "${_actual}" != "$2" ]; then
    fail "file '$1' content mismatch: expected '$2', got '${_actual}'"
  fi
  _pass_assert "file '$1' content equals expected"
}

assert_file_newer() {
  if [ ! "$1" -nt "$2" ]; then
    fail "'$1' is not newer than '$2'"
  fi
  _pass_assert "'$1' is newer than '$2'"
}

assert_file_not_newer() {
  if [ "$1" -nt "$2" ]; then
    fail "'$1' should not be newer than '$2'"
  fi
  _pass_assert "'$1' is not newer than '$2'"
}

# Skip test (exit 77 convention)
skip_test() {
  echo "SKIP: $1" >&2
  exit 77
}

# Skip test when running under siso (for ninja-specific features)
skip_if_siso() {
  if [ "${_SISO_MODE}" = "1" ]; then
    skip_test "not supported in siso: $1"
  fi
}
