# git_projects — global `git release` workflow

## Platform requirements

Linux only. Uses GNU `stat` (`-c` flag) for ownership and permission checks.
macOS and WSL1 are not supported.

A global, machine-wide git setup for repos that pair a **production** branch
with a **staging** branch and want them kept in sync via **fast-forward merges**.

Why this exists: GitHub cannot perform a true fast-forward merge through the
web UI or a pull request — it only offers merge/squash/rebase. When you need
production to be an exact fast-forward of staging, you must do the merge
locally and push it yourself. This repo automates that safely.

## Layout

```
git_projects/
├── release.gitconfig             # copy to ~/.config/git/ (see setup below)
├── hooks/                        # SELF-CONTAINED unit: copy this whole folder
│   ├── pre-push                  #   to ~/.config/git/hooks/ (see setup below)
│   └── release-common.sh         #   shared branch-name + key resolution
├── scripts/
│   ├── set-release-key.sh        # run to provision the local release key
│   └── apply_rules.sh            # apply GitHub branch rulesets for a repo
└── github/
    └── branch_rules/             # exported rulesets + security-model README
```

The `hooks/` folder is **self-contained**: the `pre-push` hook and
`release-common.sh` live side by side, so copying `hooks/` alone gives you
everything the hook needs. There is no external `lib/` dependency.

## Machine layout (copy, not symlink)

This repo mirrors where things live on your machine. You **copy** files over
(rather than symlinking). The destinations are:

| Repo path                          | Machine destination          |
|------------------------------------|------------------------------|
| `git_projects/hooks/` (whole folder)| `~/.config/git/hooks/`       |
| `git_projects/release.gitconfig`   | `~/.config/git/release.gitconfig` |
| `scripts/set-release-key.sh`       | anywhere (run to provision)  |
| `scripts/apply_rules.sh`           | anywhere (run per repo)      |

`~/.config/git/hooks/` is the conventional location for global hooks, so the
hook and its `release-common.sh` library both live there.

## One-time setup (per machine)

```bash
# 1. Copy the self-contained hooks folder to its machine home.
cp -r git_projects/hooks ~/.config/git/hooks/
chmod +x ~/.config/git/hooks/pre-push

# 2. Copy release.gitconfig to the same directory.
cp git_projects/release.gitconfig ~/.config/git/release.gitconfig

# 3. Point git at the global hooks.
git config --global core.hooksPath ~/.config/git/hooks

# 4. Include release.gitconfig in your global git config.
git config --global include.path ~/.config/git/release.gitconfig

# 5. Provision the release key.
set-release-key.sh
```

## Key concepts

### Branch names are per-repo, with a global default

Resolution order (highest precedence first):

1. `GIT_RELEASE_PRODUCTION` / `GIT_RELEASE_STAGING` (environment)
2. `git config release.production` / `release.staging`
    - repo-local (`.git/config`) → per-repo override
    - global (`~/.gitconfig`) → machine default
3. defaults: `main` / `staging`

Example per-repo override:

```bash
git config --local release.production production
git config --local release.staging  staging
```

### The release bypass key (accident prevention)

`git release` is allowed to push the production branch only when a release key
is supplied. The key is read from (highest first):

1. `GIT_RELEASE_KEY` (environment)
2. `~/.config/git/release-key` (mode 0600)

`git release` reads it automatically, so you don't type it yourself.

> **Cloud vs. local keys:** GitHub **repo secrets/variables are only visible to
> GitHub Actions**, not to your shell. A local `git push` cannot read them. So
> the bypass key is stored *locally* (~/.config/git/release-key). It prevents
> *accidental* direct pushes, but it is client-side and bypassable
> (`git push --no-verify`) — it is **not** server-side security.

## Per-repo setup

```bash
# Optional: set non-default branch names for this repo.
git config --local release.production main
git config --local release.staging  staging

# Apply the GitHub branch rulesets (Block force pushes, etc.) for this repo.
git_projects/scripts/apply_rules.sh
```

When run from a different location, pass `--libdir` to point at the directory
containing `release-common.sh` (default: `~/.config/git/hooks`):

```bash
apply_rules.sh --repo OWNER/REPO --libdir ~/.config/git/hooks
```

## Daily use

```bash
git release           # fetch, fast-forward staging into production, then push
git release --continue  # resume an interrupted release: push the already-merged prod
```

The `pre-push` hook:
- blocks **direct pushes to staging** (use a pull request instead), and
- blocks **direct pushes to production** unless the release key is present
  (i.e. only `git release`).

**Idempotency / safety:** `git release` is built around two hard safeguards:

1. **Dirty working tree** → it aborts immediately and asks you to **commit or
    stash** your staged/unstaged changes before releasing.
2. **Local commits on `prod` or `staging`** → before doing anything, it checks
    whether either branch has commits that are **not** on its origin counterpart.
    If so, it **aborts** and reports exactly which branch and which commit(s),
    then guides you to move those commits to a `feature/` or `hotfix/` branch,
    reset the local branch to match origin, open a PR into `staging`, and re-run.

`git release` never force-resets or overwrites local work, and it never guesses:
- If the local commits are *unintended* work, review and move/reset them.
- If they are the merge from an interrupted release that simply couldn't push,
    finish it with `git release --continue` (safeguard 2 is skipped there, since
    local `prod` being ahead is exactly the state being resumed).

## Security model and honest limits

- **Server-side:** the production branch ruleset enables `non_fast_forward`
    ("Block force pushes"). Force-pushes to production are rejected for everyone.
    This is the real guard. (A fast-forward release push is a normal push, not a
    force push, so it is not blocked.)
- **Local:** the hook + release key prevent *accidental* direct/force pushes on
    your machine. They can be bypassed (`git push --no-verify`, or by a user with
    shell access to the machine) and provide **no** protection against a
    determined actor or another collaborator. They complement, not replace, the
    server-side rule.
