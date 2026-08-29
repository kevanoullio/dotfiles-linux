#!/usr/bin/env bash
#
# Unit tests for git_projects/hooks/release-common.sh
#
# Focuses on the shared branch-name resolution cascade and the release-key /
# bypass logic, since these govern BOTH the `release` alias and the `pre-push`
# hook. If these two ever disagree, a release key or a protected branch could
# be handled inconsistently — a security concern. These tests pin that down.
#
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../../lib.sh"

RC="$GPROOT/git_projects/hooks/release-common.sh"

t_section "release_branch: production resolution (env > config > default)"

s_env "common-prod-default"
. "$RC"
assert_eq "$(release_branch prod)" "main" "prod defaults to main"

s_env "common-prod-config"
git config --global release.production "prod-g"
. "$RC"
assert_eq "$(release_branch prod)" "prod-g" "prod picks up global config"

s_env "common-prod-env"
git config --global release.production "prod-g"
. "$RC"
assert_eq "$(GIT_RELEASE_PRODUCTION=prod-e release_branch prod)" "prod-e" \
	"prod env var beats config"

t_section "release_branch: staging resolution (env > config > default)"

s_env "common-staging-default"
. "$RC"
assert_eq "$(release_branch staging)" "staging" "staging defaults to staging"

s_env "common-staging-config"
git config --global release.staging "stage-g"
. "$RC"
assert_eq "$(release_branch staging)" "stage-g" "staging picks up global config"

s_env "common-staging-env"
git config --global release.staging "stage-g"
. "$RC"
assert_eq "$(GIT_RELEASE_STAGING=stage-e release_branch staging)" "stage-e" \
	"staging env var beats config"

t_section "release_branch: custom defaults via env"

s_env "common-custom-default"
git config --global --unset release.production 2>/dev/null || true
git config --global --unset release.staging 2>/dev/null || true
. "$RC"
assert_eq "$(RELEASE_DEFAULT_PRODUCTION=prodX release_branch prod)" "prodX" \
	"RELEASE_DEFAULT_PRODUCTION honored"
assert_eq "$(RELEASE_DEFAULT_STAGING=stageX release_branch staging)" "stageX" \
	"RELEASE_DEFAULT_STAGING honored"

t_section "release_branch: invalid argument"

s_env "common-invalid"
. "$RC"
assert_rc "invalid arg returns 2" 2 bash -c '. "$1"; release_branch bogus' _ "$RC"

t_section "release_branch: branch name sanitization"

s_env "sanitize-good-main"
git config --global --unset release.production 2>/dev/null || true
git config --global --unset release.staging 2>/dev/null || true
. "$RC"
assert_eq "$(release_branch prod)" "main" "default prod 'main' passes"
assert_eq "$(release_branch staging)" "staging" "default staging 'staging' passes"

s_env "sanitize-good-custom"
git config --global release.production "release/v1.0"
git config --global release.staging "feature/test-branch"
. "$RC"
assert_eq "$(release_branch prod)" "release/v1.0" "hyphenated prod name passes"
assert_eq "$(release_branch staging)" "feature/test-branch" "slash in staging name passes"

s_env "sanitize-bad-semi"
git config --global release.production "main;rm -rf /"
. "$RC"
assert_rc "semicolon in branch name rejected" 1 bash -c '. "$1"; release_branch prod' _ "$RC"

s_env "sanitize-bad-dquote"
git config --global release.production 'main$(whoami)'
. "$RC"
assert_rc "dollar-sign in branch name rejected" 1 bash -c '. "$1"; release_branch prod' _ "$RC"

s_env "sanitize-bad-backtick"
git config --global release.production 'main`id`'
. "$RC"
assert_rc "backtick in branch name rejected" 1 bash -c '. "$1"; release_branch prod' _ "$RC"

s_env "sanitize-bad-ampersand"
git config --global release.production 'main&cat /etc/passwd'
. "$RC"
assert_rc "ampersand in branch name rejected" 1 bash -c '. "$1"; release_branch prod' _ "$RC"

