#!/bin/sh
# Test: $var and ${var} expansion
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
myvar = hello
rule write
  command = echo ${myvar} > $out
build out.txt: write
EOF

run_ninja
assert_exit_success
assert_file_contains out.txt "hello"
