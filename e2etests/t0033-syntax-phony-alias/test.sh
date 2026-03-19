#!/bin/sh
# Test: phony as target alias
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build out.txt: cp in.txt
build alias: phony out.txt
EOF
echo "data" > in.txt

run_ninja alias
assert_exit_success
assert_file_exists out.txt
assert_file_content_equals out.txt "data"
