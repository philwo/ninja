#!/bin/sh
# Test: Deep dependency chain executes all steps in order
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build s1.txt: cp in.txt
build s2.txt: cp s1.txt
build s3.txt: cp s2.txt
build s4.txt: cp s3.txt
build s5.txt: cp s4.txt
build s6.txt: cp s5.txt
build s7.txt: cp s6.txt
build s8.txt: cp s7.txt
build s9.txt: cp s8.txt
build s10.txt: cp s9.txt
EOF
echo "chain_data" > in.txt

run_ninja s10.txt
assert_exit_success
assert_file_exists s10.txt
assert_file_content_equals s10.txt "chain_data"
