#!/bin/sh
# Test: mutual validation edges are allowed (not a cycle)
. "$(dirname "$0")/../test_helper.sh"

# out1 validates out2 and out2 validates out1.
# This is allowed because validation edges don't form real dependencies.
cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build out1.txt: cp in1.txt |@ out2.txt
build out2.txt: cp in2.txt |@ out1.txt
EOF
echo "data1" > in1.txt
echo "data2" > in2.txt

run_ninja
assert_exit_success
assert_file_exists out1.txt
assert_file_exists out2.txt
assert_file_content_equals out1.txt "data1"
assert_file_content_equals out2.txt "data2"

# Touching only in1.txt should rebuild only out1.txt
sleep 1
echo "changed1" > in1.txt
cp -p out2.txt out2.txt.ref
run_ninja
assert_exit_success
assert_file_content_equals out1.txt "changed1"
assert_file_not_newer out2.txt out2.txt.ref
