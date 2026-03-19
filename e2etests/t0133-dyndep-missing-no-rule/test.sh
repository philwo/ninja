#!/bin/sh
# Test: missing dyndep file with no rule to build it produces error
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule touch
  command = touch $out
build out.txt: touch || dd.ninja
  dyndep = dd.ninja
EOF

# dd.ninja does not exist and has no build rule
run_ninja
assert_exit_failure
assert_output_contains "dd.ninja"
