#!/bin/sh
# Test: -t clean also removes response files alongside outputs
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule link
  command = cat $out.rsp > $out
  rspfile = $out.rsp
  rspfile_content = $in
build out.txt: link in.txt
EOF
echo "data" > in.txt

run_ninja
assert_exit_success
assert_file_exists out.txt

# Manually create the rspfile (ninja normally cleans it after success)
echo "in.txt" > out.txt.rsp

# Clean all should remove both the output and the rspfile
run_ninja -t clean
assert_exit_success
assert_file_not_exists out.txt
assert_file_not_exists out.txt.rsp
assert_file_exists in.txt
