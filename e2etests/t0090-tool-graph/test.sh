#!/bin/sh
# Test: -t graph outputs graphviz dot format
. "$(dirname "$0")/../test_helper.sh"
skip_if_siso "-t tool not supported"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build out.txt: cp in.txt
EOF

run_ninja -t graph out.txt
assert_exit_success
assert_stdout_contains "digraph"
assert_stdout_contains "out.txt"
assert_stdout_contains "in.txt"
