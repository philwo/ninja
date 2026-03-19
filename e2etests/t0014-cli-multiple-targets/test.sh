#!/bin/sh
# Test: Building specific targets by name
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build a.txt: cp in.txt
build b.txt: cp in.txt
build c.txt: cp in.txt
EOF
echo "data" > in.txt

# Build only a.txt and c.txt
run_ninja a.txt c.txt
assert_exit_success
assert_file_exists a.txt
assert_file_not_exists b.txt
assert_file_exists c.txt
