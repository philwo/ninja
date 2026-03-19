#!/bin/sh
# Test: Implicit inputs (|) trigger rebuild but are not in $in
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule write_in
  command = echo "$in" > $out
build out.txt: write_in a.txt | implicit.txt
EOF
echo "aaa" > a.txt
echo "imp" > implicit.txt

run_ninja
assert_exit_success
# $in should only contain explicit input
assert_file_contains out.txt "a.txt"

# Now modify implicit dep - should trigger rebuild
sleep 1
echo "modified" > implicit.txt
run_ninja
assert_exit_success
# Verify rebuild happened (not "no work to do")
assert_stdout_not_contains "no work to do"
