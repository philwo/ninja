#!/bin/sh
# Test: ninja_required_version checking
. "$(dirname "$0")/../test_helper.sh"
skip_if_siso "ninja_required_version not enforced"

# Version that is way too new should cause a fatal error
cat > build.ninja <<'EOF'
ninja_required_version = 999.0
rule cp
  command = cp $in $out
build out.txt: cp in.txt
EOF
echo "data" > in.txt

run_ninja
assert_exit_failure
assert_output_contains "ninja version"
assert_output_contains "incompatible"
