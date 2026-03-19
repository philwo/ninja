#!/bin/sh
# Test: -t targets all lists all targets
. "$(dirname "$0")/../test_helper.sh"
skip_if_siso "-t tool not supported"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build a.txt: cp in.txt
build b.txt: cp in.txt
EOF

run_ninja -t targets all
assert_exit_success
assert_stdout_contains "a.txt"
assert_stdout_contains "b.txt"
