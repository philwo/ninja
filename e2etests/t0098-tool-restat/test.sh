#!/bin/sh
# Test: -t restat restats outputs in the build log
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build out.txt: cp in.txt
EOF
echo "data" > in.txt

run_ninja
assert_exit_success

# Touch the output to change its mtime
sleep 1
touch out.txt

# Restat should update the build log with new mtime
run_ninja -t restat
assert_exit_success
