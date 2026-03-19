#!/bin/sh
# Test: -t clean target on multi-output edge cleans all outputs of that edge
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule gen
  command = echo a > ${out1} && echo b > ${out2}
build a.txt | b.txt: gen in.txt
  out1 = a.txt
  out2 = b.txt
build c.txt: gen in.txt
  out1 = c.txt
  out2 = c.txt
EOF
echo "data" > in.txt

run_ninja
assert_exit_success
assert_file_exists a.txt
assert_file_exists b.txt
assert_file_exists c.txt

# Cleaning a.txt should also clean b.txt (same edge), but not c.txt
run_ninja -t clean a.txt
assert_exit_success
assert_file_not_exists a.txt
assert_file_not_exists b.txt
assert_file_exists c.txt
assert_file_exists in.txt
