#!/bin/sh
# Test: Dynamic dependency discovery (dyndep)
. "$(dirname "$0")/../test_helper.sh"

# --- Baseline: without dyndep, undeclared dep changes are not detected ---

cat > build.ninja <<'EOF'
rule cat
  command = cat $in > $out
build out.txt: cat in.txt
EOF
echo "input_data" > in.txt
echo "dd_dep_data" > dd_dep.txt

run_ninja
assert_exit_success
assert_file_exists out.txt
assert_file_contains out.txt "input_data"

# Modifying dd_dep.txt should NOT trigger rebuild
sleep 1
echo "modified_dd_dep" > dd_dep.txt
run_ninja
assert_exit_success
assert_output_contains "no work to do"

# --- Clean up for next scenario ---
rm -f out.txt in.txt dd_dep.txt .ninja_log .ninja_deps

# --- With dyndep: dynamically discovered deps ARE detected ---

cat > build.ninja <<'EOF'
rule cat
  command = cat $in > $out
rule gendyndep
  command = echo "ninja_dyndep_version = 1" > $out && echo "build out.txt: dyndep | dd_dep.txt" >> $out
build dd.ninja: gendyndep
build out.txt: cat in.txt || dd.ninja
  dyndep = dd.ninja
EOF
echo "input_data" > in.txt
echo "dd_dep_data" > dd_dep.txt

run_ninja
assert_exit_success
assert_file_exists out.txt
assert_file_contains out.txt "input_data"

# Modifying the dyndep-discovered dep should trigger rebuild
sleep 1
echo "modified_dd_dep" > dd_dep.txt
run_ninja
assert_exit_success
assert_stdout_not_contains "no work to do"
