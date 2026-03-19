#!/bin/sh
# Test: Phony self-reference with default (warn) succeeds
. "$(dirname "$0")/../test_helper.sh"
# Need a real target as default so build has work to do
cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build out.txt: cp in.txt
build a: phony a
default out.txt
EOF
echo "data" > in.txt

run_ninja -w phonycycle=warn
assert_exit_success
# Warning should be printed
assert_stderr_contains "phony target"
