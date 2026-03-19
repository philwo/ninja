#!/bin/sh
# Test: malformed dyndep file produces clear error
. "$(dirname "$0")/../test_helper.sh"

# Dyndep file missing the required version header
cat > build.ninja <<'EOF'
rule touch
  command = touch $out
rule gen_dd
  command = echo "build out.txt: dyndep" > $out
build dd.ninja: gen_dd
build out.txt: touch || dd.ninja
  dyndep = dd.ninja
EOF

run_ninja
assert_exit_failure
assert_output_contains "expected 'ninja_dyndep_version = ...'"
