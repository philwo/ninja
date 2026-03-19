# End-to-End Test Suite for Ninja

A shell-based end-to-end test suite that exercises the full ninja binary against
real build files. Complements the unit tests (`ninja_test`) and Python
integration tests (`misc/output_test.py`, `misc/jobserver_test.py`).

## Running

```sh
# Build ninja first
cmake -B build && cmake --build build

# Run the full test suite
./e2etests/run_tests.sh ./build/ninja

# Run specific tests by number
./e2etests/run_tests.sh ./build/ninja t0001 t0009

# Run tests matching a substring (e.g. all CLI tests)
./e2etests/run_tests.sh ./build/ninja cli

# Lint all test scripts with shellcheck
./e2etests/lint_tests.sh

# Print stdout/stderr even for passing and skipped tests
NINJA_TEST_DEBUG=1 ./e2etests/run_tests.sh ./build/ninja

# Disable colored output
NINJA_TEST_COLOR=0 ./e2etests/run_tests.sh ./build/ninja
```

## Structure

```
e2etests/
  run_tests.sh           # Test runner (discovers and runs all t*/test.sh)
  test_helper.sh         # Shared assertion/setup library
  lint_tests.sh          # Runs shellcheck on all scripts
  t0001-cli-version/test.sh
  t0002-cli-help/test.sh
  ...
```

## Design Principles

- **POSIX sh** -- all scripts use `#!/bin/sh`, no bashisms.
- **Self-contained** -- each test creates its `.ninja` files and data inline.
- **Isolated** -- each test runs in its own temp directory, cleaned up on exit.
- **Fast** -- uses `cp`, `cat`, `echo` as build commands (no real compilers).
- **Deterministic** -- `sleep 1` only where mtime granularity matters.
- **Baseline + feature** -- many tests first demonstrate the default behavior,
  then show how a feature changes it, so the reader sees both sides.
- **Exit codes** -- 0 = pass, 1 = fail, 77 = skip.

## Writing a New Test

Create a directory matching the pattern `tNNNN-descriptive-name/` and add a
`test.sh` inside it:

```sh
#!/bin/sh
# Test: short description shown in test output
. "$(dirname "$0")/../test_helper.sh"

cat > build.ninja <<'EOF'
rule cp
  command = cp $in $out
build out.txt: cp in.txt
EOF
echo "data" > in.txt

run_ninja
assert_exit_success
assert_file_exists out.txt
```

Make it executable (`chmod +x test.sh`) and the runner will pick it up
automatically.

### Available Assertions

| Function | Checks |
|----------|--------|
| `assert_exit_success` | `$NINJA_EXIT` = 0 |
| `assert_exit_failure` | `$NINJA_EXIT` != 0 |
| `assert_exit_code N` | `$NINJA_EXIT` = N |
| `assert_stdout_contains "str"` | stdout contains exact string |
| `assert_stderr_contains "str"` | stderr contains exact string |
| `assert_stdout_not_contains "str"` | stdout does not contain string |
| `assert_stderr_not_contains "str"` | stderr does not contain string |
| `assert_output_contains "str"` | stdout or stderr contains string |
| `assert_stdout_line_count N` | stdout has exactly N lines |
| `assert_stdout_regex "re"` | stdout matches extended regex |
| `assert_stderr_regex "re"` | stderr matches extended regex |
| `assert_contains_regex "re" file` | file matches extended regex |
| `assert_file_exists path` | file exists |
| `assert_file_not_exists path` | file does not exist |
| `assert_dir_exists path` | directory exists |
| `assert_file_contains file "str"` | file contains exact string |
| `assert_file_content_equals file "str"` | file content equals string exactly |
| `assert_file_newer A B` | A is newer than B |
| `assert_file_not_newer A B` | A is not newer than B |
| `fail "message"` | fail immediately with message |
| `skip_test "reason"` | skip test (exit 77) |

## Test Numbering

Tests use `tNNNN-descriptive-name/` format, grouped by number ranges:

