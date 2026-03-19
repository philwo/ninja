#!/bin/sh
# Test: .ninja_log is NOT removed by -t clean
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build out.txt: cp in.txt
EOF
echo "data" > in.txt

run_ninja
assert_exit_success
assert_file_exists .ninja_log

run_ninja -t clean
assert_exit_success
assert_file_not_exists out.txt
# .ninja_log must survive clean
assert_file_exists .ninja_log
