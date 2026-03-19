#!/bin/sh
# Test: -t list shows all tools
. "$(dirname "$0")/../test_helper.sh"

run_ninja -t list
assert_exit_success
# Header line + 16 tools = 17 lines
assert_stdout_line_count 17
assert_stdout_contains "clean"
assert_stdout_contains "commands"
assert_stdout_contains "deps"
assert_stdout_contains "graph"
assert_stdout_contains "query"
assert_stdout_contains "targets"
assert_stdout_contains "compdb"
assert_stdout_contains "rules"
assert_stdout_contains "cleandead"
assert_stdout_contains "recompact"
assert_stdout_contains "restat"
assert_stdout_contains "inputs"
assert_stdout_contains "missingdeps"
