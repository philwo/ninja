#!/bin/sh
# Test: -k2 continues past first failure
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule pass
  command = echo ok > $out
rule fail_cmd
  command = false
build a.txt: fail_cmd
build b.txt: pass
build c.txt: fail_cmd
EOF

run_ninja -j1 -k2
assert_exit_failure
# b.txt should still have been built despite a.txt failing
assert_file_exists b.txt
