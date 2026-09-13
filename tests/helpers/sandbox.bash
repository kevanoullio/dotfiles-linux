# tests/helpers/sandbox.bash — shared sandbox builders for the BATS git_projects suite.
#
# Loaded via `load ../helpers/sandbox.bash` in each .bats file.
# Provides isolated $HOME, global git config, hooks, release.libdir, and
# bare origin + work repo so tests never touch the developer's real config.

# --- Paths to the code under test (repo-relative, resolved at load time) ---
readonly GPROOT="$(cd "$(dirname "${BATS_TEST_FILENAME}")/../../.." && pwd)"
readonly HOOKS_SRC="$GPROOT/git_projects/hooks"
readonly GITCONFIG_SRC="$GPROOT/git_projects/release.gitconfig"
readonly SCRIPTS_SRC="$GPROOT/git_projects/scripts"
readonly BRANCH_RULES_SRC="$GPROOT/git_projects/github/branch_rules"

# Global-ish names handed to helpers.
SANDBOX=""
ORIGIN=""
WORK=""
_sbid=0

# ---------------------------------------------------------------------------
# Sandbox builders
# ---------------------------------------------------------------------------

# s_env <name> — isolated environment only: fresh $HOME + core git identity.
# Does NOT install the hooks/libdir; use s_hooks for workflow tests.
s_env() {
	_sbid=$((_sbid + 1))
	SANDBOX="$BATS_TEST_TMPDIR/$1-$_sbid"
	rm -rf "$SANDBOX"
	mkdir -p "$SANDBOX/home/.config/git"

	export HOME="$SANDBOX/home"
	export GIT_CONFIG_GLOBAL="$HOME/.config/git/config"
	unset XDG_CONFIG_HOME

	: >"$GIT_CONFIG_GLOBAL"
	git config --file "$GIT_CONFIG_GLOBAL" user.name "Test User"
	git config --file "$GIT_CONFIG_GLOBAL" user.email "test@example.com"
	git config --file "$GIT_CONFIG_GLOBAL" init.defaultBranch main
	git config --file "$GIT_CONFIG_GLOBAL" --add safe.directory '*'
}

# s_hooks <name> — like s_env, and additionally installs the repo's hooks/ dir
# as the global hooksPath, points release.libdir at it, and includes the repo's
# .gitconfig (so the `release` alias resolves).
s_hooks() {
	s_env "$1"
	cp -R "$HOOKS_SRC" "$HOME/.config/git/hooks"
	chmod +x "$HOME/.config/git/hooks/pre-push"
	git config --file "$GIT_CONFIG_GLOBAL" core.hooksPath "$HOME/.config/git/hooks"
	git config --file "$GIT_CONFIG_GLOBAL" release.libdir "$HOME/.config/git/hooks"
	git config --file "$GIT_CONFIG_GLOBAL" include.path "$GITCONFIG_SRC"
}

# s_hooks_at <name> <libdir> — like s_hooks but with an explicit release.libdir
# and hooksPath. A literal $HOME in <libdir> is re-rooted onto the sandbox home.
s_hooks_at() {
	local name="$1" libdir="$2"
	s_hooks "$name"
	libdir="${libdir//"\$HOME"/$HOME}"
	git config --file "$GIT_CONFIG_GLOBAL" release.libdir "$libdir"
}

# s_key [value] — provision the release bypass key file (mode 0600).
s_key() {
	local v="${1:-test-release-key-123}"
	printf '%s\n' "$v" >"$HOME/.config/git/release-key"
	chmod 600 "$HOME/.config/git/release-key"
}

# s_repo [name] — create a bare origin + a working clone (on `main`).
s_repo() {
	s_hooks "${1:-repo}"
	ORIGIN="$SANDBOX/origin.git"
	WORK="$SANDBOX/work"
	git init -q --bare "$ORIGIN"
	git init -q -b main "$WORK"
	git -C "$WORK" remote add origin "$ORIGIN"
}

# Push a branch to origin, bypassing the pre-push hook (setup only).
s_push_bypass() {
	git push -q --no-verify origin "$1"
}

# s_stub_lib <libdir> <marker_path> — write a minimal release-common.sh that
# records its own sourcing by touching <marker_path>.
s_stub_lib() {
	local libdir="$1" marker="$2"
	mkdir -p "$libdir"
	cat >"$libdir/release-common.sh" <<EOF
touch "$marker"
release_branch(){ printf '%s\\n' "\${2:-main}"; }
release_read_key(){ return 1; }
EOF
	chmod 700 "$libdir"
	chmod 600 "$libdir/release-common.sh"
}

# s_fake_gh — install a fake `gh` at the front of a controlled PATH.
s_fake_gh() {
	local bin="$SANDBOX/bin"
	FAKE_GH_PAYLOAD_DIR="$SANDBOX/payloads"
	FAKE_GH_LOG="$SANDBOX/gh.log"
	mkdir -p "$bin" "$FAKE_GH_PAYLOAD_DIR"
	: >"$FAKE_GH_LOG"
	echo 0 >"$SANDBOX/gh-counter"
	cat >"$bin/gh" <<EOF
#!/usr/bin/env bash
n=\$(( \$(cat "$SANDBOX/gh-counter") + 1 ))
echo \$n > "$SANDBOX/gh-counter"
printf '%s ' "\$@" >> "$FAKE_GH_LOG"
echo >> "$FAKE_GH_LOG"
if [[ " \$* " == *" --input - "* ]]; then
  cat > "$FAKE_GH_PAYLOAD_DIR/payload-\$n.json"
fi
exit 0
EOF
	chmod +x "$bin/gh"
	GHPATH="$bin:$PATH"
}

# s_nogh_path — print a PATH that includes the tools apply_rules.sh needs
# but NOT `gh`, so the "gh CLI is required" branch can be exercised.
s_nogh_path() {
	local need=(git jq sed head uniq grep cat bash env sh)
	local bin="$SANDBOX/nogh-bin" b d
	mkdir -p "$bin"
	for b in "${need[@]}"; do
		if command -v "$b" >/dev/null 2>&1; then
			d="$(command -v "$b")"
			[ -e "$bin/$b" ] || ln -sf "$d" "$bin/$b"
		fi
	done
	printf '%s\n' "$bin"
}
