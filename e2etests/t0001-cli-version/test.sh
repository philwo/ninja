#!/bin/sh
# Test: --version prints version and exits 0
. "$(dirname "$0")/../test_helper.sh"

run_ninja --version
assert_exit_success
assert_stdout_line_count 1
assert_stdout_regex '^[0-9]+\.[0-9]+'
