#!/bin/sh
# Test: Order-only deps (||) don't trigger rebuild of dependent
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build out.txt: cp in.txt || order_dep.txt
EOF
echo "in_data" > in.txt
echo "order_data" > order_dep.txt

# First build
run_ninja
assert_exit_success
assert_file_exists out.txt

# Modify order-only dep - should NOT trigger rebuild of out.txt
sleep 1
echo "modified_order" > order_dep.txt
run_ninja out.txt
assert_exit_success
assert_output_contains "no work to do"
