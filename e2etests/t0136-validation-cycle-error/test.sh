#!/bin/sh
# Test: validation edge that creates a real dependency cycle produces error
. "$(dirname "$0")/../test_helper.sh"

# out validates "validate", but validate depends on validate_in,
# which depends on validate, creating a real cycle.
cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build out.txt: cp in.txt |@ validate.txt
build validate.txt: cp validate_in.txt
build validate_in.txt: cp validate.txt
EOF
echo "data" > in.txt

run_ninja
assert_exit_failure
assert_output_contains "dependency cycle"
