#!/bin/sh
# Test: Empty build file, nothing to do
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
EOF

run_ninja
assert_exit_success
assert_stdout_contains "no work to do"
assert_stdout_line_count 1
