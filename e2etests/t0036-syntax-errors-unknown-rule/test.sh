#!/bin/sh
# Test: unknown rule name produces error
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
build out.txt: nonexistent_rule in.txt
EOF

run_ninja
assert_exit_failure
# Ninja says "unknown build rule", n2 says "unknown rule"
assert_output_regex "unknown.*(build )?rule"
