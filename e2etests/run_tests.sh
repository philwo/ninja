#!/bin/sh
# Top-level runner for ninja e2e tests.
# Usage: ./e2etests/run_tests.sh /path/to/ninja [filter ...]
# If filters are given, only tests whose directory name contains a filter are run.
# Example: ./e2etests/run_tests.sh build/ninja t0001 t0009

set -e

if [ $# -lt 1 ]; then
  echo "usage: $0 /path/to/ninja" >&2
  exit 1
fi

NINJA="$1"
shift

# Remaining arguments are optional test filters
FILTERS="$*"

# Make NINJA an absolute path
case "${NINJA}" in
  /*) ;;
  *)  NINJA="$(cd "$(dirname "${NINJA}")" && pwd)/$(basename "${NINJA}")" ;;
esac

if [ ! -x "${NINJA}" ]; then
  echo "error: '${NINJA}' is not an executable" >&2
  exit 1
fi

export NINJA

# Color support (auto-detect tty, overridable via NINJA_TEST_COLOR=0|1)
if [ -z "${NINJA_TEST_COLOR+x}" ]; then
  if [ -t 1 ]; then
    NINJA_TEST_COLOR=1
  else
    NINJA_TEST_COLOR=0
  fi
fi
export NINJA_TEST_COLOR

if [ "${NINJA_TEST_COLOR}" = "1" ]; then
  _CLR_GREEN=$(printf '\033[0;32m')
  _CLR_RED=$(printf '\033[0;31m')
  _CLR_YELLOW=$(printf '\033[0;33m')
  _CLR_RESET=$(printf '\033[0m')
else
  _CLR_GREEN=''
  _CLR_RED=''
  _CLR_YELLOW=''
  _CLR_RESET=''
fi

# Find the e2etests directory (where this script lives)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

passed=0
failed=0
skipped=0
failures=""

# Discover and run all test scripts
for test_script in "${SCRIPT_DIR}"/t*/test.sh; do
  [ -f "${test_script}" ] || continue

  test_name="$(basename "$(dirname "${test_script}")")"

  # If filters were given, skip tests that don't match any filter
  if [ -n "${FILTERS}" ]; then
    _matched=0
    for _f in ${FILTERS}; do
      case "${test_name}" in
        *"${_f}"*) _matched=1; break ;;
        *) ;;
      esac
    done
    [ "${_matched}" -eq 1 ] || continue
  fi

  _test_tmpdir="$(mktemp -d)"
  set +e
  output="$(sh "${test_script}" "${NINJA}" "${_test_tmpdir}" 2>&1)"
  rc=$?
  set -e

  # Clean up temp dir (test cleanup trap may have already done this)
  rm -rf "${_test_tmpdir}" 2>/dev/null || true

  if [ "${rc}" -eq 0 ]; then
    printf "  %sPASS%s  %s\n" "${_CLR_GREEN}" "${_CLR_RESET}" "${test_name}"
    passed=$((passed + 1))
  elif [ "${rc}" -eq 77 ]; then
    printf "  %sSKIP%s  %s\n" "${_CLR_YELLOW}" "${_CLR_RESET}" "${test_name}"
    skipped=$((skipped + 1))
  else
    printf "  %sFAIL%s  %s\n" "${_CLR_RED}" "${_CLR_RESET}" "${test_name}"
    failed=$((failed + 1))
    failures="${failures} ${test_name}"
  fi

  if [ -n "${output}" ]; then
    echo "${output}" | sed 's/^/        /'
  fi
done

echo ""
total=$((passed + failed + skipped))
if [ "${failed}" -gt 0 ]; then
  printf "%s%s tests: %s passed, %s failed, %s skipped%s\n" \
    "${_CLR_RED}" "${total}" "${passed}" "${failed}" "${skipped}" "${_CLR_RESET}"
  printf "%sFAILED:%s%s\n" "${_CLR_RED}" "${failures}" "${_CLR_RESET}"
  exit 1
else
  printf "%s%s tests: %s passed, %s failed, %s skipped%s\n" \
    "${_CLR_GREEN}" "${total}" "${passed}" "${failed}" "${skipped}" "${_CLR_RESET}"
fi

exit 0
