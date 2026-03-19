#!/bin/sh
# Test: Rebuild on command change
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule gen
  command = echo version1 > $out
build out.txt: gen
EOF

run_ninja
assert_exit_success
assert_file_contains out.txt "version1"

# Change the command
cat > build.ninja <<'EOF'
rule gen
  command = echo version2 > $out
build out.txt: gen
EOF

run_ninja
assert_exit_success
assert_file_contains out.txt "version2"
