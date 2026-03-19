#!/bin/sh
# Test: -t clean discovers and removes implicit outputs from dyndep
. "$(dirname "$0")/../test_helper.sh"

# Create a dyndep file that declares an implicit output
cat > build.ninja <<'EOF'
rule touch
  command = touch $out && touch out.imp
build out.txt: touch in.txt || dd.ninja
  dyndep = dd.ninja
EOF
echo "data" > in.txt

cat > dd.ninja <<'EOF'
ninja_dyndep_version = 1
build out.txt | out.imp: dyndep
EOF

run_ninja
assert_exit_success
assert_file_exists out.txt
assert_file_exists out.imp

# Clean should remove both out.txt and the dyndep-discovered out.imp
run_ninja -t clean
assert_exit_success
assert_file_not_exists out.txt
assert_file_not_exists out.imp

# --- Test that a missing dyndep file is tolerated during clean ---
rm -f .ninja_log .ninja_deps

cat > build.ninja <<'EOF'
rule touch
  command = touch $out
build out2.txt: touch in.txt || missing_dd.ninja
  dyndep = missing_dd.ninja
EOF

# Don't create missing_dd.ninja - it should be tolerated
echo "data2" > out2.txt

run_ninja -t clean
assert_exit_success
assert_file_not_exists out2.txt
