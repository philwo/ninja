#!/bin/sh
# Test: console pool behavior (depth=1)
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule interactive
  command = echo interactive_output > $out
  pool = console
build out.txt: interactive
EOF

run_ninja
assert_exit_success
assert_file_exists out.txt
assert_file_contains out.txt "interactive_output"
