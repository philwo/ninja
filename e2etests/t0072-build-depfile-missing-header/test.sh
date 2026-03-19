#!/bin/sh
# Test: Depfile lists header that is later deleted - rebuilds correctly
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cc
  command = cp $in $out && echo "$out: $in header.h" > $out.d
  depfile = $out.d
  deps = gcc
build out.txt: cc in.txt
EOF
echo "source" > in.txt
echo "header_v1" > header.h

# First build - deps recorded with header.h
run_ninja
assert_exit_success
assert_file_exists out.txt

# Delete the header and change the build rule to not reference it
rm header.h
cat > build.ninja <<'EOF'
rule cc
  command = cp $in $out && echo "$out: $in" > $out.d
  depfile = $out.d
  deps = gcc
build out.txt: cc in.txt
EOF

# Should rebuild (header.h missing triggers dirty)
run_ninja
assert_exit_success
assert_file_exists out.txt
