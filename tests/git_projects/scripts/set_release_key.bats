#!/usr/bin/env bats
#
# Tests for scripts/set-release-key.sh — provisions the local release bypass key.
#
# Security-relevant properties:
#   * the key file must be written with mode 0600 (owner read/write only)
#   * the key must be non-empty / exactly the provided value
#   * `-s` prints an export line; never echoes the key to the file's perms

load ../../helpers/sandbox.bash

SETKEY="$SCRIPTS_SRC/set-release-key.sh"

@test "generates a key file with mode 0600" {
	s_env "key-gen"
	run bash "$SETKEY"
	[ "$status" -eq 0 ]
	[ "$(stat -c %a "$HOME/.config/git/release-key")" = "600" ]
	[ -n "$(cat "$HOME/.config/git/release-key")" ]
	[ "$(stat -c %u "$HOME/.config/git/release-key")" = "$(id -u)" ]
}

@test "provisions a provided passphrase verbatim (-p)" {
	s_env "key-provided"
	run bash "$SETKEY" -p "my-secret-passphrase"
	[ "$status" -eq 0 ]
	[ "$(cat "$HOME/.config/git/release-key")" = "my-secret-passphrase" ]
	[ "$(stat -c %a "$HOME/.config/git/release-key")" = "600" ]
}

@test "-s prints an export line for the current shell" {
	s_env "key-export"
	run bash "$SETKEY" -s
	[ "$status" -eq 0 ]
	[[ "$output" == *"export GIT_RELEASE_KEY="* ]]
	[ "$(stat -c %a "$HOME/.config/git/release-key")" = "600" ]
}

@test "directory is created if missing" {
	s_env "key-mkdir"
	rm -rf "$HOME/.config/git"
	run bash "$SETKEY"
	[ "$status" -eq 0 ]
	[ "$(stat -c %a "$HOME/.config/git/release-key")" = "600" ]
}
