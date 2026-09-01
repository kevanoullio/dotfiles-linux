#!/bin/bash
#
# release-common.sh
#
# Shared helper for the `git release` fast-forward workflow. Sourced by both the
# global `release` alias (git_projects/release.gitconfig) and the global
# `pre-push` hook (git_projects/hooks/pre-push) so that branch-name resolution
# and the release bypass key are ALWAYS identical between them.
#
# Resolution order for branch names (highest precedence first):
#   1. GIT_RELEASE_PRODUCTION / GIT_RELEASE_STAGING  (environment)
#   2. git config release.production / release.staging
#        - repo-local (.git/config)        -> per-repo override
#        - global  (~/.gitconfig)          -> machine default
#   3. hardcoded defaults: main / staging
#
# git config is layered, so `git config <key>` already returns the most
# specific value defined in system/global/local scope.
#
# Resolution order for the release bypass key (highest precedence first):
#   1. GIT_RELEASE_KEY  (environment)
#   2. key file         (~/.config/git/release-key, mode 0600)
#
# The `release` alias reads this key and exports it as GIT_RELEASE_AUTH before
# pushing. The pre-push hook only permits a direct push to the production branch
# when GIT_RELEASE_AUTH matches the configured key. Because the value is stored
# in a private file (never an obvious boolean flag), it prevents *accidental*
# direct/force pushes outside of `git release`.
#
# NOTE: This is a local, client-side guard intended to prevent accidents. It is
# bypassable (e.g. `git push --no-verify`) and is NOT server-side security.
# Real force-push protection for the production branch lives in the GitHub
# "Block force pushes" (non_fast_forward) branch rule.

# Validate a branch name: must match ^[A-Za-z0-9._/\+@-]+$ (no shell metacharacters).
# Usage: validate_branch_name <name>
validate_branch_name() {
	if ! printf '%s\n' "$1" | grep -Eq '^[A-Za-z0-9._/\+@-]+$'; then
		return 1
	fi
}

# Resolve a branch name using the cascade above.
# Usage: release_branch <prod|staging>
release_branch() {
	local _name
	case "$1" in
		prod)
			if [ -n "${GIT_RELEASE_PRODUCTION:-}" ]; then
				_name="$GIT_RELEASE_PRODUCTION"
			elif [ -z "${GIT_RELEASE_PRODUCTION:-}" ] && [ -n "${GIT_RELEASE_PRODUCTION+x}" ]; then
				echo "ERROR: GIT_RELEASE_PRODUCTION is set but empty." >&2
				return 1
			elif git config --get release.production >/dev/null 2>&1; then
				_name="$(git config --get release.production)"
			else
				_name="${RELEASE_DEFAULT_PRODUCTION:-main}"
			fi
			;;
		staging)
			if [ -n "${GIT_RELEASE_STAGING:-}" ]; then
				_name="$GIT_RELEASE_STAGING"
			elif [ -z "${GIT_RELEASE_STAGING:-}" ] && [ -n "${GIT_RELEASE_STAGING+x}" ]; then
				echo "ERROR: GIT_RELEASE_STAGING is set but empty." >&2
				return 1
			elif git config --get release.staging >/dev/null 2>&1; then
				_name="$(git config --get release.staging)"
			else
				_name="${RELEASE_DEFAULT_STAGING:-staging}"
			fi
			;;
		*) return 2 ;;
	esac
	# Sanitize: reject branch names containing shell metacharacters.
	if ! validate_branch_name "$_name"; then
		echo "ERROR: branch name '$_name' contains disallowed characters." >&2
		return 1
	fi
	printf '%s\n' "$_name"
}

# Absolute path to the release key file.
release_key_file() {
	printf '%s/.config/git/release-key\n' "${HOME:?}"
}

# Print the configured release key (env override, then key file), or nothing.
# Usage: RELEASE_KEY=$(release_read_key)
release_read_key() {
	if [ -n "${GIT_RELEASE_KEY:-}" ]; then
		printf '%s\n' "$GIT_RELEASE_KEY"
		return 0
	fi
	_key_file=$(release_key_file)
	if [ -f "$_key_file" ]; then
		cat "$_key_file"
		return 0
	fi
	return 1
}

# Exit 0 if a release bypass key is configured at all (file or env).
release_key_configured() {
	if [ -n "${GIT_RELEASE_KEY:-}" ]; then
		return 0
	fi
	[ -f "$(release_key_file)" ]
}

# Exit 0 if GIT_RELEASE_AUTH matches the configured key (i.e. this push is an
# authorized `git release`), or if NO key is configured at all (allows the
# workflow to still work pre-provisioning with an explicit notice).
release_bypass_allowed() {
	if ! release_key_configured; then
		return 0
	fi
	_expected=$(release_read_key)
	[ -n "$_expected" ] && [ "${GIT_RELEASE_AUTH:-}" = "$_expected" ]
}
