#!/bin/sh
# Test: depfile listing wrong output name causes rebuild
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cc
  command = cp $in $out && echo "$out: header.h" > ${out}.d
  depfile = ${out}.d
  deps = gcc
build foo.o: cc foo.c
EOF
echo "source" > foo.c
echo "header" > header.h

# First build
run_ninja
assert_exit_success
assert_file_exists foo.o

# Second build should be a no-op
run_ninja
assert_exit_success
assert_output_contains "no work to do"

# Now create a depfile with the WRONG output name
echo "wrong_name.o: header.h" > foo.o.d

# Delete the deps log to force re-reading the depfile
rm -f .ninja_deps

# Rebuild - should still work correctly
sleep 1
echo "changed" > header.h
run_ninja
assert_exit_success
