#!/bin/sh
# Test: -t commands lists rebuild commands
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build mid.txt: cp in.txt
build out.txt: cp mid.txt
EOF
echo "data" > in.txt

run_ninja -t commands out.txt
assert_exit_success
assert_stdout_line_count 2
assert_stdout_contains "cp in.txt mid.txt"
assert_stdout_contains "cp mid.txt out.txt"
