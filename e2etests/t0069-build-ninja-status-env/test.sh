#!/bin/sh
# Test: NINJA_STATUS format codes
. "$(dirname "$0")/../test_helper.sh"
skip_if_siso "NINJA_STATUS not supported"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build out.txt: cp in.txt
EOF
echo "data" > in.txt

NINJA_STATUS="[%f/%t] " run_ninja
assert_exit_success
assert_stdout_contains "[1/1]"
