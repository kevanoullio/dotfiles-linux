#!/bin/bash
#
# release.sh
#
# Standalone script for the `git release` fast-forward workflow.
# Sourced by the global `release` alias (release.gitconfig).
# Auto-discovers and sources release-common.sh from the same directory.
#
# Usage:
#   git release            -> fetch, fast-forward staging into production, push
#   git release --continue -> resume after an interrupted release that already
#                             merged locally but could not push.

release_main() {
    MODE=fresh
    if [ "${1:-}" = "--continue" ]; then MODE=continue; shift; fi
    if [ -n "${1:-}" ]; then echo "Unknown argument: $1"; exit 2; fi

    PROD=$(release_branch prod)
    STAGING=$(release_branch staging)

    if [ -n "$(git status --porcelain)" ]; then
        echo 'Error: Working directory is dirty. Please commit or stash your changes before releasing.'
        exit 1
    fi

    CURRENT_BRANCH=$(git branch --show-current)
    echo 'Fetching latest origin state...'
    git fetch origin

    _auth=$(release_read_key || true)

    if [ "$MODE" = "continue" ]; then
        _merge_base=$(git merge-base "origin/$PROD" "$PROD") &&
        if [ "$_merge_base" = "$(git rev-parse "origin/$PROD")" ] &&
            [ "$(git rev-list --count "origin/$PROD".."$PROD")" -gt 0 ]; then
            echo "Resuming: local $PROD is ahead of origin/$PROD as a clean fast-forward; pushing..."
            printf 'Type "YES" to confirm pushing %s to origin: ' "$PROD"
            read -r confirm
            if [ "$confirm" != "YES" ]; then
                echo 'Confirmation rejected. Aborting.'
                exit 1
            fi
            if ! env GIT_RELEASE_AUTH="$_auth" git push origin "$PROD"; then
                echo "Error: Failed to push $PROD to origin. It is already merged locally."
                echo 'Manual steps:'
                echo "  1. git push origin $PROD"
                exit 1
            fi
            unset GIT_RELEASE_AUTH
            unset _merge_base
        else
            echo "Nothing to resume: local $PROD is not a clean fast-forward ahead of origin/$PROD."
            echo 'Run plain `git release` instead, it will resolve the state.'
            exit 1
        fi
    else
        # Check for local commits on staging/production that are not on origin
        echo "Checking for local commits that are not on origin (on $PROD or $STAGING)..."
        for b in "$STAGING" "$PROD"; do
            _remote="origin/$b"
            if ! git rev-parse --verify "$_remote" >/dev/null 2>&1; then continue; fi
            _count=$(git rev-list --count "$_remote..$b" 2>/dev/null || echo 0)
            if [ "${_count:-0}" -gt 0 ]; then
                echo "ABORT: local branch '$b' has $_count commit(s) not present on '$_remote'."
                echo 'Affected commit(s):'
                git log --oneline -n 5 "$_remote..$b" | sed 's/^/    /'
                if [ "$(( _count ))" -gt 5 ]; then
                    echo "    ... and more (use: git log --oneline origin/$b..$b)"
                fi
                echo "These commits are NOT auto-pushed or auto-merged by git release, so they would"
                echo 'be ignored (staging) or could be confused with release work (prod). Resolve them first:'
                echo "  1. Move the commits onto a working branch so they are not lost:"
                echo "       git branch feature/your-change origin/$b   # or: git branch hotfix/your-fix origin/$b"
                echo "       git checkout $b"
                echo "  2. Remove the commits from '$b' so it matches origin:"
                echo "       git reset --hard $_remote"
                echo '  3. Open a pull request from feature/ or hotfix/ into '"'$STAGING'"' (normal review path).'
                echo '  4. Then re-run: git release'
                exit 1
            fi
        done

        # Verify staging can fast-forward into production (server state)
        echo "Verifying $STAGING can fast-forward into $PROD (server state)..."
        if ! git merge-base --is-ancestor "origin/$PROD" "origin/$STAGING"; then
            echo "Error: server $PROD is not an ancestor of server $STAGING."
            echo 'Fast-forward merge is not possible without first syncing.'
            exit 1
        fi

        # Sync local PROD to origin/PROD (fast-forward only)
        echo "Syncing local $PROD to origin/$PROD (fast-forward only)..."
        if [ "$(git rev-parse "$PROD")" != "$(git rev-parse "origin/$PROD")" ]; then
            if git merge-base --is-ancestor "$PROD" "origin/$PROD"; then
                git checkout -q "$PROD"
                git merge --ff-only "origin/$PROD"
            else
                echo "ABORT: local $PROD has commits not on origin/$PROD."
                echo "$PROD currently at $(git rev-parse --short "$PROD"), origin at $(git rev-parse --short "origin/$PROD")."
                echo 'Refusing to overwrite your work. Review and push or reset these commits first.'
                echo 'Manual steps:'
                echo "  1. git checkout $PROD && git log origin/$PROD..$PROD"
                echo "  2. if these are intended: git push origin $PROD (or: git release --continue)"
                echo "  3. if not intended:      git reset --hard origin/$PROD"
                exit 1
            fi
        else
            git checkout -q "$PROD"
        fi

        # Merge origin/STAGING into PROD (fast-forward only)
        echo "Merging origin/$STAGING into $PROD (fast-forward only)..."
        if ! git merge --ff-only "origin/$STAGING"; then
            echo "Error: Fast-forward merge of $STAGING into $PROD failed."
            echo "This usually means $PROD has commits that $STAGING does not."
            echo "You are currently on the $PROD branch."
            echo 'Manual steps:'
            echo "  1. git merge --ff-only origin/$STAGING"
            echo "  2. git push origin $PROD"
            echo "  3. git checkout $CURRENT_BRANCH"
            exit 1
        fi

        # Push PROD to origin
        echo "Pushing $PROD to origin..."
        printf 'Type "YES" to confirm pushing %s to origin: ' "$PROD"
        read -r confirm
        if [ "$confirm" != "YES" ]; then
            echo 'Confirmation rejected. Aborting.'
            exit 1
        fi
        if ! env GIT_RELEASE_AUTH="$_auth" git push origin "$PROD"; then
            echo "Error: Failed to push $PROD to origin."
            echo "The merge is complete locally; run: git release --continue  (to resume the push)."
            echo 'Manual steps:'
            echo "  1. git push origin $PROD"
            echo "  2. git checkout $CURRENT_BRANCH"
            exit 1
        fi
        unset GIT_RELEASE_AUTH _auth _merge_base
    fi

    # Return to original branch
    if [ -n "$CURRENT_BRANCH" ]; then
        git checkout "$CURRENT_BRANCH"
    fi

    echo 'Production fast-forward merge successful!'
}

# Auto-discover and source release-common.sh from the same directory
_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
_libfile="$_SCRIPT_DIR/release-common.sh"
if [ -L "$_libfile" ]; then echo "ERROR: release-common.sh must not be a symbolic link." >&2; exit 1; fi
if [ ! -f "$_libfile" ]; then echo "ERROR: release-common.sh not found at $_libfile." >&2; exit 1; fi
if [ "$(id -u)" != "$(stat -c %u "$_libfile")" ]; then echo "ERROR: release-common.sh must be owned by the current user (uid $(id -u))." >&2; exit 1; fi
_lmode=$(stat -c %a "$_libfile")
if [ $(( 8#$_lmode & 022 )) -ne 0 ]; then echo "ERROR: release-common.sh must not be group- or world-writable (mode $_lmode)." >&2; exit 1; fi
. "$_libfile"

# Execute with all arguments
release_main "$@"
