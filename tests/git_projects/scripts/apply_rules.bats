#!/usr/bin/env bats
#
# Tests for scripts/apply_rules.sh — applies GitHub branch rulesets.
#
# This script normally calls the GitHub API via `gh`. To make the suite fully
# offline and deterministic, `gh` is stubbed: the fake records every invocation
# and captures the generated ruleset payloads, so we can assert the exact JSON
# sent to GitHub for production / staging. A separate test uses a
# `gh`-free PATH to exercise the missing-CLI fatal error.

load ../../helpers/sandbox.bash

APPLY="$SCRIPTS_SRC/apply_rules.sh"

_apply() {
	env HOME="$HOME" PATH="$GHPATH" bash "$APPLY" --libdir "$HOOKS_SRC" "$@"
}

@test "apply_rules --help exits 0 and prints usage" {
	s_env "apply-help"
	run bash "$APPLY" --help
	[ "$status" -eq 0 ]
	[[ "$output" == *"Usage:"* ]]
}

@test "unknown option rejected" {
	s_env "apply-badopt"
	run bash "$APPLY" --bogus x
	[ "$status" -eq 1 ]
	[[ "$output" == *"Unknown option"* ]]
}

@test "missing gh binary is a clean, reported error" {
	s_env "apply-no-gh"
	nogh="$(s_nogh_path)"
	run env HOME="$HOME" PATH="$nogh" bash "$APPLY" --libdir "$HOOKS_SRC" --repo a/b </dev/null
	[ "$status" -eq 1 ]
	[[ "$output" == *"gh"*"CLI is required"* ]]
}

@test "branch resolution: defaults resolve and are echoed" {
	s_env "apply-resolve-default"
	s_fake_gh
	run _apply --repo a/b
	[ "$status" -eq 0 ]
	[[ "$output" == *"production -> main"* ]]
	[[ "$output" == *"staging    -> staging"* ]]
}

@test "branch resolution: config values honored" {
	s_env "apply-resolve-config"
	s_fake_gh
	git config --global release.production prod
	git config --global release.staging stage
	run _apply --repo a/b
	[ "$status" -eq 0 ]
	[[ "$output" == *"production -> prod"* ]]
	[[ "$output" == *"staging    -> stage"* ]]
}

@test "branch resolution: env overrides config" {
	s_env "apply-resolve-env"
	s_fake_gh
	git config --global release.production cfgprod
	git config --global release.staging cfgstage
	run env HOME="$HOME" PATH="$GHPATH" GIT_RELEASE_PRODUCTION=envprod bash "$APPLY" --libdir "$HOOKS_SRC" --repo a/b
	[ "$status" -eq 0 ]
	[[ "$output" == *"production -> envprod"* ]]
	run env HOME="$HOME" PATH="$GHPATH" GIT_RELEASE_STAGING=envstage bash "$APPLY" --libdir "$HOOKS_SRC" --repo a/b
	[ "$status" -eq 0 ]
	[[ "$output" == *"staging    -> envstage"* ]]
}

@test "repo derived from origin remote when --repo omitted" {
	s_env "apply-repo-origin"
	s_fake_gh
	wd="$SANDBOX/w"
	git init -q -b main "$wd"
	git -C "$wd" remote add origin git@github.com:kevano/demo.git
	run env HOME="$HOME" PATH="$GHPATH" bash -c 'cd "$1" && exec bash "$2" --libdir "'"$HOOKS_SRC"'" --prod main --staging staging' _ "$wd" "$APPLY"
	[ "$status" -eq 0 ]
	[[ "$output" == *"Applying branch rulesets to kevano/demo"* ]]
}

@test "generated rulesets: production blocks force pushes, staging requires PR" {
	s_env "apply-prod-rules"
	s_fake_gh
	run _apply --repo a/b --prod main --staging staging </dev/null
	[ "$status" -eq 0 ]

	payload_prod="$(grep -rlz '"name"[[:space:]]*:[[:space:]]*"protect_main"' "$FAKE_GH_PAYLOAD_DIR" 2>/dev/null | tr -d '\0' || true)"
	[ -n "$payload_prod" ]
	prod_json="$(cat "$payload_prod")"
	[[ "$prod_json" == *non_fast_forward* ]]
	[[ "$prod_json" == *refs/heads/main* ]]
	[[ "$prod_json" == *enforcement*active* ]]

	payload_stage="$(grep -rlz '"name"[[:space:]]*:[[:space:]]*"protect_staging"' "$FAKE_GH_PAYLOAD_DIR" 2>/dev/null | tr -d '\0' || true)"
	[ -n "$payload_stage" ]
	stage_json="$(cat "$payload_stage")"
	[[ "$stage_json" == *pull_request* ]]
	[[ "$stage_json" == *refs/heads/staging* ]]

	gh_log="$(cat "$FAKE_GH_LOG")"
	[[ "$gh_log" == *"repos/a/b/rulesets"* ]]
	[[ "$gh_log" == *"--method POST"* ]]
}
