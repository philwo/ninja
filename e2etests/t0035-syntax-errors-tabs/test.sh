#!/bin/sh
# Test: tabs in build files produce error
. "$(dirname "$0")/../test_helper.sh"

# Ninja rejects tabs as indentation in certain contexts.
# A tab before a variable binding like "command = ..." is rejected
# with "expected 'command =' line" (the tab is not valid indentation).
# shellcheck disable=SC2016
printf 'rule cp\n\tcommand = cp $in $out\n' > build.ninja

run_ninja
assert_exit_failure
# The error may say "tabs are not allowed", "expected 'command =' line",
# or "unexpected whitespace" (n2).
assert_output_regex "tabs are not allowed|expected.*command|unexpected whitespace"
