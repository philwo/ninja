#!/bin/sh
# Test: generator flag - no rebuild when command changes
. "$(dirname "$0")/../test_helper.sh"

# --- Baseline: without generator, command change triggers rebuild ---

cat > build.ninja <<'EOF'
rule gen
  command = echo v1 > $out
build out.txt: gen
EOF

run_ninja
assert_exit_success
assert_file_exists out.txt
assert_file_contains out.txt "v1"

# Change the command in the build file
cat > build.ninja <<'EOF'
rule gen
  command = echo v2 > $out
build out.txt: gen
EOF

# Without generator, this SHOULD rebuild
run_ninja
assert_exit_success
assert_stdout_not_contains "no work to do"
assert_file_contains out.txt "v2"

# --- Clean up for next scenario ---
rm -f out.txt .ninja_log .ninja_deps

# --- With generator: command change does NOT trigger rebuild ---

cat > build.ninja <<'EOF'
rule gen
  command = echo v1 > $out
  generator = 1
build out.txt: gen
EOF

run_ninja
assert_exit_success
assert_file_exists out.txt

# Change the command in the build file
cat > build.ninja <<'EOF'
rule gen
  command = echo v2 > $out
  generator = 1
build out.txt: gen
EOF

# Should NOT rebuild because generator flag is set
run_ninja
assert_exit_success
assert_output_contains "no work to do"
# Content should still be v1
assert_file_contains out.txt "v1"
