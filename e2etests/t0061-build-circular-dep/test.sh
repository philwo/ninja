#!/bin/sh
# Test: Cycle detection
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build a.txt: cp b.txt
build b.txt: cp a.txt
default a.txt
EOF

run_ninja
assert_exit_failure
assert_output_regex "dependency cycle|could not determine root nodes"
