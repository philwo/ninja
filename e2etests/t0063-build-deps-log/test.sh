#!/bin/sh
# Test: .ninja_deps creation with deps=gcc
. "$(dirname "$0")/../test_helper.sh"
skip_if_siso ".ninja_deps not used"

cat > build.ninja <<'EOF'
rule cc
  command = cp $in $out && echo "$out: $in" > $out.d
  depfile = $out.d
  deps = gcc
build out.txt: cc in.txt
EOF
echo "data" > in.txt

run_ninja
assert_exit_success
assert_file_exists .ninja_deps
