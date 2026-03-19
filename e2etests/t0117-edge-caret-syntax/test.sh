#!/bin/sh
# Test: target^ resolves to first output of the edge producing target
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build mid.txt: cp in.txt
build out.txt: cp mid.txt
EOF
echo "data" > in.txt

# mid.txt^ should refer to the first output of the edge that uses mid.txt as input
# i.e., out.txt
run_ninja -t query 'mid.txt^'
assert_exit_success
