#!/bin/sh
# Test: builddir moves .ninja_log to specified directory
. "$(dirname "$0")/../test_helper.sh"

# --- Baseline: without builddir, .ninja_log is in the root directory ---

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build out.txt: cp in.txt
EOF
echo "data" > in.txt

run_ninja
assert_exit_success
assert_file_exists out.txt
assert_file_exists .ninja_log

# --- Clean up for next scenario ---
rm -f out.txt .ninja_log .ninja_deps

# --- With builddir: .ninja_log moves to the specified directory ---

mkdir -p mybuilddir

cat > build.ninja <<'EOF'
builddir = mybuilddir
rule cp
  command = cp $in $out
build out.txt: cp in.txt
EOF

run_ninja
assert_exit_success
assert_file_exists out.txt
assert_file_exists mybuilddir/.ninja_log
