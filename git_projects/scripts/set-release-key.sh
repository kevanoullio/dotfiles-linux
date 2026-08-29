#!/usr/bin/env bash
#
# set-release-key.sh — provision the local release bypass key.
#
# The `git release` alias and the global pre-push hook grant a direct push to
# the production branch only when a release key is supplied. This script:
#   1. Generates a random key (openssl rand or /dev/urandom).
#   2. Writes it to ~/.config/git/release-key with mode 0600.
#   3. Optionally exports GIT_RELEASE_KEY for the current shell session.
#
# Usage:
#   set-release-key.sh            # generate + write key file
#   set-release-key.sh -s         # ... and print an `export GIT_RELEASE_KEY=...`
#   set-release-key.sh -p "..."   # use a provided passphrase instead of generate
#
# NOTE: This key is LOCAL to your machine and only guards against accidental
# pushes. It is not readable by GitHub (repo secrets/variables are only visible
# to GitHub Actions, not your shell) and is not server-side security.

set -euo pipefail

KEY_FILE="${HOME}/.config/git/release-key"
PRINT_EXPORT=0
PROVIDED=""

usage() {
	cat <<'EOF'
Usage:
  set-release-key.sh            generate + write release key file
  set-release-key.sh -s         ... and print shell export line
  set-release-key.sh -p VALUE   use provided VALUE as the key
EOF
}

while getopts "sp:" opt; do
	case "$opt" in
		s) PRINT_EXPORT=1 ;;
		p) PROVIDED="$OPTARG" ;;
		*) usage; exit 1 ;;
	esac
done

if [ -n "$PROVIDED" ]; then
	KEY="$PROVIDED"
else
	KEY=$(openssl rand -hex 32 2>/dev/null || head -c 64 /dev/urandom | od -An -tx1 | tr -d ' \n')
fi

if [ -z "$KEY" ]; then
	echo "Error: failed to generate a key." >&2
	exit 1
fi

mkdir -p "$(dirname "$KEY_FILE")"
umask 077
printf '%s\n' "$KEY" > "$KEY_FILE"
chmod 600 "$KEY_FILE"

echo "Release key written to: $KEY_FILE (mode 600)"

if [ "$PRINT_EXPORT" -eq 1 ]; then
	echo "For the current shell session, run:"
	echo "  export GIT_RELEASE_KEY='$KEY'"
fi
