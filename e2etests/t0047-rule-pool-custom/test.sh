#!/bin/sh
# Test: Custom pool limiting parallelism
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
pool serial
  depth = 1
rule write
  command = echo $out > $out
  pool = serial
build a.txt: write
build b.txt: write
build c.txt: write
EOF

# Even with -j8, the pool limits to depth 1
run_ninja -j8
assert_exit_success
assert_file_exists a.txt
assert_file_exists b.txt
assert_file_exists c.txt
