#!/bin/sh
# Test: dyndep discovers new implicit output at build time
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule gen
  command = echo main > $out && echo implicit > out.imp
rule gen_dd
  command = printf 'ninja_dyndep_version = 1\nbuild out.txt | out.imp: dyndep\n' > $out
build dd.ninja: gen_dd
build out.txt: gen in.txt || dd.ninja
  dyndep = dd.ninja
EOF
echo "hello" > in.txt

run_ninja
assert_exit_success
assert_file_exists out.txt
assert_file_exists out.imp
assert_file_contains out.txt "main"
assert_file_contains out.imp "implicit"
