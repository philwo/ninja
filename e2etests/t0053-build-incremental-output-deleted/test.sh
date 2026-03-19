#!/bin/sh
# Test: Rebuild when output is deleted or modified externally
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build out.txt: cp in.txt
EOF
echo "data" > in.txt

run_ninja
assert_exit_success
assert_file_exists out.txt

# --- Output deleted: ninja recreates it ---

rm out.txt

run_ninja
assert_exit_success
assert_file_exists out.txt
assert_file_content_equals out.txt "data"

# --- Output modified externally: ninja should restore it ---

sleep 1
echo "corrupted" > out.txt

run_ninja
assert_exit_success
assert_file_content_equals out.txt "data"
