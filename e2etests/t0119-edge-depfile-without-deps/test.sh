#!/bin/sh
# Test: depfile without deps= binding
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cc
  command = cp $in $out && echo "$out: $in header.h" > $out.d
  depfile = $out.d
build out.txt: cc in.txt
EOF
echo "source" > in.txt
echo "header" > header.h

# Build should succeed
run_ninja
assert_exit_success
assert_file_exists out.txt

# Without deps=gcc, the depfile is NOT consumed (remains on disk)
# but the deps from it are still used for the next build
# Modify header - should trigger rebuild
sleep 1
echo "modified_header" > header.h
run_ninja
assert_exit_success
assert_stdout_not_contains "no work to do"
