#!/bin/sh
# Test: depfile + deps = gcc workflow
. "$(dirname "$0")/../test_helper.sh"

# --- Baseline: without depfile, header changes are not detected ---

cat > build.ninja <<'EOF'
rule cc
  command = cp $in $out
build out.txt: cc in.txt
EOF
echo "source" > in.txt
echo "header" > header.h

run_ninja
assert_exit_success
assert_file_exists out.txt

# Modify header - should NOT trigger rebuild since ninja doesn't know about it
sleep 1
echo "modified_header" > header.h
run_ninja
assert_exit_success
assert_output_contains "no work to do"

# --- Clean up for next scenario ---
rm -f out.txt in.txt header.h .ninja_log .ninja_deps

# --- With depfile + deps = gcc: header changes ARE detected ---

cat > build.ninja <<'EOF'
rule cc
  command = cp $in $out && echo "$out: $in header.h" > $depfile
  depfile = $out.d
  deps = gcc
build out.txt: cc in.txt
EOF
echo "source" > in.txt
echo "header" > header.h

run_ninja
assert_exit_success
assert_file_exists out.txt
# Depfile should be consumed (deleted)
assert_file_not_exists out.txt.d

# Modify header - should trigger rebuild
sleep 1
echo "modified_header" > header.h
run_ninja
assert_exit_success
assert_stdout_not_contains "no work to do"
