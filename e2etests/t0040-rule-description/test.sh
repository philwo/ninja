#!/bin/sh
# Test: description is shown instead of command
. "$(dirname "$0")/../test_helper.sh"

# --- Baseline: without description, the raw command is shown ---

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build out.txt: cp in.txt
EOF
echo "data" > in.txt

run_ninja
assert_exit_success
# Without a description, the raw command SHOULD be shown
assert_stdout_contains "cp in.txt out.txt"

# --- Clean up for next scenario ---
rm -f out.txt .ninja_log .ninja_deps

# --- With description: description is shown instead of command ---

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
  description = COPY $in -> $out
build out.txt: cp in.txt
EOF

run_ninja
assert_exit_success
assert_stdout_contains "COPY in.txt -> out.txt"
# Without -v, the raw command should not be shown
assert_stdout_not_contains "cp in.txt out.txt"
