#!/bin/sh
# Test: -t clean -g removes generator outputs too
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule gen
  command = echo generated > $out
  generator = 1
rule cp
  command = cp $in $out
build gen.txt: gen
build out.txt: cp in.txt
EOF
echo "data" > in.txt

run_ninja
assert_exit_success
assert_file_exists gen.txt
assert_file_exists out.txt

# Without -g, generator outputs are kept
run_ninja -t clean
assert_exit_success
assert_file_exists gen.txt
assert_file_not_exists out.txt

# Rebuild out.txt
run_ninja
assert_exit_success

# With -g, generator outputs are also removed
run_ninja -t clean -g
assert_exit_success
assert_file_not_exists gen.txt
assert_file_not_exists out.txt