s_env "sanitize-bad-pipe"
git config --global release.production 'main|cat /etc/passwd'
. "$RC"
assert_rc "pipe in branch name rejected" 1 bash -c '. "$1"; release_branch prod' _ "$RC"

s_env "sanitize-bad-redirect"
git config --global release.production 'main>evil'
. "$RC"
assert_rc "redirect in branch name rejected" 1 bash -c '. "$1"; release_branch prod' _ "$RC"

s_env "sanitize-bad-env"
. "$RC"
assert_rc "empty env var for prod rejected" 1 bash -c '. "$1"; GIT_RELEASE_PRODUCTION="" release_branch prod' _ "$RC"

s_env "sanitize-good-env"
. "$RC"
assert_eq "$(GIT_RELEASE_PRODUCTION=prod-name GIT_RELEASE_STAGING=stage_v2 release_branch prod)" "prod-name" "env prod passes"
assert_eq "$(GIT_RELEASE_PRODUCTION=prod-name GIT_RELEASE_STAGING=stage_v2 release_branch staging)" "stage_v2" "env staging passes"

# Clean up global config to avoid leaking into later test sections
git config --global --unset release.production 2>/dev/null || true
git config --global --unset release.staging 2>/dev/null || true

t_section "release key file path"

s_env "common-keyfile"
. "$RC"
assert_eq "$(release_key_file)" "$HOME/.config/git/release-key" \
	"release_key_file is \$HOME/.config/git/release-key"

t_section "release_read_key: env override, file, precedence"

s_env "common-read-env"
. "$RC"
assert_eq "$(GIT_RELEASE_KEY=envkey release_read_key)" "envkey" \
	"reads key from GIT_RELEASE_KEY"

s_env "common-read-file"
s_key "filekey"
. "$RC"
assert_eq "$(release_read_key)" "filekey" "reads key from key file"

s_env "common-read-both"
s_key "filekey"
. "$RC"
assert_eq "$(GIT_RELEASE_KEY=envkey release_read_key)" "envkey" \
	"GIT_RELEASE_KEY wins over key file"

s_env "common-read-none"
. "$RC"
rc=0
out="$(release_read_key 2>/dev/null)" || rc=$?
assert_eq "${out:-}" "" "no key -> empty output"
assert_eq "$rc" "1" "no key -> rc 1"

t_section "release_key_configured"

s_env "common-cfg-none"
. "$RC"
assert_rc "no key -> not configured (rc 1)" 1 bash -c '. "$1"; release_key_configured' _ "$RC"

s_env "common-cfg-env"
. "$RC"
assert_rc "env key -> configured (rc 0)" 0 bash -c '. "$1"; GIT_RELEASE_KEY=k release_key_configured' _ "$RC"

s_env "common-cfg-file"
s_key "filekey"
. "$RC"
assert_rc "file key -> configured (rc 0)" 0 bash -c '. "$1"; release_key_configured' _ "$RC"

t_section "release_bypass_allowed"

s_env "common-bypass-none"
. "$RC"
assert_rc "no key configured -> allowed (rc 0)" 0 bash -c '. "$1"; release_bypass_allowed' _ "$RC"

s_env "common-bypass-match"
s_key "sekret"
. "$RC"
assert_rc "matching GIT_RELEASE_AUTH -> allowed" 0 \
	bash -c '. "$1"; GIT_RELEASE_AUTH=sekret release_bypass_allowed' _ "$RC"

s_env "common-bypass-mismatch"
s_key "sekret"
. "$RC"
assert_rc "wrong GIT_RELEASE_AUTH -> denied (rc 1)" 1 \
	bash -c '. "$1"; GIT_RELEASE_AUTH=wrong release_bypass_allowed' _ "$RC"

s_env "common-bypass-auth-env-key"
. "$RC"
assert_rc "env key + matching auth -> allowed" 0 \
	bash -c '. "$1"; GIT_RELEASE_KEY=k GIT_RELEASE_AUTH=k release_bypass_allowed' _ "$RC"

t_summary
