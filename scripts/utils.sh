#!/bin/bash

# Global default managed shell RC file (override by exporting MANAGED_SHELL_RC before sourcing)
: "${MANAGED_SHELL_RC:=$HOME/.bashrc}"

# Helper: check if a block already exists in the target rc file
# Usage: _block_exists_in_file <title> <verb> [rc_file]
_block_exists_in_file() {
    local title="$1" verb="$2" file="${3:-$MANAGED_SHELL_RC}"
    local start_marker="# >>> $title $verb >>>"
    grep -q "$start_marker" "$file" 2>/dev/null
}

# Helper: extract existing block (including markers) if present
# Usage: _get_block_from_file <title> <verb> [rc_file]
_get_block_from_file() {
    local title="$1" verb="$2" file="${3:-$MANAGED_SHELL_RC}"
    local start_marker="# >>> $title $verb >>>"
    local end_marker="# <<< $title $verb <<<"
    awk -v start="$start_marker" -v end="$end_marker" '
        $0==start {printing=1}
        printing {print}
        $0==end {printing=0}
    ' "$file" 2>/dev/null
}

# Helper: create timestamped backup of a file
# Usage: _backup_file <file>
_backup_file() {
    local file="$1"
    [ -f "$file" ] || return 0
    local ts
    ts=$(date +%Y%m%d_%H%M%S)
    cp "$file" "${file}.bak.${ts}"
    echo "Backup created: ${file}.bak.${ts}"
}

# Function for adding (or updating) a managed block in rc file (default: $MANAGED_SHELL_RC)
# Usage: add_block_to_file <title> <verb> <setup_code> [rc_file]
# Behavior:
#  - If block absent: append new block.
#  - If block present & identical: skip.
#  - If block present & different: backup file, remove old block, append new at end.
add_block_to_file() {
    local title="$1" verb="$2" setup_code="$3" file="${4:-$MANAGED_SHELL_RC}"
    local start_marker="# >>> $title $verb >>>"
    local end_marker="# <<< $title $verb <<<"

    local expected_block
    expected_block="$start_marker"$'\n'"$setup_code"$'\n'"$end_marker"

    if _block_exists_in_file "$title" "$verb" "$file"; then
        local existing_block
        existing_block=$(_get_block_from_file "$title" "$verb" "$file")
        if [ "$existing_block" = "$expected_block" ]; then
            echo "$title $verb block already up to date in $file. Skipping."
            return 0
        fi
        echo "$title $verb block differs; backing up $file and updating it..."
        _backup_file "$file"
        # Remove all occurrences of the block before appending new one
        sed -i "/$start_marker/,/$end_marker/d" "$file"
    else
        echo "$title $verb block not found; adding new block to $file..."
    fi

    # Add the new block at the end of the file
    {
        echo ""
        echo "$start_marker"
        echo "$setup_code"
        echo "$end_marker"
        echo ""
    } >> "$file"

    echo "$title $verb block written to end of $file."
}

# Function for printing completion message
# Usage: print_completion_message <env_title> <env_verb> [<Name> <VersionCommand>]...
print_completion_message() {
    local env_title="$1" env_verb="$2"
    shift 2
    echo ""
    echo "$env_title $env_verb complete!"
    # Expect remaining arguments as pairs: <Name> <Command>
    while [ "$#" -gt 0 ]; do
        # Break if command missing (odd number of args)
        local name="$1" cmd="$2"
        if [ -z "$cmd" ]; then
            break
        fi
        shift 2
        # Capture command output safely
        local output
        output=$(eval "$cmd" 2>/dev/null)
        echo "Installed $name version: $output"
    done
    echo ""
    echo "To use $env_title in new terminal sessions, make sure to restart your terminal"
    echo "or run: source $MANAGED_SHELL_RC"
}
