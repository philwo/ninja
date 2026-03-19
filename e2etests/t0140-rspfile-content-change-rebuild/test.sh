#!/bin/sh
# Test: changing rspfile_content triggers rebuild
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule link
  command = cat $out.rsp > $out
  rspfile = $out.rsp
  rspfile_content = original_content
build out.txt: link in.txt
EOF
echo "data" > in.txt

# First build
run_ninja
assert_exit_success
assert_file_exists out.txt
assert_file_contains out.txt "original_content"

# Second build with no changes - should be up to date
run_ninja
assert_exit_success
assert_output_contains "no work to do"

# Change rspfile_content - should trigger rebuild
cat > build.ninja <<'EOF'
rule link
  command = cat $out.rsp > $out
  rspfile = $out.rsp
  rspfile_content = changed_content
build out.txt: link in.txt
EOF

run_ninja
assert_exit_success
assert_file_contains out.txt "changed_content"
