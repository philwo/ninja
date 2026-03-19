#!/bin/sh
# Test: # comments are ignored
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
# This is a comment
rule cp
  command = cp $in $out
# Another comment
build out.txt: cp in.txt
# Final comment
EOF
echo "data" > in.txt

run_ninja
assert_exit_success
assert_file_exists out.txt
assert_file_content_equals out.txt "data"
