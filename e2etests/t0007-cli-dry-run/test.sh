#!/bin/sh
# Test: -n shows commands but doesn't execute
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build out.txt: cp in.txt
EOF
echo "data" > in.txt

run_ninja -n
assert_exit_success
# Output file should NOT be created in dry run
assert_file_not_exists out.txt
