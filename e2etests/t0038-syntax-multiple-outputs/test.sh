#!/bin/sh
# Test: multiple explicit outputs
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule gen
  command = echo a > a.txt && echo b > b.txt
build a.txt b.txt: gen
EOF

run_ninja
assert_exit_success
assert_file_exists a.txt
assert_file_exists b.txt
