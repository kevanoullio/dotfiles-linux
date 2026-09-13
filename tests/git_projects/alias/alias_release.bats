#!/usr/bin/env bats
#
# Integration tests for the `release` alias workflow (git_projects/release.gitconfig).
#
# Runs `git release` end-to-end against a local bare origin, exercising the
# protected push through the real global pre-push hook (via core.hooksPath) and
# the shared release-common.sh library.

load ../../helpers/sandbox.bash

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

@test "happy path: staging fast-forwards into prod (default names)" {
	s_repo "release-happy"
	( cd "$WORK" && seed_branches main staging )
	( cd "$WORK" && s_key )
	run bash -c 'cd "$1" && git release <<<YES' _ "$WORK"
	[ "$status" -eq 0 ]
	[[ "$output" == *"Production fast-forward merge successful!"* ]]
	[ "$(git -C "$WORK" rev-parse origin/main)" = "$(git -C "$WORK" rev-parse origin/staging)" ]
	[ "$(git -C "$WORK" rev-parse main)" = "$(git -C "$WORK" rev-parse origin/main)" ]
	[ "$(git -C "$WORK" branch --show-current)" = "staging" ]
}

@test "happy path with custom branch names (git config)" {
	s_repo "release-config"
	( cd "$WORK" && git config release.production prod )
	( cd "$WORK" && git config release.staging staging )
	( cd "$WORK" && seed_branches prod staging )
	( cd "$WORK" && s_key )
	run bash -c 'cd "$1" && git release <<<YES' _ "$WORK"
	[ "$status" -eq 0 ]
	[ "$(git -C "$WORK" rev-parse origin/prod)" = "$(git -C "$WORK" rev-parse origin/staging)" ]
}

@test "happy path with branch names via environment" {
	s_repo "release-env"
	( cd "$WORK" && seed_branches prod stage )
	run bash -c 'cd "$1" && GIT_RELEASE_PRODUCTION=prod GIT_RELEASE_STAGING=stage git release <<<YES' _ "$WORK"
	[ "$status" -eq 0 ]
	[ "$(git -C "$WORK" rev-parse origin/prod)" = "$(git -C "$WORK" rev-parse origin/stage)" ]
}

@test "unknown argument rejected" {
	s_repo "release-arg"
	( cd "$WORK" && seed_branches main staging )
	run bash -c 'cd "$1" && git release --bogus' _ "$WORK"
	[ "$status" -eq 2 ]
	[[ "$output" == *"Unknown argument"* ]]
}

@test "dirty working tree aborts" {
	s_repo "release-dirty"
	( cd "$WORK" && seed_branches main staging )
	( cd "$WORK" && echo dirty >untracked )
	run bash -c 'cd "$1" && git release' _ "$WORK" </dev/null
	[ "$status" -eq 1 ]
	[[ "$output" == *"Working directory is dirty"* ]]
}

@test "local commits on prod abort (never auto-pushed)" {
	s_repo "release-prod-local"
	( cd "$WORK" && seed_branches main staging )
	( cd "$WORK" && git checkout -q main && echo b >>f && git commit -qam "localb" && git checkout -q staging )
	( cd "$WORK" && s_key )
	run bash -c 'cd "$1" && git release' _ "$WORK" </dev/null
	[ "$status" -eq 1 ]
	[[ "$output" == *"ABORT: local branch 'main' has 1 commit"* ]]
}

@test "local commits on staging abort (never auto-pushed)" {
	s_repo "release-staging-local"
	( cd "$WORK" && seed_branches main staging )
	( cd "$WORK" && echo c >>g && git commit -qam "localc" )
	( cd "$WORK" && s_key )
	run bash -c 'cd "$1" && git release' _ "$WORK" </dev/null
	[ "$status" -eq 1 ]
	[[ "$output" == *"ABORT: local branch 'staging' has 1 commit"* ]]
}

@test "--continue: nothing to resume when prod is in sync" {
	s_repo "release-continue-none"
	( cd "$WORK" && seed_branches main staging )
	( cd "$WORK" && s_key )
	run bash -c 'cd "$1" && git release --continue' _ "$WORK" </dev/null
	[ "$status" -eq 1 ]
	[[ "$output" == *"Nothing to resume"* ]]
}

@test "--continue: resumes a clean fast-forward prod ahead of origin" {
	s_repo "release-continue-ff"
	( cd "$WORK" && seed_branches main staging )
	( cd "$WORK" && git checkout -q main && echo r >>f && git commit -qam "resume" && git checkout -q staging )
	( cd "$WORK" && s_key )
	run bash -c 'cd "$1" && git release --continue <<<YES' _ "$WORK"
	[ "$status" -eq 0 ]
	[[ "$output" == *"Resuming"* ]]
	[ "$(git -C "$WORK" rev-parse origin/main)" = "$(git -C "$WORK" rev-parse main)" ]
}
