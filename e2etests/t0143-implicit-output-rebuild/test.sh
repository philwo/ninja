#!/bin/sh
# Test: missing or out-of-date implicit output triggers rebuild
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule gen
  command = echo main > $out && echo side > side.txt
build out.txt | side.txt: gen in.txt
EOF
echo "data" > in.txt

# First build
run_ninja
assert_exit_success
assert_file_exists out.txt
assert_file_exists side.txt

# Second build should be a no-op
run_ninja
assert_exit_success
assert_output_contains "no work to do"

# Delete the implicit output - should trigger rebuild
rm side.txt
run_ninja
assert_exit_success
assert_file_exists side.txt
assert_stdout_not_contains "no work to do"

# Verify it's up to date now
run_ninja
assert_exit_success
assert_output_contains "no work to do"
