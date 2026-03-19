#!/bin/sh
# Test: default target specification
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build a.txt: cp in.txt
build b.txt: cp in.txt
default a.txt
EOF
echo "data" > in.txt

run_ninja
assert_exit_success
assert_file_exists a.txt
# b.txt should NOT be built since it's not default
assert_file_not_exists b.txt
