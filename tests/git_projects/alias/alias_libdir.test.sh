#!/usr/bin/env bash
#
# Tests for the `release` alias release.libdir hardening (Recommendation #1).
#
# The alias sources release-common.sh from a user-controllable `release.libdir`
# git-config value. If unvalidated, an attacker who can set that config could
# make `git release` source and run arbitrary shell code. These tests pin down
# the hardening: the library may only be sourced from an absolute path under
# $HOME that is a real, owner-only file (not a symlink, not group/world
# writable, owned by the current user).
#
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../../lib.sh"
ALIAS="$GPROOT/git_projects/release.gitconfig"

t_section "release.libdir must be an absolute path under \$HOME"

s_hooks_at "libdir-outside" "/tmp/libdir-evil"
wd="$SANDBOX/w"
git init -q -b main "$wd"
assert_rc_out \
	"rejects release.libdir outside \$HOME" 1 \
	"must be an absolute path under" \
	bash -c 'cd "$1" && git release' _ "$wd"

t_section "release.libdir missing release-common.sh"

s_hooks_at "libdir-missing" '$HOME/missing-lib'
wd="$SANDBOX/w"
git init -q -b main "$wd"
assert_rc_out \
	"rejects missing release-common.sh" 1 \
	"release-common.sh not found" \
	bash -c 'cd "$1" && git release' _ "$wd"

t_section "release-common.sh must not be a symlink"

s_hooks_at "libdir-symlink" '$HOME/sym-lib'
mkdir -p "$HOME/sym-lib"
ln -s /tmp/never "$HOME/sym-lib/release-common.sh"
wd="$SANDBOX/w"
git init -q -b main "$wd"
assert_rc_out \
	"rejects a symlinked release-common.sh" 1 \
	"must not be a symbolic link" \
	bash -c 'cd "$1" && git release' _ "$wd"

t_section "release-common.sh must not be group- or world-writable"

s_hooks_at "libdir-writable" '$HOME/.config/git/hooks'
chmod g+w "$HOME/.config/git/hooks/release-common.sh"
wd="$SANDBOX/w"
git init -q -b main "$wd"
assert_rc_out \
	"rejects group-writable release-common.sh" 1 \
	"must not be group- or world-writable" \
	bash -c 'cd "$1" && git release' _ "$wd"

t_section "release-common.sh must be owned by the current user"

if [ "$(id -u)" -eq 0 ]; then
	s_hooks_at "libdir-owner" '$HOME/.config/git/hooks'
	chown 1:1 "$HOME/.config/git/hooks/release-common.sh"
	wd="$SANDBOX/w"
	git init -q -b main "$wd"
	assert_rc_out \
		"rejects release-common.sh owned by another user" 1 \
		"must be owned by the current user" \
		bash -c 'cd "$1" && git release' _ "$wd"
else
	echo "  (skip: ownership test requires root)"
fi

t_section "valid release.libdir passes hardening (sources the library)"

s_hooks_at "libdir-valid" '$HOME/valid-lib'
marker="$SANDBOX/sourced-ok"
libdir="$HOME/valid-lib"
s_stub_lib "$libdir" "$marker"
wd="$SANDBOX/w"
git init -q -b main "$wd"
rc=0
( cd "$wd" && git release ) >/dev/null 2>&1 || rc=$?
assert_ne "$rc" "0" "valid libdir proceeds past hardening (fails later at fetch)"
assert_eq "$([ -f "$marker" ] && echo yes || echo no)" "yes" \
	"library was actually sourced after valid libdir"

t_section "source must not happen when hardening rejects"

s_hooks_at "libdir-rejected" '$HOME/rejected-lib'
marker2="$SANDBOX/not-sourced"
libdir2="$HOME/rejected-lib"
s_stub_lib "$libdir2" "$marker2"
chmod o+w "$libdir2/release-common.sh"
wd="$SANDBOX/w"
git init -q -b main "$wd"
rc=0
( cd "$wd" && git release ) >/dev/null 2>&1 || rc=$?
assert_eq "$rc" "1" "world-writable lib rejected with rc 1"
assert_eq "$([ -f "$marker2" ] && echo yes || echo no)" "no" \
	"library was NOT sourced when hardening rejected it"

t_summary
