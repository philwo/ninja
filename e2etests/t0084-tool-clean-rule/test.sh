#!/bin/sh
# Test: -t clean -r rule removes outputs of specified rule only
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule compile
  command = cp $in $out
rule link
  command = cp $in $out
build obj.txt: compile src.txt
build bin.txt: link obj.txt
EOF
echo "source" > src.txt

run_ninja
assert_exit_success
assert_file_exists obj.txt
assert_file_exists bin.txt

run_ninja -t clean -r compile
assert_exit_success
assert_file_not_exists obj.txt
# bin.txt built by 'link' rule should remain
assert_file_exists bin.txt
