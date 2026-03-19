#!/bin/sh
# Test: -C dir builds in specified directory
. "$(dirname "$0")/../test_helper.sh"

mkdir subdir
cat > subdir/build.ninja <<'EOF'
rule cp
  command = cp $in $out
build out.txt: cp in.txt
EOF
echo "hello" > subdir/in.txt

run_ninja -C subdir
assert_exit_success
assert_file_exists subdir/out.txt
assert_file_content_equals subdir/out.txt "hello"
