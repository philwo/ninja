#!/bin/sh
# Test: NINJA_STATUS supports various format codes
. "$(dirname "$0")/../test_helper.sh"
skip_if_siso "NINJA_STATUS not supported"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build a.txt: cp in.txt
build b.txt: cp in.txt
EOF
echo "data" > in.txt

# Test %s (starting edges), %t (total), %f (finished), %r (running)
NINJA_STATUS="[s=%s t=%t f=%f r=%r] " run_ninja
assert_exit_success
# At some point during the build, we should see total=2
assert_stdout_contains "t=2"

# Clean and test %e (elapsed time in seconds)
rm -f a.txt b.txt .ninja_log
NINJA_STATUS="[%e] " run_ninja
assert_exit_success
# Elapsed time should be a number (possibly with decimal)
assert_stdout_regex '^\[([0-9]+\.)?[0-9]+'

# Clean and test %p (percentage)
rm -f a.txt b.txt .ninja_log
NINJA_STATUS="[%p] " run_ninja
assert_exit_success
# Should contain a percentage like "50%" or "100%"
assert_stdout_regex '[0-9]+%'
