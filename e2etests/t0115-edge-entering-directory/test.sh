#!/bin/sh
# Test: -C dir prints "Entering directory" message
. "$(dirname "$0")/../test_helper.sh"

mkdir subdir
cat > subdir/build.ninja <<'EOF'
rule cp
  command = cp $in $out
build out.txt: cp in.txt
EOF
echo "data" > subdir/in.txt

run_ninja -C subdir
assert_exit_success
assert_output_contains "Entering directory"
