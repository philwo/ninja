#!/bin/sh
# Test: Error on missing explicit input
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build out.txt: cp nonexistent.txt
EOF

run_ninja
assert_exit_failure
assert_output_contains "nonexistent.txt"
