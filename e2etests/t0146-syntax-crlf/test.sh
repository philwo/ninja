#!/bin/sh
# Test: build.ninja with CRLF line endings works correctly
. "$(dirname "$0")/../test_helper.sh"

# Write a build.ninja with \r\n line endings using a heredoc + sed
cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build out.txt: cp in.txt
EOF
sed -i 's/$/\r/' build.ninja
echo "data" > in.txt

run_ninja
assert_exit_success
assert_file_exists out.txt
assert_file_content_equals out.txt "data"
