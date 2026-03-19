#!/bin/sh
# Test: -t compdb-targets for specific targets
. "$(dirname "$0")/../test_helper.sh"
skip_if_siso "-t tool not supported"

cat > build.ninja <<'EOF'
rule cc
  command = cc -c $in -o $out
build a.o: cc a.c
build b.o: cc b.c
EOF

run_ninja -t compdb-targets a.o
assert_exit_success
assert_stdout_contains "a.c"
# b.c should not be in the output for target a.o
assert_stdout_not_contains "b.c"
