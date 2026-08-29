# Test Audit Findings

## Root Cause Affecting Multiple Tests

**`lib.sh:19`** references `git_projects/.gitconfig`, but the actual file is **`git_projects/release.gitconfig`**:

```bash
readonly GITCONFIG_SRC="$GPROOT/git_projects/.gitconfig"   # WRONG
```

This means `s_hooks()` sets `include.path` to a non-existent file, so the `release` alias is **never registered**. Any test using `s_hooks()` or `s_repo()` that relies on `git release` fails with `"git: 'release' is not a git command"`.

---

## Test-by-Test Results

### 1. `scripts/apply_rules.test.sh` — FAIL (cannot even source lib.sh)

**Issue:** Line 19 uses `../../../lib.sh` which goes up 4 levels from `tests/git_projects/scripts/` and lands outside the repo. Should be `../../lib.sh`.

**Verdict: NEEDS FIXING** — fix the relative path.

### 2. `scripts/set_release_key.test.sh` — PASS (11/11)

All 4 test sections are logically sound, covering key generation, mode 0600, provided passphrase, export line, and directory creation.

**Verdict: NO ISSUES**

### 3. `hooks/release_common.test.sh` — PASS (35/35)

All 9 test sections are logically sound, covering branch-name resolution cascade (env > config > default), sanitization of shell metacharacters, key file path, key reading precedence, key configuration detection, and bypass logic.

**Verdict: NO ISSUES**

### 4. `alias/alias_release.test.sh` — FAIL (4 pass, 8 fail)

All failures are caused by the `.gitconfig` filename mismatch — the `release` alias never loads. The test logic itself is sound (happy path, custom branches, env override, arg validation, dirty tree, local commits abort, --continue).

**Verdict: NEEDS FIXING** — only the gitconfig path needs to be corrected; all test logic is valid.

### 5. `alias/alias_libdir.test.sh` — FAIL (0 pass, 6+ fail)

Same root cause as #4 (gitconfig path). Additionally, **line 39** creates a symlink without first creating the parent directory (`$HOME/sym-lib/`), causing a "No such file or directory" error.

**Verdict: NEEDS FIXING** — fix gitconfig path + add `mkdir -p` before the symlink test.

### 6. `hooks/pre_push.test.sh` — FAIL (4 pass, 5 fail)

**Bug in `hook_rc()` function:** The hook's `echo "ERROR: ..."` messages go to **stdout**, but `hook_rc()` only redirects stderr (`2>/dev/null`). So `$(hook_rc ...)` captures both the error messages AND the exit code as a multi-line string, which `assert_eq` then compares against `"1"` — always failing.

The test logic itself is sound. The "real push" subtests all pass because they use `assert_ne` and `assert_contains` which work correctly.

**Verdict: NEEDS FIXING** — redirect the hook's stdout to `/dev/null` inside `hook_rc()`.

---

## Final Summary

| Test File | Passed | Failed | Needs Fixing? |
|-----------|--------|--------|---------------|
| `apply_rules.test.sh` | — | — | **Yes** — wrong lib.sh path |
| `set_release_key.test.sh` | 11 | 0 | No |
| `release_common.test.sh` | 35 | 0 | No |
| `alias_release.test.sh` | 4 | 8 | **Yes** — gitconfig filename (logic is sound) |
| `alias_libdir.test.sh` | 0 | 6+ | **Yes** — gitconfig filename + mkdir bug |
| `pre_push.test.sh` | 4 | 5 | **Yes** — hook_rc stdout capture bug |
| **TOTAL** | **54** | **19+** | |

## Required Fixes (priority order)

1. **`lib.sh:19`** — Change `.gitconfig` to `release.gitconfig` (fixes alias tests)
2. **`apply_rules.test.sh:19`** — Change `../../../lib.sh` to `../../lib.sh`
3. **`pre_push.test.sh` hook_rc()** — Suppress hook stdout (`>/dev/null`) so only exit code is captured
4. **`alias_libdir.test.sh:39`** — Add `mkdir -p "$HOME/sym-lib"` before the `ln -s` command

## Tests That Are Perfect (no changes needed)

- `set_release_key.test.sh` — 4 sections, 11 assertions, all passing, logic is sound
- `release_common.test.sh` — 9 sections, 35 assertions, all passing, logic is sound
