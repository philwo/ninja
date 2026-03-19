#!/bin/sh
# Test: two-level dyndep chain works correctly
. "$(dirname "$0")/../test_helper.sh"

# dd1 is a dyndep for out1, and dd2 is a dyndep for out2.
# out2 depends on out1, so dd1 must be loaded before out1 is built,
# and dd2 must be loaded before out2 is built.
cat > build.ninja <<'EOF'
rule touch
  command = touch $out
rule cp
  command = cp $in $out
build dd1: cp dd1-in
build out1: touch || dd1
  dyndep = dd1
build dd2: cp dd2-in
build out2: touch out1 || dd2
  dyndep = dd2
EOF

cat > dd1-in <<'EOF'
ninja_dyndep_version = 1
build out1: dyndep
EOF

cat > dd2-in <<'EOF'
ninja_dyndep_version = 1
build out2: dyndep
EOF

run_ninja -v out2
assert_exit_success
assert_file_exists out1
assert_file_exists out2
assert_file_exists dd1
assert_file_exists dd2
