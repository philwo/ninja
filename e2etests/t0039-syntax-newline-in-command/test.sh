#!/bin/sh
# Test: $\n line continuation in variable values
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
long_var = hello $
  world
rule write
  command = echo $long_var > $out
build out.txt: write
EOF

run_ninja
assert_exit_success
assert_file_contains out.txt "hello"
assert_file_contains out.txt "world"
