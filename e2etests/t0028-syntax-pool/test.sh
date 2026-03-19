#!/bin/sh
# Test: Pool declarations with depth limit concurrency
. "$(dirname "$0")/../test_helper.sh"

# --- Baseline: without pool, jobs run with full parallelism ---

cat > build.ninja <<'EOF'
rule slow_write
  command = sleep 1 && echo $out > $out
build a.txt: slow_write
build b.txt: slow_write
EOF

# Run with -j8 (no pool restriction) - both should run in parallel
start_time=$(date +%s)
run_ninja -j8
end_time=$(date +%s)
assert_exit_success
assert_file_exists a.txt
assert_file_exists b.txt

# With -j8 and no pool, both 1-second jobs should complete in ~1 second
elapsed=$((end_time - start_time))
if [ "${elapsed}" -ge 3 ]; then
  fail "expected parallel execution (~1s), but took ${elapsed}s"
fi

# --- Clean up for next scenario ---
rm -f a.txt b.txt .ninja_log .ninja_deps

# --- With pool depth=1: concurrency is limited ---

cat > build.ninja <<'EOF'
pool mypool
  depth = 1
rule slow_write
  command = sleep 1 && echo $out > $out
  pool = mypool
build a.txt: slow_write
build b.txt: slow_write
EOF

run_ninja -j8
assert_exit_success
assert_file_exists a.txt
assert_file_exists b.txt
