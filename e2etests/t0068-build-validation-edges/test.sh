#!/bin/sh
# Test: |@ validations execute
. "$(dirname "$0")/../test_helper.sh"

# --- Baseline: without |@, validator target is not built ---

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
rule validate
  command = echo validated > $out
build out.txt: cp in.txt
build validation.stamp: validate in.txt
EOF
echo "data" > in.txt

run_ninja out.txt
assert_exit_success
assert_file_exists out.txt
# Without |@, validation.stamp should NOT be built
assert_file_not_exists validation.stamp

# --- Clean up for next scenario ---
rm -f out.txt validation.stamp .ninja_log .ninja_deps

# --- With |@: validation target IS built ---

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
rule validate
  command = echo validated > $out
build out.txt: cp in.txt |@ validation.stamp
build validation.stamp: validate in.txt
EOF

run_ninja
assert_exit_success
assert_file_exists out.txt
assert_file_exists validation.stamp
assert_file_contains validation.stamp "validated"
