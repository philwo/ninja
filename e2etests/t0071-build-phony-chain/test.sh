#!/bin/sh
# Test: Chain of phony aliases
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build out.txt: cp in.txt
build alias1: phony out.txt
build alias2: phony alias1
EOF
echo "data" > in.txt

run_ninja alias2
assert_exit_success
assert_file_exists out.txt
assert_file_content_equals out.txt "data"
