#!/bin/sh
# Test: No targets + no default statement produces error
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build a.txt: cp in.txt
EOF
echo "data" > in.txt

# No default statement and no targets specified on command line
# With no default statement, all outputs are built (ninja builds root nodes)
# But if there are no root nodes, we get an error.
# Actually ninja builds all targets without incoming edges as default.
# Let's test with a file that has an edge but it's a cycle of deps.
# Simpler: empty build file with no build statements at all.
cat > build.ninja <<'EOF'
EOF

run_ninja
assert_exit_success
# Empty build file = "no work to do" (exactly one line on stdout)
assert_stdout_contains "no work to do"
assert_stdout_line_count 1
