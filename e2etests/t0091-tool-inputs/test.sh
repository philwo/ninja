#!/bin/sh
# Test: -t inputs lists all transitive inputs
. "$(dirname "$0")/../test_helper.sh"
skip_if_siso "-t tool not supported"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build mid.txt: cp src.txt
build out.txt: cp mid.txt
EOF

run_ninja -t inputs out.txt
assert_exit_success
assert_stdout_contains "src.txt"
assert_stdout_contains "mid.txt"
