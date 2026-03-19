#!/bin/sh
# Test: -d keeprsp preserves response files after build
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule link
  command = cat $out.rsp > $out
  rspfile = $out.rsp
  rspfile_content = $in
build out.txt: link in.txt
EOF
echo "data" > in.txt

run_ninja -d keeprsp
assert_exit_success
assert_file_exists out.txt
assert_file_exists out.txt.rsp
