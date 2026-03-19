#!/bin/sh
# Test: -t clean handles depfiles and rspfiles with spaces in paths
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cc_dep
  command = cp $in $out && echo "$out: $in" > ${out}.d
  depfile = ${out}.d
rule cc_rsp
  command = cat $out.rsp > $out
  rspfile = ${out}.rsp
  rspfile_content = $in
build out$ 1.txt: cc_dep in.txt
build out$ 2.txt: cc_rsp in.txt
EOF
echo "data" > in.txt

run_ninja
assert_exit_success
assert_file_exists "out 1.txt"
assert_file_exists "out 2.txt"

# Manually create the rspfile and depfile (they may have been cleaned up)
echo "in.txt" > "out 2.txt.rsp"
echo "out 1.txt: in.txt" > "out 1.txt.d"

# Clean should remove outputs and their associated depfiles/rspfiles
run_ninja -t clean
assert_exit_success
assert_file_not_exists "out 1.txt"
assert_file_not_exists "out 1.txt.d"
assert_file_not_exists "out 2.txt"
assert_file_not_exists "out 2.txt.rsp"
