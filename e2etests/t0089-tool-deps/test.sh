#!/bin/sh
# Test: -t deps shows dependencies stored in deps log
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cc
  command = cp $in $out && echo "$out: $in header.h" > $out.d
  depfile = $out.d
  deps = gcc
build out.txt: cc in.txt
EOF
echo "data" > in.txt
echo "header" > header.h

# Build first to populate deps log
run_ninja
assert_exit_success

run_ninja -t deps out.txt
assert_exit_success
assert_stdout_contains "out.txt"
assert_stdout_contains "in.txt"
assert_stdout_contains "header.h"
