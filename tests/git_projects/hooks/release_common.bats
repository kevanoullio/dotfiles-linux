#!/usr/bin/env bats
#
# Unit tests for git_projects/hooks/release-common.sh
#
# Focuses on the shared branch-name resolution cascade and the release-key /
# bypass logic, since these govern BOTH the `release` alias and the `pre-push`
# hook. If these two ever disagree, a release key or a protected branch could
# be handled inconsistently — a security concern. These tests pin that down.

load ../../helpers/sandbox.bash

RC="$GPROOT/git_projects/hooks/release-common.sh"

@test "release_branch: prod defaults to main" {
	s_env "common-prod-default"
	. "$RC"
	[ "$(release_branch prod)" = "main" ]
}

@test "release_branch: prod picks up global config" {
	s_env "common-prod-config"
	git config --global release.production "prod-g"
	. "$RC"
	[ "$(release_branch prod)" = "prod-g" ]
}

@test "release_branch: prod env var beats config" {
	s_env "common-prod-env"
	git config --global release.production "prod-g"
	. "$RC"
	[ "$(GIT_RELEASE_PRODUCTION=prod-e release_branch prod)" = "prod-e" ]
}

@test "release_branch: staging defaults to staging" {
	s_env "common-staging-default"
	. "$RC"
	[ "$(release_branch staging)" = "staging" ]
}

@test "release_branch: staging picks up global config" {
	s_env "common-staging-config"
	git config --global release.staging "stage-g"
	. "$RC"
	[ "$(release_branch staging)" = "stage-g" ]
}

@test "release_branch: staging env var beats config" {
	s_env "common-staging-env"
	git config --global release.staging "stage-g"
	. "$RC"
	[ "$(GIT_RELEASE_STAGING=stage-e release_branch staging)" = "stage-e" ]
}

@test "release_branch: custom defaults via env" {
	s_env "common-custom-default"
	git config --global --unset release.production 2>/dev/null || true
	git config --global --unset release.staging 2>/dev/null || true
	. "$RC"
	[ "$(RELEASE_DEFAULT_PRODUCTION=prodX release_branch prod)" = "prodX" ]
	[ "$(RELEASE_DEFAULT_STAGING=stageX release_branch staging)" = "stageX" ]
}

@test "release_branch: invalid argument returns 2" {
	s_env "common-invalid"
	. "$RC"
	run bash -c '. "$1"; release_branch bogus' _ "$RC"
	[ "$status" -eq 2 ]
}

@test "release_branch: valid branch names pass sanitization" {
	s_env "sanitize-good-main"
	git config --global --unset release.production 2>/dev/null || true
	git config --global --unset release.staging 2>/dev/null || true
	. "$RC"
	[ "$(release_branch prod)" = "main" ]
	[ "$(release_branch staging)" = "staging" ]

	s_env "sanitize-good-custom"
	git config --global release.production "release/v1.0"
	git config --global release.staging "feature/test-branch"
	. "$RC"
	[ "$(release_branch prod)" = "release/v1.0" ]
	[ "$(release_branch staging)" = "feature/test-branch" ]

	s_env "sanitize-good-env"
	. "$RC"
	[ "$(GIT_RELEASE_PRODUCTION=prod-name GIT_RELEASE_STAGING=stage_v2 release_branch prod)" = "prod-name" ]
	[ "$(GIT_RELEASE_PRODUCTION=prod-name GIT_RELEASE_STAGING=stage_v2 release_branch staging)" = "stage_v2" ]
}

