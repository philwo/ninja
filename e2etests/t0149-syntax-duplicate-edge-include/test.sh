#!/bin/sh
# Test: duplicate output across included files produces error
. "$(dirname "$0")/../test_helper.sh"

cat > child.ninja <<'EOF'
build out.txt: cp in.txt
EOF

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build out.txt: cp in.txt
include child.ninja
EOF
echo "data" > in.txt

run_ninja
assert_exit_failure
# Ninja says "multiple rules generate out.txt", n2 says "already an output"
assert_output_contains "out.txt"
