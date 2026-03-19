#!/bin/sh
# Test: --quiet suppresses progress status
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build out.txt: cp in.txt
EOF
echo "data" > in.txt

# --- Baseline: without --quiet, progress is shown ---

run_ninja
assert_exit_success
assert_file_exists out.txt
# Without --quiet, progress SHOULD appear
assert_stdout_contains "1/1"

# --- Clean up for next scenario ---
rm -f out.txt .ninja_log .ninja_deps

# --- With --quiet: progress is suppressed ---

run_ninja --quiet
assert_exit_success
assert_file_exists out.txt
# Progress like [1/1] should not appear; stdout should be completely empty
assert_stdout_not_contains "[1/1]"
assert_stdout_line_count 0
