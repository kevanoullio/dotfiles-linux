#!/usr/bin/env bats
#
# Tests for the global pre-push hook (git_projects/hooks/pre-push).
#
# The hook is the LOCAL accident-prevention guard for the release workflow:
#   * direct push to STAGING        -> always blocked (use a PR)
#   * direct push to PRODUCTION     -> blocked UNLESS the release bypass key is
#                                        supplied. When no key is configured at
#                                        all, pushes are allowed.
#   * any other branch              -> allowed

load ../../helpers/sandbox.bash

HOOK=""

setup() {
	s_hooks "hook-matrix"
	HOOK="$HOME/.config/git/hooks/pre-push"
}

@test "staging push blocked (no key)" {
	run bash -c 'bash "$1" <<<"a a refs/heads/staging a"' _ "$HOOK"
	[ "$status" -eq 1 ]
}

@test "prod push allowed when NO key configured" {
	run bash -c 'bash "$1" <<<"a a refs/heads/main a"' _ "$HOOK"
	[ "$status" -eq 0 ]
}

@test "feature branch always allowed" {
	run bash -c 'bash "$1" <<<"a a refs/heads/feature/x a"' _ "$HOOK"
	[ "$status" -eq 0 ]
}

@test "staging blocked even with key" {
	s_key "sekret"
	run bash -c 'GIT_RELEASE_AUTH=sekret bash "$1" <<<"a a refs/heads/staging a"' _ "$HOOK"
	[ "$status" -eq 1 ]
}

@test "prod blocked without the matching key" {
	s_key "sekret"
	run bash -c 'bash "$1" <<<"a a refs/heads/main a"' _ "$HOOK"
	[ "$status" -eq 1 ]
}

@test "prod blocked with a wrong key" {
	s_key "sekret"
	run bash -c 'GIT_RELEASE_AUTH=wrong bash "$1" <<<"a a refs/heads/main a"' _ "$HOOK"
	[ "$status" -eq 1 ]
}

@test "prod allowed with the matching key" {
	s_key "sekret"
	run bash -c 'GIT_RELEASE_AUTH=sekret bash "$1" <<<"a a refs/heads/main a"' _ "$HOOK"
	[ "$status" -eq 0 ]
}

@test "feature allowed with key present" {
	s_key "sekret"
	run bash -c 'GIT_RELEASE_AUTH=sekret bash "$1" <<<"a a refs/heads/feature a"' _ "$HOOK"
	[ "$status" -eq 0 ]
}

@test "real push: staging is blocked" {
	s_repo "hook-real-staging"
	( cd "$WORK" && s_key sekret )
	( cd "$WORK" && echo one >f && git add f && git commit -qm one )
	run bash -c 'cd "$1" && GIT_RELEASE_AUTH=sekret git push origin HEAD:refs/heads/staging' _ "$WORK"
	[ "$status" -ne 0 ]
	[[ "$output" == *"blocked locally"* ]]
}

@test "real push: prod blocked without key, allowed with key" {
	s_repo "hook-real-prod-block"
	( cd "$WORK" && s_key sekret )
	( cd "$WORK" && echo one >f && git add f && git commit -qm one && s_push_bypass main )
	( cd "$WORK" && git checkout -qb staging && echo two >g && git add g && git commit -qm two && s_push_bypass staging )
	( cd "$WORK" && git checkout -q main && echo b >>f && git commit -qam b )

	run bash -c 'cd "$1" && git push origin main' _ "$WORK"
	[ "$status" -ne 0 ]
	[[ "$output" == *"blocked locally"* ]]

	run bash -c 'cd "$1" && GIT_RELEASE_AUTH=sekret git push origin main' _ "$WORK"
	[ "$status" -eq 0 ]
	[ "$(git -C "$WORK" rev-parse origin/main)" = "$(git -C "$WORK" rev-parse main)" ]
}
