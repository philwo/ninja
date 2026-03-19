#!/bin/sh
# Test: -t rules lists rules
. "$(dirname "$0")/../test_helper.sh"
skip_if_siso "-t tool not supported"

cat > build.ninja <<'EOF'
rule compile
  command = cc -c $in -o $out
  description = Compile $in
rule link
  command = cc $in -o $out
  description = Link $out
build a.o: compile a.c
build prog: link a.o
EOF

run_ninja -t rules
assert_exit_success
# compile + link + phony = 3 lines
assert_stdout_line_count 3
assert_stdout_contains "compile"
assert_stdout_contains "link"

# With -d flag, descriptions should be shown
run_ninja -t rules -d
assert_exit_success
assert_stdout_line_count 3
assert_stdout_contains "Compile"
assert_stdout_contains "Link"