@test "release_branch: shell metacharacters in branch names are rejected" {
	s_env "sanitize-bad-semi"
	git config --global release.production "main;rm -rf /"
	. "$RC"
	run bash -c '. "$1"; release_branch prod' _ "$RC"
	[ "$status" -eq 1 ]

	s_env "sanitize-bad-dquote"
	git config --global release.production 'main$(whoami)'
	. "$RC"
	run bash -c '. "$1"; release_branch prod' _ "$RC"
	[ "$status" -eq 1 ]

	s_env "sanitize-bad-backtick"
	git config --global release.production 'main`id`'
	. "$RC"
	run bash -c '. "$1"; release_branch prod' _ "$RC"
	[ "$status" -eq 1 ]

	s_env "sanitize-bad-ampersand"
	git config --global release.production 'main&cat /etc/passwd'
	. "$RC"
	run bash -c '. "$1"; release_branch prod' _ "$RC"
	[ "$status" -eq 1 ]

	s_env "sanitize-bad-pipe"
	git config --global release.production 'main|cat /etc/passwd'
	. "$RC"
	run bash -c '. "$1"; release_branch prod' _ "$RC"
	[ "$status" -eq 1 ]

	s_env "sanitize-bad-redirect"
	git config --global release.production 'main>evil'
	. "$RC"
	run bash -c '. "$1"; release_branch prod' _ "$RC"
	[ "$status" -eq 1 ]
}

@test "release_branch: empty env var for prod is rejected" {
	s_env "sanitize-bad-env"
	. "$RC"
	run bash -c '. "$1"; GIT_RELEASE_PRODUCTION="" release_branch prod' _ "$RC"
	[ "$status" -eq 1 ]
}

@test "release_key_file returns the expected path" {
	s_env "common-keyfile"
	. "$RC"
	[ "$(release_key_file)" = "$HOME/.config/git/release-key" ]
}

@test "release_read_key: reads from GIT_RELEASE_KEY env var" {
	s_env "common-read-env"
	. "$RC"
	[ "$(GIT_RELEASE_KEY=envkey release_read_key)" = "envkey" ]
}

@test "release_read_key: reads from key file" {
	s_env "common-read-file"
	s_key "filekey"
	. "$RC"
	[ "$(release_read_key)" = "filekey" ]
}

@test "release_read_key: GIT_RELEASE_KEY wins over key file" {
	s_env "common-read-both"
	s_key "filekey"
	. "$RC"
	[ "$(GIT_RELEASE_KEY=envkey release_read_key)" = "envkey" ]
}

@test "release_read_key: no key returns empty with rc 1" {
	s_env "common-read-none"
	. "$RC"
	run release_read_key
	[ "$status" -eq 1 ]
	[ -z "${output:-}" ]
}

@test "release_key_configured: no key -> not configured (rc 1)" {
	s_env "common-cfg-none"
	. "$RC"
	run bash -c '. "$1"; release_key_configured' _ "$RC"
	[ "$status" -eq 1 ]
}

@test "release_key_configured: env key -> configured (rc 0)" {
	s_env "common-cfg-env"
	. "$RC"
	run bash -c '. "$1"; GIT_RELEASE_KEY=k release_key_configured' _ "$RC"
	[ "$status" -eq 0 ]
}

@test "release_key_configured: file key -> configured (rc 0)" {
	s_env "common-cfg-file"
	s_key "filekey"
	. "$RC"
	run bash -c '. "$1"; release_key_configured' _ "$RC"
	[ "$status" -eq 0 ]
}

@test "release_bypass_allowed: no key configured -> allowed" {
	s_env "common-bypass-none"
	. "$RC"
	run bash -c '. "$1"; release_bypass_allowed' _ "$RC"
	[ "$status" -eq 0 ]
}

@test "release_bypass_allowed: matching GIT_RELEASE_AUTH -> allowed" {
	s_env "common-bypass-match"
	s_key "sekret"
	. "$RC"
	run bash -c '. "$1"; GIT_RELEASE_AUTH=sekret release_bypass_allowed' _ "$RC"
	[ "$status" -eq 0 ]
}

@test "release_bypass_allowed: wrong GIT_RELEASE_AUTH -> denied" {
	s_env "common-bypass-mismatch"
	s_key "sekret"
	. "$RC"
	run bash -c '. "$1"; GIT_RELEASE_AUTH=wrong release_bypass_allowed' _ "$RC"
	[ "$status" -eq 1 ]
}

@test "release_bypass_allowed: env key + matching auth -> allowed" {
	s_env "common-bypass-auth-env-key"
	. "$RC"
	run bash -c '. "$1"; GIT_RELEASE_KEY=k GIT_RELEASE_AUTH=k release_bypass_allowed' _ "$RC"
	[ "$status" -eq 0 ]
}
