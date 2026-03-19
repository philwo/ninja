#!/bin/sh
# Test: phony with no inputs (always dirty if output missing)
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build intermediate: phony
build out.txt: cp in.txt | intermediate
EOF
echo "data" > in.txt

# First build
run_ninja
assert_exit_success
assert_file_exists out.txt

# Second build - phony with no inputs is always dirty,
# but since intermediate is phony (no file), touching it doesn't
# trigger rebuild of out.txt (phony outputs don't have mtimes).
run_ninja
assert_exit_success
