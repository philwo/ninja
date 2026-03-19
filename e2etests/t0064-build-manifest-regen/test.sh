#!/bin/sh
# Test: build.ninja as output triggers manifest regeneration
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule regen
  command = cp build.ninja.in build.ninja
  generator = 1
build build.ninja: regen build.ninja.in

rule cp
  command = cp $in $out
build out.txt: cp in.txt
EOF

# Create build.ninja.in with same content plus extra target
cat > build.ninja.in <<'EOF'
rule regen
  command = cp build.ninja.in build.ninja
  generator = 1
build build.ninja: regen build.ninja.in

rule cp
  command = cp $in $out
build out.txt: cp in.txt
build extra.txt: cp in.txt
EOF
echo "data" > in.txt

run_ninja
assert_exit_success
assert_file_exists out.txt
# After manifest regen, extra.txt should be buildable
run_ninja extra.txt
assert_exit_success
assert_file_exists extra.txt
