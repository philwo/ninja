#!/bin/sh
# Test: File-level, rule-level, and build-level variable scoping
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
myvar = file_level
rule write
  command = echo $myvar > $out
build out.txt: write
  myvar = build_level
EOF

run_ninja
assert_exit_success
# Build-level binding should override file-level
assert_file_contains out.txt "build_level"
