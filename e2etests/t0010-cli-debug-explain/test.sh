#!/bin/sh
# Test: -d explain shows rebuild reasons
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build out.txt: cp in.txt
EOF
echo "data" > in.txt

# First build
run_ninja
assert_exit_success

# Modify input
sleep 1
echo "modified" > in.txt

# Rebuild with explain - ninja prints explanation to stderr
run_ninja -d explain
assert_exit_success
assert_output_regex "older than|is dirty|explain"
