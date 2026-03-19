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

# Manually create the depfile (ninja/siso may consume it after build)
echo "out.o: in.c" > out.o.d

# Clean all should remove both the output and the depfile
run_ninja -t clean
assert_exit_success
assert_file_not_exists out.o
assert_file_not_exists out.o.d
assert_file_exists in.c

# --- Clean target should also remove its depfile ---
run_ninja
assert_exit_success
assert_file_exists out.o
echo "out.o: in.c" > out.o.d

run_ninja -t clean out.o
assert_exit_success
assert_file_not_exists out.o
assert_file_not_exists out.o.d
assert_file_exists in.c

# --- Clean rule should also remove depfiles for that rule ---
run_ninja
assert_exit_success
assert_file_exists out.o
echo "out.o: in.c" > out.o.d

run_ninja -t clean -r cc
assert_exit_success
assert_file_not_exists out.o
assert_file_not_exists out.o.d
assert_file_exists in.c
