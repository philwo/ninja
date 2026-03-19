#!/bin/sh
# Test: phony target with no inputs always causes dependents to rebuild
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule touch
  command = touch $out
build always_dirty: phony
build out.txt: touch always_dirty
EOF

# First build
run_ninja
assert_exit_success
assert_file_exists out.txt
cp -p out.txt out.txt.ref

sleep 1

# Second build - should STILL rebuild because phony with no inputs
# is always considered dirty
run_ninja
assert_exit_success
assert_file_newer out.txt out.txt.ref

cp -p out.txt out.txt.ref

sleep 1

# Third build - same thing, always rebuilds
run_ninja
assert_exit_success
assert_file_newer out.txt out.txt.ref
