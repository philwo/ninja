#!/bin/sh
# Test: -t targets rule R lists outputs of rule R
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule compile
  command = cp $in $out
rule link
  command = cp $in $out
build a.o: compile a.c
build b.o: compile b.c
build prog: link a.o b.o
EOF

run_ninja -t targets rule compile
assert_exit_success
assert_stdout_contains "a.o"
assert_stdout_contains "b.o"
assert_stdout_not_contains "prog"
