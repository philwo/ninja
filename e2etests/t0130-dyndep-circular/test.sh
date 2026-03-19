#!/bin/sh
# Test: dyndep file creating a circular dependency produces error
. "$(dirname "$0")/../test_helper.sh"

# The dyndep file will add "out.txt" as an input to itself,
# creating a self-cycle.
cat > build.ninja <<'EOF'
rule touch
  command = touch $out
rule gen_dd
  command = printf 'ninja_dyndep_version = 1\nbuild out.txt: dyndep | out.txt\n' > $out
build dd.ninja: gen_dd
build out.txt: touch || dd.ninja
  dyndep = dd.ninja
EOF

run_ninja
assert_exit_failure
assert_output_contains "cycle"
