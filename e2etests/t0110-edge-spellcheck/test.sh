#!/bin/sh
# Test: Misspelled target suggests correction
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build output.txt: cp in.txt
EOF
echo "data" > in.txt

run_ninja outpu.txt
assert_exit_failure
assert_stderr_contains "did you mean 'output.txt'"
