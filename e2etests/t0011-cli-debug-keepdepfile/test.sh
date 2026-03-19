#!/bin/sh
# Test: -d keepdepfile preserves .d files after build
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cc
  command = cp $in $out && echo "$out: $in" > $out.d
  depfile = $out.d
  deps = gcc
build out.txt: cc in.txt
EOF
echo "data" > in.txt

run_ninja -d keepdepfile
assert_exit_success
assert_file_exists out.txt
assert_file_exists out.txt.d
