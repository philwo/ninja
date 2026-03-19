#!/bin/sh
# Test: Rebuild on input change
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build out.txt: cp in.txt
EOF
echo "original" > in.txt

run_ninja
assert_exit_success
assert_file_content_equals out.txt "original"

sleep 1
echo "modified" > in.txt

run_ninja
assert_exit_success
assert_file_content_equals out.txt "modified"
