#!/bin/sh
# Test: Explicit inputs appear in $in
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cat_inputs
  command = cat $in > $out
build out.txt: cat_inputs a.txt b.txt
EOF
echo "aaa" > a.txt
echo "bbb" > b.txt

run_ninja
assert_exit_success
assert_file_contains out.txt "aaa"
assert_file_contains out.txt "bbb"
