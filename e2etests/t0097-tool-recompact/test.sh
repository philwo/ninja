#!/bin/sh
# Test: -t recompact succeeds
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build out.txt: cp in.txt
EOF
echo "data" > in.txt

# Build first to create logs
run_ninja
assert_exit_success

run_ninja -t recompact
assert_exit_success
