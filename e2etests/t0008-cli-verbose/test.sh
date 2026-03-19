#!/bin/sh
# Test: -v shows full command lines
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
  description = COPY $out
build out.txt: cp in.txt
EOF
echo "data" > in.txt

run_ninja -v
assert_exit_success
assert_stdout_contains "cp in.txt out.txt"
