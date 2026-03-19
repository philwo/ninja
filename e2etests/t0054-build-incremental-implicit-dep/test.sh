#!/bin/sh
# Test: Implicit dep change triggers rebuild
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build out.txt: cp in.txt | implicit_dep.txt
EOF
echo "data" > in.txt
echo "dep" > implicit_dep.txt

run_ninja
assert_exit_success
assert_file_exists out.txt

sleep 1
echo "changed_dep" > implicit_dep.txt

run_ninja
assert_exit_success
assert_stdout_not_contains "no work to do"
