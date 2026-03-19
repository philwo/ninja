#!/bin/sh
# Test: validation edge that depends on the build output
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
rule check
  command = test -f $in && echo ok > $out
build out.txt: cp in.txt |@ validate.stamp
build validate.stamp: check out.txt
EOF
echo "data" > in.txt

# First build: both out.txt and validate.stamp should be built
run_ninja
assert_exit_success
assert_file_exists out.txt
assert_file_exists validate.stamp

# Touching only in.txt should rebuild both out.txt and validate.stamp
# (validate depends on out.txt via implicit dep)
sleep 1
echo "changed" > in.txt
cp -p validate.stamp validate.stamp.ref
run_ninja
assert_exit_success
assert_file_contains out.txt "changed"
assert_file_newer validate.stamp validate.stamp.ref
