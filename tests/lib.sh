#!/usr/bin/env bash
#
# tests/lib.sh — shared test harness for the git_projects suite.
#
# Sourced by every `*.test.sh`. Provides:
#   * lightweight assertion helpers (assert_eq / assert_rc / assert_rc_out)
#   * an isolated sandbox builder (isolated $HOME, global git config, hooks,
#     release.libdir, a bare origin + work repo) so tests never touch the
#     developer's real ~/.config/git or real remotes.
#
# Each test file must end by calling `t_summary` (which returns non-zero if any
# assertion failed) or by `exit`ing appropriately.
#
set -euo pipefail

# --- Paths to the code under test (repo-relative, resolved at source time) ---
readonly GPROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly HOOKS_SRC="$GPROOT/git_projects/hooks"
readonly GITCONFIG_SRC="$GPROOT/git_projects/release.gitconfig"
readonly SCRIPTS_SRC="$GPROOT/git_projects/scripts"
readonly BRANCH_RULES_SRC="$GPROOT/git_projects/github/branch_rules"

# Directory that holds the `tests/` tree; used for scratch sandboxes. The runner
# normally exports this; make standalone execution work too.
: "${TESTS_HOME:="$(dirname "${BASH_SOURCE[0]}")"}"
export TESTS_HOME

# Global-ish names handed to helpers.
SANDBOX=""
ORIGIN=""
WORK=""
_current=""
__pass=0
__fail=0

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------
t_section() { printf '\n== %s ==\n' "$1"; }

t_run() { _current="$1"; }

__t_ok()   { __pass=$((__pass + 1)); printf '  ok  %s\n' "$_current"; }
__t_fail() {
	__fail=$((__fail + 1))
	printf '  FAIL %s\n' "$_current"
	shift
	for _m in "$@"; do printf '       %s\n' "$_m"; done
}

# ---------------------------------------------------------------------------
# Assertions
# ---------------------------------------------------------------------------
assert_eq() {
	t_run "$3"
	[ "$1" = "$2" ] && __t_ok || __t_fail "expected: $2" "actual:   $1"
}

assert_ne() {
	t_run "$3"
	[ "$1" != "$2" ] && __t_ok || __t_fail "did not expect: $2"
}

assert_contains() {
	t_run "$3"
	case "$1" in *"$2"*) __t_ok ;; *) __t_fail "expected to contain: $2" "actual: $1" ;; esac
}

# assert_rc <message> <expected_rc> <cmd> [cmd-args...]
assert_rc() {
	local msg="$1" exp="$2" rc=0
	shift 2
	t_run "$msg"
	"$@" >/dev/null 2>&1 || rc=$?
	[ "$rc" -eq "$exp" ] && __t_ok || __t_fail "expected rc=$exp, got rc=$rc" "cmd: $*"
}

# assert_rc_out <message> <expected_rc> <grep-pattern> <cmd> [cmd-args...]
# Runs cmd, capturing combined output. Asserts exit code AND that output matches
# the (extended) grep pattern.
assert_rc_out() {
	local msg="$1" exp="$2" pat="$3" out rc=0
	shift 3
	t_run "$msg"
	out="$("$@" 2>&1)" || rc=$?
	if [ "$rc" -eq "$exp" ] && printf '%s\n' "$out" | grep -Eq "$pat"; then
		__t_ok
	else
		__t_fail "expected rc=$exp and output matching: $pat" "rc was: $rc" \
			"output was: $(printf '%s\n' "$out" | head -c 600)"
	fi
}

# ---------------------------------------------------------------------------
# Sandbox
# ---------------------------------------------------------------------------
_sbid=0

# s_env <name> — isolated environment only: fresh $HOME + core git identity.
# Does NOT install the hooks/libdir; use s_hooks for workflow tests.
#
# CRITICAL: GIT_CONFIG_GLOBAL is set to explicitly override git's global config
# location. Without this, `git config --global` may fall back to ~/.gitconfig or
# ~/.config/git/config depending on git version and XDG_CONFIG_HOME state, which
# would pollute the developer's real config. This variable is the only reliable
# way to guarantee all git config reads/writes stay inside the sandbox.
s_env() {
	_sbid=$((_sbid + 1))
	# Resolve TESTS_HOME to an absolute path so SANDBOX is always absolute.
	# This is critical: GIT_CONFIG_GLOBAL is inherited by subshells (bash -c)
	# which may cd into a different directory; a relative path would break.
	local abs_tests
	abs_tests="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	SANDBOX="$abs_tests/.tmp/$1-$_sbid-$$"
	rm -rf "$SANDBOX"
	mkdir -p "$SANDBOX/home/.config/git"

	# HOME must be set before any git command so path resolution inside
	# hooks/aliases (which use $HOME) targets the sandbox.
	export HOME="$SANDBOX/home"

	# GIT_CONFIG_GLOBAL is the hard boundary: every `git config --global`
	# (and every `git` command that reads global config) uses this file
	# exclusively. It completely bypasses ~/.gitconfig and XDG_CONFIG_HOME.
	# Must be absolute — subshells may cd elsewhere.
	export GIT_CONFIG_GLOBAL="$HOME/.config/git/config"

	# Unset XDG_CONFIG_HOME so git never falls back to an XDG path.
	# GIT_CONFIG_GLOBAL takes precedence, but this removes ambiguity.
	unset XDG_CONFIG_HOME

	# Write the initial global config directly into the sandbox file.
	# Using --file (not --global) makes the target explicit.
	: >"$GIT_CONFIG_GLOBAL"
	git config --file "$GIT_CONFIG_GLOBAL" user.name "Test User"
	git config --file "$GIT_CONFIG_GLOBAL" user.email "test@example.com"
	git config --file "$GIT_CONFIG_GLOBAL" init.defaultBranch main
	git config --file "$GIT_CONFIG_GLOBAL" --add safe.directory '*'
}