- `t0001-t0019` -- CLI flags and options
- `t0020-t0039` -- Build file syntax
- `t0040-t0049` -- Rule variables and special features
- `t0050-t0079` -- Build behavior (clean + incremental)
- `t0080-t0109` -- Tools (`-t`)
- `t0110-t0120` -- Edge cases and error handling
- `t0121-t0126` -- Clean tool advanced scenarios
- `t0127-t0133` -- Advanced dyndep behavior
- `t0134-t0136` -- Validation edge scenarios
- `t0137-t0138` -- Restat + depfile interactions
- `t0139-t0140` -- Response file edge cases
- `t0141-t0145` -- Build behavior edge cases
- `t0146-t0150` -- Syntax and formatting edge cases

## Test Catalog

### CLI Flags (t0001-t0015)

| Test | What it verifies |
|------|-----------------|
| `t0001-cli-version` | `--version` prints version and exits 0 |
| `t0002-cli-help` | `-h` prints usage to stderr and exits 1 |
| `t0003-cli-change-dir` | `-C dir` builds in specified directory |
| `t0004-cli-build-file` | `-f custom.ninja` loads alternate build file |
| `t0005-cli-parallel-jobs` | `-j1` forces serial execution |
| `t0006-cli-keep-going` | `-k2` continues past first failure |
| `t0007-cli-dry-run` | `-n` shows commands without executing |
| `t0008-cli-verbose` | `-v` shows full command lines |
| `t0009-cli-quiet` | Default shows progress; `--quiet` suppresses it |
| `t0010-cli-debug-explain` | `-d explain` shows rebuild reasons |
| `t0011-cli-debug-keepdepfile` | `-d keepdepfile` preserves `.d` files |
| `t0012-cli-debug-keeprsp` | `-d keeprsp` preserves response files |
| `t0013-cli-warning-phonycycle` | `-w phonycycle=warn` vs `=err` |
| `t0014-cli-multiple-targets` | Only named targets are built |
| `t0015-cli-no-targets-no-default` | No targets + no default exits with "no work to do" |

### Build File Syntax (t0020-t0039)

| Test | What it verifies |
|------|-----------------|
| `t0020-syntax-variables` | `$var` and `${var}` expansion |
| `t0021-syntax-variable-scoping` | File, rule, and build-level scoping precedence |
| `t0022-syntax-escapes` | `$$` becomes literal `$` |
| `t0023-syntax-rule-bindings` | `command` and `description` rule bindings |
| `t0024-syntax-build-deps-explicit` | Explicit inputs appear in `$in` |
| `t0025-syntax-build-deps-implicit` | Implicit inputs (`|`) trigger rebuild but not in `$in` |
| `t0026-syntax-build-deps-order-only` | Order-only deps (`||`) are built first but don't trigger rebuild |
| `t0027-syntax-implicit-outputs` | Implicit outputs created but not in `$out` |
| `t0028-syntax-pool` | Without pool: full parallelism; with pool `depth=1`: limited |
| `t0029-syntax-default` | Only `default` targets are built |
| `t0030-syntax-include` | `include` shares parent scope |
| `t0031-syntax-subninja` | `include` leaks scope changes; `subninja` isolates them |
| `t0032-syntax-comments` | `#` comments don't affect build |
| `t0033-syntax-phony-alias` | Phony as target alias builds real target |
| `t0034-syntax-phony-no-inputs` | Phony with no inputs is always dirty if missing |
| `t0035-syntax-errors-tabs` | Tabs in wrong places produce error |
| `t0036-syntax-errors-unknown-rule` | Unknown rule name gives clear error |
| `t0037-syntax-ninja-required-version` | Too-new required version causes error |
| `t0038-syntax-multiple-outputs` | Multiple explicit outputs all created |
| `t0039-syntax-newline-in-command` | `$\n` line continuation in values |

### Rule Variables and Special Features (t0040-t0047)

| Test | What it verifies |
|------|-----------------|
| `t0040-rule-description` | Without description: command shown; with: description shown instead |
| `t0041-rule-depfile-gcc` | Without depfile: header changes undetected; with: detected and `.d` consumed |
| `t0042-rule-restat` | Without restat: downstream always rebuilds; with: skipped if output unchanged |
| `t0043-rule-generator` | Without generator: command change rebuilds; with: no rebuild |
| `t0044-rule-rspfile` | `rspfile` + `rspfile_content` creates and consumes response file |
| `t0045-rule-dyndep` | Without dyndep: undeclared dep changes ignored; with: detected |
| `t0046-rule-pool-console` | `console` pool gives direct terminal access at depth 1 |
| `t0047-rule-pool-custom` | Custom pool limits concurrent jobs |

