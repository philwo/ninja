#!/bin/sh
# Test: missing subninja file produces error
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
subninja does_not_exist.ninja
EOF

run_ninja
assert_exit_failure
assert_output_contains "does_not_exist.ninja"
