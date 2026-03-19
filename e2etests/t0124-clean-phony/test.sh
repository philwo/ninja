#!/bin/sh
# Test: -t clean does NOT remove phony target files
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build phony_target: phony real.txt
build real.txt: cp in.txt
EOF
echo "data" > in.txt

run_ninja
assert_exit_success
assert_file_exists real.txt

# Create a file named like the phony target
echo "should survive" > phony_target

# Clean should remove real.txt but NOT the phony_target file
run_ninja -t clean
assert_exit_success
assert_file_not_exists real.txt
assert_file_exists phony_target
assert_file_exists in.txt

# Also test CleanTarget on the phony target
run_ninja
assert_exit_success
assert_file_exists real.txt
echo "should survive" > phony_target

run_ninja -t clean phony_target
assert_exit_success
assert_file_not_exists real.txt
assert_file_exists phony_target
assert_file_exists in.txt
