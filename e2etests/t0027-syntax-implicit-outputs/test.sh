#!/bin/sh
# Test: Implicit outputs (build out | impl_out : rule)
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule gen
  command = echo main > $out && echo side > impl.txt
build out.txt | impl.txt: gen
EOF

run_ninja
assert_exit_success
assert_file_exists out.txt
assert_file_exists impl.txt
assert_file_contains out.txt "main"
assert_file_contains impl.txt "side"
