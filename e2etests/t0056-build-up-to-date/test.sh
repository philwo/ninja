#!/bin/sh
# Test: "no work to do" on second build
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build out.txt: cp in.txt
EOF
echo "data" > in.txt

run_ninja
assert_exit_success

run_ninja
assert_exit_success
assert_stdout_contains "no work to do"
assert_stdout_line_count 1
