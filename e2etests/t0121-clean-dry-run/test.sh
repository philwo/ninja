#!/bin/sh
# Test: -n -t clean (dry run) reports files but does not delete them
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build a.txt: cp in.txt
build b.txt: cp in.txt
EOF
echo "data" > in.txt

run_ninja
assert_exit_success
assert_file_exists a.txt
assert_file_exists b.txt

# Dry-run clean should report what it would remove
run_ninja -n -t clean
assert_exit_success
assert_stdout_contains "a.txt"
assert_stdout_contains "b.txt"

# But files should still exist
assert_file_exists a.txt
assert_file_exists b.txt
