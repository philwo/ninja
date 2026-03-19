#!/bin/sh
# Test: include shares parent scope
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
myvar = from_parent
include included.ninja
EOF

cat > included.ninja <<'EOF'
rule write
  command = echo $myvar > $out
build out.txt: write
EOF

run_ninja
assert_exit_success
assert_file_contains out.txt "from_parent"
