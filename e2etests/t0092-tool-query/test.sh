#!/bin/sh
# Test: -t query shows inputs/outputs for a path
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build out.txt: cp in.txt
build final.txt: cp out.txt
EOF

run_ninja -t query out.txt
assert_exit_success
assert_stdout_contains "out.txt"
assert_stdout_contains "input"
assert_stdout_contains "output"
