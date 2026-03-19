#!/bin/sh
# Test: rspfile + rspfile_content
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule link
  command = cat $out.rsp > $out
  rspfile = $out.rsp
  rspfile_content = contents_from_rsp
build out.txt: link
EOF

run_ninja
assert_exit_success
assert_file_exists out.txt
assert_file_contains out.txt "contents_from_rsp"
# Response file should be cleaned up after success (without -d keeprsp)
assert_file_not_exists out.txt.rsp
