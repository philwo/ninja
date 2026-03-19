#!/bin/sh
# Test: -w phonycycle=err vs =warn
. "$(dirname "$0")/../test_helper.sh"

# Phony self-reference as default target so the cycle is actually visited
cat > build.ninja <<'EOF'
build a: phony a
default a
EOF

# Warn mode: the self-reference is removed, build succeeds
run_ninja -w phonycycle=warn
assert_exit_success
assert_stderr_contains "phony target"

# Error mode: self-reference is kept, cycle is detected during build
rm -f .ninja_log .ninja_deps
run_ninja -w phonycycle=err
assert_exit_failure