### Build Behavior (t0050-t0072)

| Test | What it verifies |
|------|-----------------|
| `t0050-build-clean-build` | Clean build creates outputs and `.ninja_log` |
| `t0051-build-incremental-input` | Input change triggers rebuild |
| `t0052-build-incremental-cmd` | Command change in `.ninja` triggers rebuild |
| `t0053-build-incremental-output-deleted` | Deleted output is recreated |
| `t0054-build-incremental-implicit-dep` | Implicit dep change triggers rebuild |
| `t0055-build-order-only-no-rebuild` | Implicit dep (`|`) change rebuilds; order-only (`||`) does not |
| `t0056-build-up-to-date` | Second run reports "no work to do" |
| `t0057-build-multiple-outputs` | Rule producing multiple outputs creates all |
| `t0058-build-failure-stops` | Default `-k1` stops on failure; `-k0` continues past failures |
| `t0059-build-failure-keep-going` | `-k0` continues building other targets |
| `t0060-build-missing-input` | Missing explicit input gives clear error |
| `t0061-build-circular-dep` | Cycle detection reports "dependency cycle" |
| `t0062-build-log` | `.ninja_log` created with entries |
| `t0063-build-deps-log` | `.ninja_deps` created with `deps=gcc` |
| `t0064-build-manifest-regen` | `build.ninja` as output triggers manifest re-read |
| `t0065-build-dir-creation` | Output directories created by command |
| `t0066-build-builddir` | Without builddir: logs in root; with: logs in specified directory |
| `t0067-build-restat-chain` | Restat in multi-step chain only rebuilds necessary steps |
| `t0068-build-validation-edges` | Without `\|@`: validator not built; with: validator executes |
| `t0069-build-ninja-status-env` | `NINJA_STATUS` format codes work |
| `t0070-build-empty-build` | Empty build file exits 0 with "no work to do" |
| `t0071-build-phony-chain` | Phony depending on phony works |
| `t0072-build-depfile-missing-header` | Depfile with later-deleted header rebuilds correctly |

### Tools (t0080-t0101)

| Test | What it verifies |
|------|-----------------|
| `t0080-tool-list` | `-t list` shows all tool names |
| `t0081-tool-clean-all` | `-t clean` removes outputs, keeps `.ninja_log` |
| `t0082-tool-clean-target` | `-t clean target` removes only that target |
| `t0083-tool-clean-generator` | `-t clean -g` also removes generator outputs |
| `t0084-tool-clean-rule` | `-t clean -r rule` removes outputs of specified rule |
| `t0085-tool-cleandead` | `-t cleandead` removes files no longer in manifest |
| `t0086-tool-commands` | `-t commands` lists commands in dependency order |
| `t0087-tool-compdb` | `-t compdb` outputs valid JSON compilation database |
| `t0088-tool-compdb-targets` | `-t compdb-targets target` outputs only that target's entry |
| `t0089-tool-deps` | `-t deps` shows stored dependencies |
| `t0090-tool-graph` | `-t graph` outputs dot-format graph |
| `t0091-tool-inputs` | `-t inputs target` lists transitive inputs |
| `t0092-tool-query` | `-t query target` shows target's deps |
| `t0093-tool-rules` | `-t rules` lists rules; `-d` adds descriptions |
| `t0094-tool-targets-depth` | `-t targets depth N` lists targets by depth |
| `t0095-tool-targets-rule` | `-t targets rule R` lists outputs of rule |
| `t0096-tool-targets-all` | `-t targets all` lists all targets |
| `t0097-tool-recompact` | `-t recompact` succeeds and recompacts logs |
| `t0098-tool-restat` | `-t restat` updates build log |
| `t0099-tool-missingdeps` | `-t missingdeps` reports missing dep edges |
| `t0100-tool-commands-single` | `-t commands -s` prints only final command |
| `t0101-tool-multi-inputs` | `-t multi-inputs` prints input sets |

### Edge Cases (t0110-t0120)

