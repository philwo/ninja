#!/bin/sh
# Test: Same output in two build statements produces error
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build out.txt: cp a.txt
build out.txt: cp b.txt
EOF

run_ninja
assert_exit_failure
# Ninja says "multiple rules generate", n2 says "already an output"
assert_output_regex "multiple rules generate|already an output"
