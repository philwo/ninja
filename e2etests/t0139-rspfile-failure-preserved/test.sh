#!/bin/sh
# Test: response file is preserved on build failure for debugging
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule fail
  command = false
  rspfile = $out.rsp
  rspfile_content = some very long command content
build out.txt: fail in.txt
EOF
echo "data" > in.txt

run_ninja
assert_exit_failure

# The rspfile should be preserved after failure (not cleaned up)
assert_file_exists out.txt.rsp
assert_file_contains out.txt.rsp "some very long command content"
