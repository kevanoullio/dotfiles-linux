#!/usr/bin/env bats
#
# Tests for the `release` alias release.libdir hardening (Recommendation #1).
#
# The alias sources release-common.sh from a user-controllable `release.libdir`
# git-config value. If unvalidated, an attacker who can set that config could
# make `git release` source and run arbitrary shell code. These tests pin down
# the hardening: the library may only be sourced from an absolute path under
# $HOME that is a real, owner-only file (not a symlink, not group/world
# writable, owned by the current user).

load ../../helpers/sandbox.bash

@test "release.libdir pointing to a missing directory is rejected" {
	s_hooks_at "libdir-outside" "/tmp/libdir-evil"
	wd="$SANDBOX/w"
	git init -q -b main "$wd"
	run bash -c 'cd "$1" && git release' _ "$wd"
	[ "$status" -eq 1 ]
}

@test "release.libdir missing release-common.sh" {
	s_hooks_at "libdir-missing" '$HOME/missing-lib'
	mkdir -p "$HOME/missing-lib"
	cp "$HOOKS_SRC/release.sh" "$HOME/missing-lib/release.sh"
	wd="$SANDBOX/w"
	git init -q -b main "$wd"
	run bash -c 'cd "$1" && git release' _ "$wd"
	[ "$status" -eq 1 ]
	[[ "$output" == *"release-common.sh not found"* ]]
}

@test "release-common.sh must not be a symlink" {
	s_hooks_at "libdir-symlink" '$HOME/sym-lib'
	mkdir -p "$HOME/sym-lib"
	cp "$HOOKS_SRC/release.sh" "$HOME/sym-lib/release.sh"
	ln -s /tmp/never "$HOME/sym-lib/release-common.sh"
	wd="$SANDBOX/w"
	git init -q -b main "$wd"
	run bash -c 'cd "$1" && git release' _ "$wd"
	[ "$status" -eq 1 ]
	[[ "$output" == *"must not be a symbolic link"* ]]
}

@test "release-common.sh must not be group- or world-writable" {
	s_hooks_at "libdir-writable" '$HOME/.config/git/hooks'
	chmod g+w "$HOME/.config/git/hooks/release-common.sh"
	wd="$SANDBOX/w"
	git init -q -b main "$wd"
	run bash -c 'cd "$1" && git release' _ "$wd"
	[ "$status" -eq 1 ]
	[[ "$output" == *"must not be group- or world-writable"* ]]
}

@test "release-common.sh must be owned by the current user" {
	[ "$(id -u)" -ne 0 ] && skip "requires root"
	s_hooks_at "libdir-owner" '$HOME/.config/git/hooks'
	chown 1:1 "$HOME/.config/git/hooks/release-common.sh"
	wd="$SANDBOX/w"
	git init -q -b main "$wd"
	run bash -c 'cd "$1" && git release' _ "$wd"
	[ "$status" -eq 1 ]
	[[ "$output" == *"must be owned by the current user"* ]]
}

@test "valid release.libdir passes hardening (sources the library)" {
	s_hooks_at "libdir-valid" '$HOME/valid-lib'
	marker="$SANDBOX/sourced-ok"
	libdir="$HOME/valid-lib"
	mkdir -p "$libdir"
	cp "$HOOKS_SRC/release.sh" "$libdir/release.sh"
	cat >"$libdir/release-common.sh" <<EOF
touch "$marker"
release_branch(){ printf '%s\\n' "\${2:-main}"; }
release_read_key(){ return 1; }
EOF
	chmod 700 "$libdir"
	chmod 600 "$libdir/release-common.sh"
	wd="$SANDBOX/w"
	git init -q -b main "$wd"
	run bash -c 'cd "$1" && git release' _ "$wd"
	[ "$status" -ne 0 ]
	[ -f "$marker" ]
}

@test "source must not happen when hardening rejects" {
	s_hooks_at "libdir-rejected" '$HOME/rejected-lib'
	marker2="$SANDBOX/not-sourced"
	libdir2="$HOME/rejected-lib"
	mkdir -p "$libdir2"
	cp "$HOOKS_SRC/release.sh" "$libdir2/release.sh"
	cat >"$libdir2/release-common.sh" <<EOF
touch "$marker2"
release_branch(){ printf '%s\\n' "\${2:-main}"; }
release_read_key(){ return 1; }
EOF
	chmod 700 "$libdir2"
	chmod o+w "$libdir2/release-common.sh"
	wd="$SANDBOX/w"
	git init -q -b main "$wd"
	run bash -c 'cd "$1" && git release' _ "$wd"
	[ "$status" -eq 1 ]
	[ ! -f "$marker2" ]
}
