#!/bin/sh
# Test: -f custom.ninja loads alternate build file
. "$(dirname "$0")/../test_helper.sh"

cat > custom.ninja <<'EOF'
rule cp
  command = cp $in $out
build out.txt: cp in.txt
EOF
echo "custom" > in.txt

run_ninja -f custom.ninja
assert_exit_success
assert_file_exists out.txt
assert_file_content_equals out.txt "custom"
