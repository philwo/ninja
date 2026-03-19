#!/bin/sh
# Test: Rule producing multiple outputs
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule gen_both
  command = echo a > a.txt && echo b > b.txt
build a.txt b.txt: gen_both in.txt
EOF
echo "data" > in.txt

run_ninja
assert_exit_success
assert_file_exists a.txt
assert_file_exists b.txt
assert_file_contains a.txt "a"
assert_file_contains b.txt "b"
