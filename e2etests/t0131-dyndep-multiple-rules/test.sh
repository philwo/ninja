#!/bin/sh
# Test: dyndep file discovering output already claimed by another edge is an error
. "$(dirname "$0")/../test_helper.sh"

# out1 already produces "shared.imp" as an implicit output.
# The dyndep file for out2 will also try to claim "shared.imp".
cat > build.ninja <<'EOF'
rule touch
  command = touch $out
build shared.imp: touch
build dd.ninja: touch
build out.txt: touch || dd.ninja
  dyndep = dd.ninja
EOF

cat > dd.ninja <<'EOF'
ninja_dyndep_version = 1
build out.txt | shared.imp: dyndep
EOF

run_ninja
assert_exit_failure
assert_output_contains "multiple rules generate shared.imp"
