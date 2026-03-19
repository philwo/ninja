#!/bin/sh
# Test: Restat in multi-step chain - only necessary steps rebuild
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule gen
  command = echo static > $out.tmp && if cmp -s $out.tmp $out; then rm $out.tmp; else mv $out.tmp $out; fi
  restat = 1
rule cp
  command = cp $in $out
build step1.txt: gen in.txt
build step2.txt: cp step1.txt
build step3.txt: cp step2.txt
EOF
echo "data" > in.txt

# First build
run_ninja
assert_exit_success
assert_file_exists step1.txt
assert_file_exists step2.txt
assert_file_exists step3.txt

cp -p step3.txt step3.txt.ref
sleep 1

# Modify input - gen reruns but produces same output, so step2/3 shouldn't rebuild
echo "different" > in.txt
run_ninja
assert_exit_success
assert_file_not_newer step3.txt step3.txt.ref
