#!/bin/sh
# Test: dyndep discovers new implicit input at build time
. "$(dirname "$0")/../test_helper.sh"

# The dyndep file adds "extra_in.txt" as a new implicit input to out.txt.
# This means extra_in.txt must be built before out.txt.
cat > build.ninja <<'EOF'
rule cat
  command = cat $in > $out
rule touch
  command = touch $out
rule gen_dd
  command = printf 'ninja_dyndep_version = 1\nbuild out.txt: dyndep | extra_in.txt\n' > $out
build dd.ninja: gen_dd
build extra_in.txt: touch
build out.txt: cat in.txt || dd.ninja
  dyndep = dd.ninja
EOF
echo "hello" > in.txt

run_ninja -v
assert_exit_success
assert_file_exists out.txt
assert_file_exists extra_in.txt
assert_file_exists dd.ninja

# The dyndep-discovered input (extra_in.txt) should have been built
assert_file_exists extra_in.txt
