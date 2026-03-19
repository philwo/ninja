#!/bin/sh
# Test: line continuation with $ at end of line
. "$(dirname "$0")/../test_helper.sh"

# Test line continuation in variable values and build statements
cat > build.ninja <<'EOF'
long_var = hello $
  world

rule echo_var
  command = echo $long_var > $out

build out.txt: echo_var
EOF

run_ninja
assert_exit_success
assert_file_exists out.txt
assert_file_contains out.txt "hello world"
