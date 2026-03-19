#!/bin/sh
# Test: .ninja_log creation and content
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build out.txt: cp in.txt
EOF
echo "data" > in.txt

run_ninja
assert_exit_success
assert_file_exists .ninja_log
# Log should contain the output path
assert_file_contains .ninja_log "out.txt"
