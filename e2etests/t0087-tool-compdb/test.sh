#!/bin/sh
# Test: -t compdb outputs JSON compilation database
. "$(dirname "$0")/../test_helper.sh"
skip_if_siso "-t tool not supported"

cat > build.ninja <<'EOF'
rule cc
  command = cc -c $in -o $out
build out.o: cc in.c
EOF

run_ninja -t compdb cc
assert_exit_success
assert_stdout_contains '"command"'
assert_stdout_contains '"file"'
assert_stdout_contains '"directory"'
assert_stdout_contains "in.c"
