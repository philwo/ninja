#!/bin/sh
# Test: restat prevents downstream rebuild when output unchanged
. "$(dirname "$0")/../test_helper.sh"

# --- Baseline: without restat, downstream rebuilds even when output unchanged ---

cat > build.ninja <<'EOF'
rule gen
  command = echo static_content > $out
rule cp
  command = cp $in $out
build mid.txt: gen in.txt
build out.txt: cp mid.txt
EOF
echo "data" > in.txt

run_ninja
assert_exit_success
assert_file_exists mid.txt
assert_file_exists out.txt

cp -p out.txt out.txt.ref
sleep 1

# Touch input - gen reruns, and without restat downstream SHOULD rebuild
echo "different" > in.txt
run_ninja
assert_exit_success
assert_file_newer out.txt out.txt.ref

# --- Clean up for next scenario ---
rm -f mid.txt out.txt out.txt.ref in.txt .ninja_log .ninja_deps

# --- With restat: downstream does NOT rebuild when output unchanged ---

# Use a script that only updates mid.txt if the content changes
cat > build.ninja <<'EOF'
rule gen
  command = echo static_content > $out.tmp && if cmp -s $out.tmp $out; then rm $out.tmp; else mv $out.tmp $out; fi
  restat = 1
rule cp
  command = cp $in $out
build mid.txt: gen in.txt
build out.txt: cp mid.txt
EOF
echo "data" > in.txt

run_ninja
assert_exit_success
assert_file_exists mid.txt
assert_file_exists out.txt

cp -p out.txt out.txt.ref
sleep 1

# Touch input - gen reruns but produces same output, so downstream shouldn't rebuild
echo "different" > in.txt
run_ninja -d explain
assert_exit_success
# out.txt should NOT be rebuilt since mid.txt content didn't change
assert_file_not_newer out.txt out.txt.ref
