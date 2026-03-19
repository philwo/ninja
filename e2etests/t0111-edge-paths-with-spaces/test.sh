#!/bin/sh
# Test: Escaped spaces in paths
. "$(dirname "$0")/../test_helper.sh"

# In ninja, spaces in filenames are escaped with "$ "
# The command needs to handle the spaces properly
cat > build.ninja <<'EOF'
rule cp
  command = cp "my input.txt" "my output.txt"
build my$ output.txt: cp my$ input.txt
EOF
echo "space data" > "my input.txt"

run_ninja
assert_exit_success
assert_file_exists "my output.txt"
assert_file_content_equals "my output.txt" "space data"
