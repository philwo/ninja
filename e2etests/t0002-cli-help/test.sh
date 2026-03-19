#!/bin/sh
# Test: -h prints usage to stderr and exits 1
. "$(dirname "$0")/../test_helper.sh"
skip_if_siso "-h output differs"

run_ninja -h
assert_exit_code 1
assert_stderr_contains "usage: ninja"
assert_stderr_contains "--version"
assert_stderr_contains "-C DIR"
