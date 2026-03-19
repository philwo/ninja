#!/bin/sh
# Test: phony target with real inputs propagates rebuild when input changes
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule touch
  command = touch $out
build alias: phony real.txt
build out.txt: touch alias
EOF
echo "data" > real.txt

# First build
run_ninja
assert_exit_success
assert_file_exists out.txt

# Second build with no changes - should be up to date
# (phony with inputs is clean when inputs haven't changed)
run_ninja
assert_exit_success
assert_output_contains "no work to do"

# Touch the real input - should cause rebuild through the phony alias
sleep 1
cp -p out.txt out.txt.ref
echo "changed" > real.txt
run_ninja
assert_exit_success
assert_file_newer out.txt out.txt.ref
