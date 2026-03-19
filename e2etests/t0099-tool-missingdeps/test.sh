#!/bin/sh
# Test: -t missingdeps checks for missing dependency edges
. "$(dirname "$0")/../test_helper.sh"

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

run_ninja -t missingdeps
assert_exit_success
