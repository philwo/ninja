#!/bin/sh
# Test: -t multi-inputs prints input sets
. "$(dirname "$0")/../test_helper.sh"
skip_if_siso "-t tool not supported"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build out.txt: cp a.txt b.txt
EOF

run_ninja -t multi-inputs out.txt
assert_exit_success
assert_stdout_contains "a.txt"
assert_stdout_contains "b.txt"
