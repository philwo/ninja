#!/bin/sh
# Test: $$ escape becomes literal $
. "$(dirname "$0")/../test_helper.sh"

# Write a file whose content proves $$ -> $ expansion
cat > build.ninja <<'EOF'
rule write
  command = echo 'a$$b' > $out
build out.txt: write
EOF

run_ninja
assert_exit_success
# The command should have echo 'a$b' which produces a$b
# shellcheck disable=SC2016
assert_file_contains out.txt 'a$b'
