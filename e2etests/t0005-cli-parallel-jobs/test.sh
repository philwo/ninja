#!/bin/sh
# Test: -j1 forces serial execution (outputs appear in order)
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule echo_to_file
  command = echo $msg > $out
build a.txt: echo_to_file
  msg = alpha
build b.txt: echo_to_file
  msg = bravo
build c.txt: echo_to_file
  msg = charlie
EOF

run_ninja -j1
assert_exit_success
assert_file_exists a.txt
assert_file_exists b.txt
assert_file_exists c.txt
