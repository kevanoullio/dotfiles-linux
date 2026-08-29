#!/usr/bin/env bash
#
# Tests for the global pre-push hook (git_projects/hooks/pre-push).
#
# The hook is the LOCAL accident-prevention guard for the release workflow:
#   * direct push to STAGING        -> always blocked (use a PR)
#   * direct push to PRODUCTION     -> blocked UNLESS the release bypass key is
#                                        supplied (i.e. via `git release`). When
#                                        no key is configured at all, pushes are
#                                        allowed (the workflow operates
#                                        pre-provisioning with a notice).
#   * any other branch              -> allowed
#
# The first half drives the installed hook directly (fast, precise matrix).
# The second half does real `git push`es against a local bare origin, proving
# git actually wires the hook up via core.hooksPath.
#
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../../lib.sh"

HOOK=""

# hook_rc <remote_ref> <auth(empty=none)> -> prints the hook's exit code
hook_rc() {
	local ref="$1" auth="$2"
	if [ -n "$auth" ]; then
		GIT_RELEASE_AUTH="$auth" bash "$HOOK" <<<"a a $ref a" >/dev/null 2>/dev/null
	else
		bash "$HOOK" <<<"a a $ref a" >/dev/null 2>/dev/null
	fi
	echo $?
}

t_section "direct hook matrix"

s_hooks "hook-matrix"
HOOK="$HOME/.config/git/hooks/pre-push"

assert_eq "$(hook_rc refs/heads/staging '')" "1" "staging push blocked (no key)"
assert_eq "$(hook_rc refs/heads/main '')" "0" "prod push allowed when NO key configured"
assert_eq "$(hook_rc refs/heads/feature/x '')" "0" "feature branch always allowed"

s_key "sekret"
assert_eq "$(hook_rc refs/heads/staging 'sekret')" "1" "staging blocked even with key"
assert_eq "$(hook_rc refs/heads/main '')" "1" "prod blocked without the matching key"
assert_eq "$(hook_rc refs/heads/main 'wrong')" "1" "prod blocked with a wrong key"
assert_eq "$(hook_rc refs/heads/main 'sekret')" "0" "prod allowed with the matching key"
assert_eq "$(hook_rc refs/heads/feature 'sekret')" "0" "feature allowed with key present"

t_section "real push: staging is blocked"

s_repo "hook-real-staging"
( cd "$WORK" && s_key sekret )
( cd "$WORK" && echo one >f && git add f && git commit -qm one )
rc=0
out="$(cd "$WORK" && GIT_RELEASE_AUTH=sekret git push origin HEAD:refs/heads/staging 2>&1)" || rc=$?
assert_ne "$rc" "0" "direct staging push fails"
assert_contains "$out" "blocked locally" "hook reports the block"

t_section "real push: prod blocked without the key"

s_repo "hook-real-prod-block"
( cd "$WORK" && s_key sekret )
( cd "$WORK" && echo one >f && git add f && git commit -qm one && s_push_bypass main )
( cd "$WORK" && git checkout -qb staging && echo two >g && git add g && git commit -qm two && s_push_bypass staging )
( cd "$WORK" && git checkout -q main && echo b >h && git commit -qam b )
rc=0
out="$(cd "$WORK" && git push origin main 2>&1)" || rc=$?
assert_ne "$rc" "0" "prod push without key fails"
assert_contains "$out" "blocked locally" "hook reports the block for prod"

t_section "real push: prod allowed with the key"

rc=0
out="$(cd "$WORK" && GIT_RELEASE_AUTH=sekret git push origin main 2>&1)" || rc=$?
assert_eq "$rc" "0" "prod push with matching key succeeds"
assert_eq "$(git -C "$WORK" rev-parse origin/main)" "$(git -C "$WORK" rev-parse main)" \
	"origin/main advanced after authorized push"

t_summary
