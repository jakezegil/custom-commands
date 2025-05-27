#!/bin/bash

# Register custom git commands by creating symlinks in PATH
# Makes custom scripts available as git subcommands

SCRIPT_DIR="$HOME/custom-commands"

# Dynamically find all executable scripts in the directory
commands=()
for script in "$SCRIPT_DIR"/*; do
    if [ -f "$script" ]  && [[ "$(basename "$script")" != "register-commands.sh" ]]; then
        commands+=("$(basename "$script")")
    fi
done

# Make all scripts executable first
for script in "$SCRIPT_DIR"/*; do
    if [ -f "$script" ] && [[ "$(basename "$script")" != "register-commands.sh" ]]; then
        chmod +x "$script"
    fi
done

echo ""
echo "Custom git commands registered (${#commands[@]} total):"
for cmd in "${commands[@]}"; do
    echo " $cmd"
done