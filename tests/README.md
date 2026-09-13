# git_projects Test Suite

BATS (Bash Automated Testing System) tests for the **git_projects** security/workflow tooling (pre-push hooks, `release` alias, `release-common.sh` library, and `apply_rules.sh` script).

## Prerequisites

| Requirement | Why |
|---|---|
| `bats` (1.0+) | Test framework — install via `scripts/dev_env/setup_bats.sh` |
| `git` (2.28+) | Sandbox repos, `git init`, `git config` |
| `jq` | Used by `apply_rules.sh` and its tests |
| `sed`, `head`, `uniq`, `grep` | Tooling chain for `apply_rules.sh` tests |

## Quick Start

```bash
# Run the entire suite
bats -r tests/git_projects/

# Run a specific file
bats tests/git_projects/hooks/pre_push.bats

# Filter by test name (regex)
bats --filter "staging" tests/git_projects/
```

A non-zero exit code means one or more tests failed.

## CI / Formatters

```bash
# TAP output
bats --formatter tap -r tests/git_projects/

# JUnit XML (GitHub Actions / CI dashboards)
bats --formatter junit -r tests/git_projects/

# Parallel execution (requires GNU parallel)
bats --jobs 4 -r tests/git_projects/

# Timing info
bats -T -r tests/git_projects/
```

## Test File Layout

```
tests/
├── helpers/
│   └── sandbox.bash              # Shared sandbox builders (loaded via `load`)
├── git_projects/
│   ├── hooks/
│   │   ├── release_common.bats   # Branch-name resolution, key reading, bypass logic
│   │   └── pre_push.bats         # Pre-push hook blocking logic
│   ├── alias/
│   │   ├── alias_release.bats    # `git release` alias happy/error paths
│   │   └── alias_libdir.bats     # release.libdir hardening
│   └── scripts/
│       ├── set_release_key.bats  # Key generation & provisioning
│       └── apply_rules.bats      # GitHub branch ruleset application
├── README.md
└── test-findings.md              # Historical audit reference
```

## Sandbox Helpers (`tests/helpers/sandbox.bash`)

Loaded in each `.bats` file via:

```bash
load ../../helpers/sandbox.bash
```

| Function | Description |
|---|---|
| `s_env <name>` | Creates an isolated `$HOME` + global git config (no hooks/libdir) |
| `s_hooks <name>` | Like `s_env` + installs hooks, sets `core.hooksPath`, includes `release.gitconfig` |
| `s_hooks_at <name> <libdir>` | Like `s_hooks` with an explicit `release.libdir` |
| `s_key [value]` | Provisions the release bypass key file (mode 0600) |
| `s_repo [name]` | Creates a bare `origin.git` + a working clone on `main` |
| `s_push_bypass <branch>` | Pushes a branch to origin, bypassing pre-push (setup only) |
| `s_stub_lib <libdir> <marker>` | Writes a minimal `release-common.sh` stub for hardening tests |
| `s_fake_gh` | Installs a fake `gh` CLI that records calls and captures payloads |
| `s_nogh_path` | Returns a PATH with required tools but without `gh` |

Sandboxes use `$BATS_TEST_TMPDIR` (auto-cleaned by BATS after each test).

## Installing BATS

```bash
bash scripts/dev_env/setup_bats.sh
```
