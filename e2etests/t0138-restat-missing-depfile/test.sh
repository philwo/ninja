#!/bin/sh
# Test: restat rule with missing depfile forces rebuild of downstream
. "$(dirname "$0")/../test_helper.sh"

# When a restat rule's output hasn't changed, it normally cancels
# downstream rebuilds. But if the downstream target's depfile is
# missing, it should still force a rebuild.
cat > build.ninja <<'EOF'
rule gen_header
  command = echo static > $out.tmp && if cmp -s $out.tmp $out; then rm $out.tmp; else mv $out.tmp $out; fi
  restat = 1
rule cc
  command = cat $in header.h > $out
  depfile = ${out}.d
  deps = gcc
build header.h: gen_header header.in
build out.txt: cc header.h
EOF
echo "data" > header.in

# First build
run_ninja
assert_exit_success
assert_file_exists header.h
assert_file_exists out.txt

# Create depfile to record the dependency
echo "out.txt: header.h" > out.txt.d

# Rebuild to record deps in .ninja_deps
run_ninja
assert_exit_success

sleep 1

# Delete the deps log to simulate missing deps
rm -f .ninja_deps .siso_deps

# Touch header.in - gen_header runs but produces same content.
# Without deps info, out.txt should still rebuild.
echo "different" > header.in
cp -p out.txt out.txt.ref
run_ninja
assert_exit_success
# out.txt should have been rebuilt because deps are missing
assert_file_newer out.txt out.txt.ref
