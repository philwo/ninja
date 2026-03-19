#!/bin/sh
# Test: -t clean removes built files
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build a.txt: cp in.txt
build b.txt: cp in.txt
EOF
echo "data" > in.txt

run_ninja
assert_exit_success
assert_file_exists a.txt
assert_file_exists b.txt

run_ninja -t clean
assert_exit_success
assert_file_not_exists a.txt
assert_file_not_exists b.txt
# .ninja_log should be kept
assert_file_exists .ninja_log
