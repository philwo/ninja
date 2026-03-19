#!/bin/sh
# Run shellcheck on all e2e test scripts and helper scripts.
# Usage: ./e2etests/lint_tests.sh

set -e

# Find the e2etests directory (where this script lives)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

failed=0

# Lint top-level scripts
shellcheck "${SCRIPT_DIR}/run_tests.sh" "${SCRIPT_DIR}/test_helper.sh" || failed=1

# Lint each test script from its own directory so that shellcheck can
# resolve the `. "$(dirname "$0")/../test_helper.sh"` source line.
for test_script in "${SCRIPT_DIR}"/t*/test.sh; do
  [ -f "${test_script}" ] || continue
  test_dir="$(dirname "${test_script}")"
  (cd "${test_dir}" && shellcheck -x --source-path=.. test.sh) || failed=1
done

exit "${failed}"
