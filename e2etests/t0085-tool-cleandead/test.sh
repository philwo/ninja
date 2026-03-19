#!/bin/sh
# Test: -t cleandead removes files no longer in manifest
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build a.txt: cp in.txt
build b.txt: cp in.txt
EOF
echo "data" > in.txt

run_ninja
assert_exit_success
assert_file_exists a.txt
assert_file_exists b.txt

# Remove b.txt from the manifest
cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build a.txt: cp in.txt
EOF

run_ninja -t cleandead
assert_exit_success
# b.txt should be removed since it's no longer in the manifest
assert_file_not_exists b.txt
assert_file_exists a.txt
