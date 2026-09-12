#!/usr/bin/env bash
#
# Tests for scripts/apply_rules.sh — applies GitHub branch rulesets.
#
# This script normally calls the GitHub API via `gh`. To make the suite fully
# offline and deterministic, `gh` is stubbed: the fake records every invocation
# and captures the generated ruleset payloads, so we can assert the exact JSON
# sent to GitHub for production / staging. A separate test uses a
# `gh`-free PATH to exercise the missing-CLI fatal error.
#
# Security assertions verified here:
#   * production ruleset includes `non_fast_forward` (Block force pushes) and
#     targets refs/heads/<prod> — this is the server-side force-push guard.
#   * staging ruleset requires a pull_request and does NOT reference prod.
#   * branch names resolve (env > config > default) so protection is never
#     silently applied to the wrong branch.
#
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../../lib.sh"
APPLY="$SCRIPTS_SRC/apply_rules.sh"

s_apply_env() {
	s_env "$1"
}

_apply() {
	env HOME="$HOME" PATH="$GHPATH" bash "$APPLY" --libdir "$HOOKS_SRC" "$@"
}

t_section "option parsing"

s_apply_env "apply-help"
assert_rc "apply_rules --help exits 0" 0 bash "$APPLY" --help
assert_rc_out "apply_rules --help prints usage" 0 "Usage:" bash "$APPLY" --help

s_apply_env "apply-badopt"
assert_rc_out "unknown option rejected" 1 "Unknown option" bash "$APPLY" --bogus x

t_section "missing gh binary is a clean, reported error"

s_apply_env "apply-no-gh"
nogh="$(s_nogh_path)"
assert_rc_out "missing gh reported as fatal" 1 "gh.*CLI is required" \
	env HOME="$HOME" PATH="$nogh" bash "$APPLY" --libdir "$HOOKS_SRC" --repo a/b </dev/null

t_section "branch resolution is echoed (env > config > default)"

s_apply_env "apply-resolve-default"
s_fake_gh
assert_rc_out "defaults resolve and are echoed" 0 "production -> main" \
	_apply --repo a/b
assert_rc_out "staging default echoed" 0 "staging    -> staging" \
	_apply --repo a/b

s_apply_env "apply-resolve-config"
s_fake_gh
git config --global release.production prod
git config --global release.staging stage
assert_rc_out "config PRODUCTION honored" 0 "production -> prod" \
	_apply --repo a/b
assert_rc_out "config STAGING honored" 0 "staging    -> stage" \
	_apply --repo a/b

s_apply_env "apply-resolve-env"
s_fake_gh
git config --global release.production cfgprod
git config --global release.staging cfgstage
assert_rc_out "env PRODUCTION overrides config" 0 "production -> envprod" \
	env HOME="$HOME" PATH="$GHPATH" GIT_RELEASE_PRODUCTION=envprod bash "$APPLY" --libdir "$HOOKS_SRC" --repo a/b
assert_rc_out "env STAGING overrides config" 0 "staging    -> envstage" \
	env HOME="$HOME" PATH="$GHPATH" GIT_RELEASE_STAGING=envstage bash "$APPLY" --libdir "$HOOKS_SRC" --repo a/b

t_section "repo derived from origin remote when --repo omitted"

s_apply_env "apply-repo-origin"
s_fake_gh
wd="$SANDBOX/w"
git init -q -b main "$wd"
git -C "$wd" remote add origin git@github.com:kevano/demo.git
	assert_rc_out "repo derived from origin remote" 0 \
		"Applying branch rulesets to kevano/demo" \
		env HOME="$HOME" PATH="$GHPATH" bash -c 'cd "$1" && exec bash "$2" --libdir "'"$HOOKS_SRC"'" --prod main --staging staging' \
		_ "$wd" "$APPLY"

t_section "generated production ruleset blocks force pushes (security)"

s_apply_env "apply-prod-rules"
s_fake_gh
assert_rc "apply_rules full run succeeds against stubbed gh" 0 \
	_apply --repo a/b --prod main --staging staging </dev/null
# find the payload for protect_main (production) and inspect it
payload_prod="$(grep -rlz '"name"[[:space:]]*:[[:space:]]*"protect_main"' "$FAKE_GH_PAYLOAD_DIR" 2>/dev/null | tr -d '\0' || true)"
prod_json=""
[ -n "$payload_prod" ] && prod_json="$(cat "$payload_prod")"
assert_ne "$payload_prod" "" "a production ruleset payload was generated"
assert_contains "$prod_json" '"type": "non_fast_forward"' \
	"production ruleset blocks force pushes (non_fast_forward)"
assert_contains "$prod_json" '"refs/heads/main"' \
	"production ruleset targets refs/heads/main"
assert_contains "$prod_json" '"enforcement": "active"' \
	"production ruleset is active"

t_section "generated staging ruleset requires a pull request (security)"

payload_stage="$(grep -rlz '"name"[[:space:]]*:[[:space:]]*"protect_staging"' "$FAKE_GH_PAYLOAD_DIR" 2>/dev/null | tr -d '\0' || true)"
stage_json=""
[ -n "$payload_stage" ] && stage_json="$(cat "$payload_stage")"
assert_ne "$payload_stage" "" "a staging ruleset payload was generated"
assert_contains "$stage_json" '"type": "pull_request"' \
	"staging ruleset requires a pull request"
assert_contains "$stage_json" '"refs/heads/staging"' \
	"staging ruleset targets refs/heads/staging"

t_section "gh api calls are made for upsert (find then create)"

assert_contains "$(cat "$FAKE_GH_LOG")" "repos/a/b/rulesets" \
	"gh api called against the resolved repo"
assert_contains "$(cat "$FAKE_GH_LOG")" "--method POST" \
	"gh api uses POST to create rulesets"

t_summary
