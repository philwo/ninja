#!/bin/sh
# Test: Phony self-reference with -w phonycycle=err fails
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
build a: phony a
EOF

run_ninja -w phonycycle=err
assert_exit_failure
