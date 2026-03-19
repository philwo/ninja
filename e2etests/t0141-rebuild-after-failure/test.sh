#!/bin/sh
# Test: rebuilding after a previous failure succeeds
. "$(dirname "$0")/../test_helper.sh"

# Use a command that will fail if "should_fail" file exists
cat > build.ninja <<'EOF'
rule maybe_fail
  command = test ! -f should_fail && cp $in $out
build out.txt: maybe_fail in.txt
EOF
echo "data" > in.txt

# First build - will fail
touch should_fail
run_ninja
assert_exit_failure
assert_file_not_exists out.txt

# Fix the issue and rebuild - should succeed
rm should_fail
run_ninja
assert_exit_success
assert_file_exists out.txt
assert_file_content_equals out.txt "data"
