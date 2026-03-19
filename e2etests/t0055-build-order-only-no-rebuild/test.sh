#!/bin/sh
# Test: order-only dep change doesn't trigger rebuild (but implicit dep does)
. "$(dirname "$0")/../test_helper.sh"

# --- Baseline: implicit dep (|) change DOES trigger rebuild ---

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build out.txt: cp in.txt | regular_dep.txt
EOF
echo "data" > in.txt
echo "dep_data" > regular_dep.txt

run_ninja
assert_exit_success
assert_file_exists out.txt

sleep 1
echo "changed_dep" > regular_dep.txt

# With an implicit dep, this SHOULD rebuild
run_ninja
assert_exit_success
assert_stdout_not_contains "no work to do"

# --- Clean up for next scenario ---
rm -f out.txt in.txt regular_dep.txt .ninja_log .ninja_deps

# --- With order-only dep (||): change does NOT trigger rebuild ---

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build out.txt: cp in.txt || order_dep.txt
EOF
echo "data" > in.txt
echo "order" > order_dep.txt

run_ninja
assert_exit_success

sleep 1
echo "changed_order" > order_dep.txt

run_ninja
assert_exit_success
assert_output_contains "no work to do"
