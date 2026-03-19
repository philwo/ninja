#!/bin/sh
# Test: Build commands can create output directories
. "$(dirname "$0")/../test_helper.sh"

# Note: Ninja does NOT auto-create output directories.
# The command itself must handle directory creation.
# We use sh -c to avoid $ being interpreted as ninja variable.
cat > build.ninja <<'EOF'
rule mkcp
  command = mkdir -p subdir/deep && cp $in $out
build subdir/deep/out.txt: mkcp in.txt
EOF
echo "data" > in.txt

run_ninja
assert_exit_success
assert_file_exists subdir/deep/out.txt
