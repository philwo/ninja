#!/bin/sh
# Test: -t targets depth N lists targets by depth
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build mid.txt: cp in.txt
build out.txt: cp mid.txt
EOF

# Depth 2 should show both out.txt and mid.txt
run_ninja -t targets depth 2
assert_exit_success
assert_stdout_contains "out.txt"
assert_stdout_contains "mid.txt"
