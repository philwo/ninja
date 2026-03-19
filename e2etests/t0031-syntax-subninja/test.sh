#!/bin/sh
# Test: subninja creates a new scope (variable isolation)
. "$(dirname "$0")/../test_helper.sh"

# --- Baseline: include shares scope (child override leaks to parent) ---

cat > child.ninja <<'EOF'
myvar = child_value
rule write_child
  command = echo $myvar > $out
build child_out.txt: write_child
EOF

cat > build.ninja <<'EOF'
myvar = parent_value
include child.ninja
rule write_parent
  command = echo $myvar > $out
build parent_out.txt: write_parent
EOF

run_ninja
assert_exit_success
assert_file_contains child_out.txt "child_value"
# With include, child's override affects parent scope
assert_file_contains parent_out.txt "child_value"

# --- Clean up for next scenario ---
rm -f parent_out.txt child_out.txt .ninja_log .ninja_deps

# --- With subninja: child override does NOT leak to parent ---

cat > build.ninja <<'EOF'
myvar = parent_value
subninja child.ninja
rule write_parent
  command = echo $myvar > $out
build parent_out.txt: write_parent
EOF

run_ninja
assert_exit_success
assert_file_contains child_out.txt "child_value"
# With subninja, parent keeps its own value
assert_file_contains parent_out.txt "parent_value"
