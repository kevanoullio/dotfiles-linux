#!/usr/bin/env bash
#
# Integration tests for the `release` alias workflow (git_projects/release.gitconfig).
#
# Runs `git release` end-to-end against a local bare origin, exercising the
# protected push through the real global pre-push hook (via core.hooksPath) and
# the shared release-common.sh library.
#
# Coverage:
#   * happy-path fast-forward release (and custom branch names via config/env)
#   * dirty-working-tree abort
#   * local-commits-on-prod / local-commits-on-staging abort
#   * `--continue`: nothing-to-resume, and clean fast-forward resume
#   * unknown-argument rejection
#
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../../lib.sh"

# seed_branches <prod> <staging> — build a working repo where <staging> is a
# clean fast-forward ahead of <prod>, both pushed, tree clean, on <staging>.
seed_branches() {
	local prod="$1" staging="$2"
	git branch -M "$prod"
	echo one >f
	git add f
	git commit -qm "one"
	s_push_bypass "$prod"
	git checkout -qb "$staging"
	echo two >g
	git add g
	git commit -qm "two"
	s_push_bypass "$staging"
	git checkout -q "$staging"
}

t_section "happy path: staging fast-forwards into prod (default names)"

s_repo "release-happy"
( cd "$WORK" && seed_branches main staging )
( cd "$WORK" && s_key )
out=""
rc=0
out="$(cd "$WORK" && git release 2>&1 <<<YES)" || rc=$?
assert_eq "$rc" "0" "git release succeeds (rc 0)"
assert_contains "$out" "Production fast-forward merge successful!" "prints success"
assert_eq "$(git -C "$WORK" rev-parse origin/main)" "$(git -C "$WORK" rev-parse origin/staging)" \
	"origin/prod advanced to origin/staging"
assert_eq "$(git -C "$WORK" rev-parse main)" "$(git -C "$WORK" rev-parse origin/main)" \
	"local prod synced to origin/prod"
assert_eq "$(git -C "$WORK" branch --show-current)" "staging" \
	"returns to the original branch"

t_section "happy path with custom branch names (git config)"

s_repo "release-config"
( cd "$WORK" && git config release.production prod )
( cd "$WORK" && git config release.staging staging )
( cd "$WORK" && seed_branches prod staging )
( cd "$WORK" && s_key )
rc=0
out="$(cd "$WORK" && git release 2>&1 <<<YES)" || rc=$?
assert_eq "$rc" "0" "custom-named release succeeds"
assert_eq "$(git -C "$WORK" rev-parse origin/prod)" "$(git -C "$WORK" rev-parse origin/staging)" \
	"custom origin/prod advances to origin/staging"

t_section "happy path with branch names via environment"

s_repo "release-env"
( cd "$WORK" && seed_branches prod stage )
rc=0
out="$(cd "$WORK" && GIT_RELEASE_PRODUCTION=prod GIT_RELEASE_STAGING=stage git release 2>&1 <<<YES)" || rc=$?
assert_eq "$rc" "0" "env-named release succeeds"
assert_eq "$(git -C "$WORK" rev-parse origin/prod)" "$(git -C "$WORK" rev-parse origin/stage)" \
	"env prod advances to env staging"

t_section "argument validation"

s_repo "release-arg"
( cd "$WORK" && seed_branches main staging )
assert_rc_out "unknown argument rejected" 2 "Unknown argument" \
	bash -c 'cd "$1" && git release --bogus' _ "$WORK" </dev/null

t_section "dirty working tree aborts"

s_repo "release-dirty"
( cd "$WORK" && seed_branches main staging )
( cd "$WORK" && echo dirty >untracked && true )
rc=0
out="$(cd "$WORK" && git release 2>&1 </dev/null)" || rc=$?
assert_eq "$rc" "1" "dirty tree aborts (rc 1)"
assert_contains "$out" "Working directory is dirty" "prints dirty-tree message"

t_section "local commits on prod abort (never auto-pushed)"

s_repo "release-prod-local"
( cd "$WORK" && seed_branches main staging )
# local-only commit on prod
( cd "$WORK" && git checkout -q main && echo b >>f && git commit -qam "localb" && git checkout -q staging )
( cd "$WORK" && s_key )
rc=0
out="$(cd "$WORK" && git release 2>&1 </dev/null)" || rc=$?
assert_eq "$rc" "1" "local prod commits abort (rc 1)"
assert_contains "$out" "ABORT: local branch 'main' has 1 commit" "identifies prod branch"

t_section "local commits on staging abort (never auto-pushed)"

s_repo "release-staging-local"
( cd "$WORK" && seed_branches main staging )
# local-only commit on staging
( cd "$WORK" && echo c >>g && git commit -qam "localc" )
( cd "$WORK" && s_key )
rc=0
out="$(cd "$WORK" && git release 2>&1 </dev/null)" || rc=$?
assert_eq "$rc" "1" "local staging commits abort (rc 1)"
assert_contains "$out" "ABORT: local branch 'staging' has 1 commit" "identifies staging branch"

t_section "--continue: nothing to resume when prod is in sync"

s_repo "release-continue-none"
( cd "$WORK" && seed_branches main staging )
( cd "$WORK" && s_key )
rc=0
out="$(cd "$WORK" && git release --continue 2>&1 </dev/null)" || rc=$?
assert_eq "$rc" "1" "--continue with nothing to resume exits 1"
assert_contains "$out" "Nothing to resume" "prints nothing-to-resume message"

t_section "--continue: resumes a clean fast-forward prod ahead of origin"

s_repo "release-continue-ff"
( cd "$WORK" && seed_branches main staging )
# local prod is a clean fast-forward ahead of origin/prod (the state left by an
# interrupted release that merged but could not push)
( cd "$WORK" && git checkout -q main && echo r >>f && git commit -qam "resume" && git checkout -q staging )
( cd "$WORK" && s_key )
rc=0
out="$(cd "$WORK" && git release --continue 2>&1 <<<YES)" || rc=$?
assert_eq "$rc" "0" "--continue resumes and pushes (rc 0)"
assert_contains "$out" "Resuming" "prints resuming message"
assert_eq "$(git -C "$WORK" rev-parse origin/main)" "$(git -C "$WORK" rev-parse main)" \
	"resume pushed the clean fast-forward"

t_summary
