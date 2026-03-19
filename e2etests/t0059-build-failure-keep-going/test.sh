#!/bin/sh
# Test: -k0 continues through failures
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule fail_cmd
  command = exit 1
rule pass
  command = echo ok > $out
build a.txt: fail_cmd
build b.txt: pass
default a.txt b.txt
EOF

run_ninja -j1 -k0
assert_exit_failure
# b.txt should still be built despite a.txt failing
assert_file_exists b.txt