# s_hooks <name> — like s_env, and additionally installs the repo's hooks/ dir
# as the global hooksPath, points release.libdir at it, and includes the repo's
# .gitconfig (so the `release` alias resolves). This mirrors a real machine
# exactly: the alias + hook share the same copied release-common.sh.
s_hooks() {
	s_env "$1"
	cp -R "$HOOKS_SRC" "$HOME/.config/git/hooks"
	chmod +x "$HOME/.config/git/hooks/pre-push"
	# All writes use --file to explicitly target the sandbox config file.
	# Even though GIT_CONFIG_GLOBAL is set, --file is a second safety net
	# that makes the sandbox boundary obvious to anyone reading the code.
	git config --file "$GIT_CONFIG_GLOBAL" core.hooksPath "$HOME/.config/git/hooks"
	git config --file "$GIT_CONFIG_GLOBAL" release.libdir "$HOME/.config/git/hooks"
	git config --file "$GIT_CONFIG_GLOBAL" include.path "$GITCONFIG_SRC"
}

# s_hooks_at <name> <libdir> — like s_hooks but with an explicit release.libdir
# and hooksPath (used by the libdir-hardening tests to point at various dirs).
s_hooks_at() {
	local name="$1" libdir="$2"
	s_hooks "$name"
	git config --file "$GIT_CONFIG_GLOBAL" release.libdir "$libdir"
}

# s_key [value] — provision the release bypass key file (mode 0600).
s_key() {
	local v="${1:-test-release-key-123}"
	printf '%s\n' "$v" >"$HOME/.config/git/release-key"
	chmod 600 "$HOME/.config/git/release-key"
}

# s_repo [name] — create a bare origin + a working clone (on `main`) with a
# remote named `origin` pointing at the bare repo. Sets $ORIGIN and $WORK.
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

# s_stub_lib <libdir> <marker_path> — write a minimal, self-describing
# release-common.sh into <libdir> that records its own sourcing by touching
# <marker_path>. Used by the hardening tests to prove (or disprove) that the
# alias actually sourced the library after passing the libdir checks.
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

# s_fake_gh — install a fake `gh` at the front of a controlled PATH. The fake
# records every call to $SANDBOX/gh.log and captures any `--input -` payload to
# $SANDBOX/payloads/payload-N.json, then exits 0 (simulating a successful API
# call). Sets $GHPATH = fake-bin-dir:$PATH and $FAKE_GH_LOG / $FAKE_GH_PAYLOAD_DIR.
s_fake_gh() {
	local bin="$SANDBOX/bin"
	FAKE_GH_PAYLOAD_DIR="$SANDBOX/payloads"
	FAKE_GH_LOG="$SANDBOX/gh.log"
	mkdir -p "$bin" "$FAKE_GH_PAYLOAD_DIR"
	: >"$FAKE_GH_LOG"
	: >"$SANDBOX/gh-counter"
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
# (git/jq/sed/head/...) but NOT `gh`, so the "gh CLI is required" branch can be
# exercised deterministically regardless of whether gh is installed machine-wide.
s_nogh_path() {
	local need=(git jq sed head uniq grep)
	local p="" d b
	for b in "${need[@]}"; do
		if command -v "$b" >/dev/null 2>&1; then
			d="$(dirname "$(command -v "$b")")"
			case ":$p:" in *":$d:"*) ;; *) p="$p:$d" ;; esac
		fi
	done
	printf '%s\n' "$p"
}

# ---------------------------------------------------------------------------
# Summary — last statement of every test file.
# ---------------------------------------------------------------------------
t_summary() {
	printf '\n%d passed, %d failed\n' "$__pass" "$__fail"
	[ "$__fail" -eq 0 ]
}
