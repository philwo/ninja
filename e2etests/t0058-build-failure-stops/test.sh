#!/bin/sh
# Test: Build stops on failure (default -k1) but -k0 continues
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule fail_cmd
  command = false
rule pass
  command = echo ok > $out
build a.txt: fail_cmd
build b.txt: pass
default a.txt b.txt
EOF

# --- Baseline: default -k1 stops after first failure ---

run_ninja -j1
assert_exit_failure
# b.txt should NOT be built because ninja stopped after a.txt failed
assert_file_not_exists b.txt

# --- With -k0: continues past failures ---

run_ninja -j1 -k0
assert_exit_failure
# b.txt SHOULD be built this time despite a.txt failing
assert_file_exists b.txt
