#!/bin/sh
# Test: -t commands -s prints only the final command
. "$(dirname "$0")/../test_helper.sh"
skip_if_siso "-t tool not supported"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build mid.txt: cp in.txt
build out.txt: cp mid.txt
EOF
echo "data" > in.txt

run_ninja -t commands -s out.txt
assert_exit_success
# Should only print the final command
assert_stdout_contains "cp mid.txt out.txt"
assert_stdout_not_contains "cp in.txt mid.txt"
