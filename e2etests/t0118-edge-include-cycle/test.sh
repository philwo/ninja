#!/bin/sh
# Test: Circular includes produce an error
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
include a.ninja
EOF

cat > a.ninja <<'EOF'
include build.ninja
EOF

run_ninja
assert_exit_failure
assert_output_contains "include cycle"
