#!/usr/bin/env bash
#
# Tests for scripts/set-release-key.sh — provisions the local release bypass key.
#
# Security-relevant properties:
#   * the key file must be written with mode 0600 (owner read/write only)
#   * the key must be non-empty / exactly the provided value
#   * `-s` prints an export line; never echoes the key to the file's perms
#
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../../lib.sh"
SETKEY="$SCRIPTS_SRC/set-release-key.sh"

t_section "generates a key file with mode 0600"

s_env "key-gen"
assert_rc "set-release-key.sh runs clean" 0 bash "$SETKEY"
assert_eq "$(stat -c %a "$HOME/.config/git/release-key")" "600" \
	"key file mode is 0600"
assert_ne "$(cat "$HOME/.config/git/release-key")" "" "key is non-empty"
assert_eq "$(stat -c %u "$HOME/.config/git/release-key")" "$(id -u)" \
	"key file owned by current user"

t_section "provisions a provided passphrase verbatim (-p)"

s_env "key-provided"
assert_rc "set-release-key.sh -p VALUE runs clean" 0 bash "$SETKEY" -p "my-secret-passphrase"
assert_eq "$(cat "$HOME/.config/git/release-key")" "my-secret-passphrase" \
	"provided passphrase written verbatim"
assert_eq "$(stat -c %a "$HOME/.config/git/release-key")" "600" \
	"provided passphrase file still mode 0600"

t_section "-s prints an export line for the current shell"

s_env "key-export"
out="$(bash "$SETKEY" -s 2>&1)"
assert_contains "$out" "export GIT_RELEASE_KEY=" "-s prints an export line"
assert_eq "$(stat -c %a "$HOME/.config/git/release-key")" "600" \
	"file mode 0600 even with -s"

t_section "directory is created if missing"

s_env "key-mkdir"
rm -rf "$HOME/.config/git"
assert_rc "creates ~/.config/git when absent" 0 bash "$SETKEY"
assert_eq "$(stat -c %a "$HOME/.config/git/release-key")" "600" \
	"file created with 0600 after creating dirs"

t_summary
