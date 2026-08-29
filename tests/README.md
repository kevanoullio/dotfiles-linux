# git_projects Test Suite

Bash unit tests for the **git_projects** security/workflow tooling (pre-push hooks, `release` alias, `release-common.sh` library, and `apply_rules.sh` script).

## Prerequisites

| Requirement | Why |
|---|---|
| `bash` (4.0+) | Tests use `mapfile`, process substitution, `local` scoping |
| `git` (2.28+) | Sandbox repos, `git init`, `git config` |
| `jq` | Used by `apply_rules.sh` and its tests |
| `sed`, `head`, `uniq`, `grep` | Tooling chain for `apply_rules.sh` tests |
| `gh` (optional) | Only needed for `apply_rules.test.sh` — a fake `gh` is auto-injected when available |

All other dependencies are self-contained in `lib.sh`.

## Quick Start

```bash
# Run the entire suite from the repo root
bash tests/run.sh

# Run from within tests/
cd tests && bash run.sh
```

A non-zero exit code means one or more test files failed.

## Running Subsets

The runner accepts an optional **pattern** argument. Only test files whose path contains the pattern are executed:

```bash
# Only hook-related tests
bash tests/run.sh hooks

# Only alias-related tests
bash tests/run.sh alias

# Only script-related tests
bash tests/run.sh scripts
```

## Running a Single Test

Each `*.test.sh` is self-contained and can be run directly:

```bash
# Run a single test file
bash tests/git_projects/hooks/release_common.test.sh

bash tests/git_projects/alias/alias_release.test.sh

bash tests/git_projects/scripts/apply_rules.test.sh
```

## Test File Layout

```
tests/
├── run.sh                  # Test runner (discovers and executes *.test.sh)
├── lib.sh                  # Shared test harness (sourced by every test)
├── test-findings.md        # Audit findings and known issues
├── .tmp/                   # Auto-generated sandbox directories (ignored)
└── git_projects/
    ├── hooks/
    │   ├── release_common.test.sh   # Branch-name resolution, key reading
    │   └── pre_push.test.sh         # Pre-push hook blocking logic
    ├── alias/
    │   ├── alias_release.test.sh    # `git release` alias happy/error paths
    │   └── alias_libdir.test.sh     # release.libdir hardening
    └── scripts/
        ├── set_release_key.test.sh  # Key generation & provisioning
        └── apply_rules.test.sh      # GitHub branch ruleset application
```

## Test Harness (`lib.sh`)

Every `*.test.sh` sources `lib.sh` which provides:

### Assertion Helpers

| Function | Signature | Description |
|---|---|---|
| `assert_eq` | `assert_eq <actual> <expected> <message>` | Compare two strings |
| `assert_ne` | `assert_ne <actual> <not-expected> <message>` | Assert inequality |
| `assert_contains` | `assert_contains <string> <substring> <message>` | Check substring inclusion |
| `assert_rc` | `assert_rc <message> <expected_rc> <cmd> [args...]` | Assert exit code of a command |
| `assert_rc_out` | `assert_rc_out <message> <expected_rc> <grep-pattern> <cmd> [args...]` | Assert exit code AND output matches a grep pattern |

### Sandbox Builders

| Function | Description |
|---|---|
| `s_env <name>` | Creates an isolated `$HOME` + global git config (no hooks/libdir) |
| `s_hooks <name>` | Like `s_env` + installs hooks, sets `core.hooksPath`, includes `release.gitconfig` |
| `s_hooks_at <name> <libdir>` | Like `s_hooks` with an explicit `release.libdir` |
| `s_key [value]` | Provisions the release bypass key file (mode 0600) |
| `s_repo [name]` | Creates a bare `origin.git` + a working clone on `main` |
| `s_stub_lib <libdir> <marker>` | Writes a minimal `release-common.sh` stub for hardening tests |
| `s_fake_gh` | Installs a fake `gh` CLI that records calls for verification |
| `s_nogh_path` | Returns a PATH with required tools but without `gh` |

### Logging

| Function | Description |
|---|---|
| `t_section <name>` | Prints a section header |
| `t_run <name>` | Sets the current test context name |
| `t_summary` | Prints pass/fail counts; returns non-zero if any assertions failed |

Each test file must end by calling `t_summary` or `exit`ing with the appropriate code.

## Environment Variables

| Variable | Purpose |
|---|---|
| `TESTS_HOME` | Directory containing the `tests/` tree (auto-set by `run.sh` and `lib.sh`) |

## Known Issues

See [`test-findings.md`](./test-findings.md) for the latest audit findings and required fixes.
