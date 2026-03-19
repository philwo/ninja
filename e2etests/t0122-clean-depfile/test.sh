#!/bin/sh
# Test: -t clean also removes depfiles alongside outputs
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cc
  command = cp $in $out && echo "$out: $in" > ${out}.d
  depfile = ${out}.d
  deps = gcc
build out.o: cc in.c
EOF
echo "source" > in.c

run_ninja
assert_exit_success
assert_file_exists out.o

# Clean all should remove both the output and the depfile
run_ninja -t clean
assert_exit_success
assert_file_not_exists out.o

# --- Clean target should also remove its depfile ---
run_ninja
assert_exit_success
assert_file_exists out.o

run_ninja -t clean out.o
assert_exit_success
assert_file_not_exists out.o

# --- Clean rule should also remove depfiles for that rule ---
run_ninja
assert_exit_success
assert_file_exists out.o

run_ninja -t clean -r cc
assert_exit_success
assert_file_not_exists out.o