| Test | What it verifies |
|------|-----------------|
| `t0110-edge-spellcheck` | Misspelled target suggests correction |
| `t0111-edge-paths-with-spaces` | `$ ` escaped spaces in paths handled |
| `t0112-edge-duplicate-output` | Same output in two build statements errors |
| `t0113-edge-phony-cycle-warn` | Phony self-reference warns by default |
| `t0114-edge-phony-cycle-err` | `-w phonycycle=err` makes it an error |
| `t0115-edge-entering-directory` | `-C dir` prints "Entering directory" |
| `t0116-edge-long-build-chain` | Deep dependency chain executes in order |
| `t0117-edge-caret-syntax` | `target^` resolves to first output |
| `t0118-edge-include-cycle` | Circular includes produce error |
| `t0119-edge-depfile-without-deps` | `depfile` without `deps` binding still works |
| `t0120-edge-build-log-survives-clean` | `.ninja_log` not removed by `-t clean` |

### Clean Tool Advanced Scenarios (t0121-t0126)

| Test | What it verifies |
|------|-----------------|
| `t0121-clean-dry-run` | `-n -t clean` reports files but does not delete them |
| `t0122-clean-depfile` | `-t clean` also removes depfiles alongside outputs |
| `t0123-clean-rspfile` | `-t clean` also removes response files alongside outputs |
| `t0124-clean-phony` | `-t clean` does NOT remove phony target files |
| `t0125-clean-dyndep` | `-t clean` discovers/removes dyndep implicit outputs; tolerates missing dyndep |
| `t0126-clean-depfile-rspfile-spaces` | Clean handles depfiles and rspfiles with spaces in paths |

### Advanced Dyndep Behavior (t0127-t0133)

| Test | What it verifies |
|------|-----------------|
| `t0127-dyndep-discover-input` | Dyndep discovers new implicit input at build time |
| `t0128-dyndep-discover-output` | Dyndep discovers new implicit output at build time |
| `t0129-dyndep-syntax-error` | Malformed dyndep file (missing version) produces clear error |
| `t0130-dyndep-circular` | Dyndep creating a circular dependency produces error |
| `t0131-dyndep-multiple-rules` | Dyndep claiming output already owned by another edge errors |
| `t0132-dyndep-two-level` | Two-level dyndep chain resolves correctly |
| `t0133-dyndep-missing-no-rule` | Missing dyndep file with no build rule produces error |

### Validation Edge Scenarios (t0134-t0136)

| Test | What it verifies |
|------|-----------------|
| `t0134-validation-depends-on-output` | Validation edge that depends on the build output |
| `t0135-validation-circular` | Mutual validation edges are allowed (not a cycle) |
| `t0136-validation-cycle-error` | Validation introducing a real dependency cycle produces error |

### Restat + Depfile Interactions (t0137-t0138)

| Test | What it verifies |
|------|-----------------|
| `t0137-restat-depfile-dependency` | Restat rule generating a header cancels downstream rebuild via depfile |
| `t0138-restat-missing-depfile` | Restat with missing depfile forces rebuild of downstream |

### Response File Edge Cases (t0139-t0140)

| Test | What it verifies |
|------|-----------------|
| `t0139-rspfile-failure-preserved` | Response file is preserved on build failure for debugging |
| `t0140-rspfile-content-change-rebuild` | Changing `rspfile_content` triggers rebuild |

### Build Behavior Edge Cases (t0141-t0145)

| Test | What it verifies |
|------|-----------------|
| `t0141-rebuild-after-failure` | Fixing a build error and rebuilding succeeds |
| `t0142-depfile-wrong-output` | Depfile listing wrong output name handled correctly |
| `t0143-implicit-output-rebuild` | Missing implicit output triggers rebuild |
| `t0144-phony-no-inputs-always-rebuilds` | Phony with no inputs always causes dependents to rebuild |
| `t0145-phony-with-inputs-rebuild` | Phony with real inputs propagates rebuild when input changes |

### Syntax and Formatting Edge Cases (t0146-t0150)

| Test | What it verifies |
|------|-----------------|
| `t0146-syntax-crlf` | Build.ninja with CRLF line endings works correctly |
| `t0147-syntax-missing-subninja` | Missing subninja file produces error |
| `t0148-syntax-line-continuation` | Line continuation with `$` at end of line |
| `t0149-syntax-duplicate-edge-include` | Duplicate output across included files produces error |
| `t0150-ninja-status-format-codes` | `NINJA_STATUS` format codes (`%s`, `%t`, `%f`, `%r`, `%e`, `%p`) |
