#!/bin/bash

# ga-gcm-gitp: Stage, commit, and push with PR prompt in one beautiful flow.
# Usage: gap <commit message>
# Stages all changes, commits with the given message, pushes, and prompts for PR.

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    if [[ -f "$(dirname "$0")/gap.help" ]]; then
        echo -e "$(cat "$(dirname "$0")/gap.help")"
    else
        echo "Help file not found"
    fi
    exit 0
fi

if [ $# -eq 0 ]; then
    echo "Usage: gap <commit message>"
    echo "Use 'gap -h' for more information."
    exit 1
fi

# Stage all changes with feedback (reuse ga logic)
if ! command -v git &> /dev/null; then
    echo "git is not installed." >&2
    exit 1
fi

git add .
if [ $? -eq 0 ]; then
    echo -e "\033[1;32m✔ Successfully staged: (all changes)\033[0m"
else
    echo -e "\033[1;31m✗ Failed to add files.\033[0m"
    exit 1
fi

gcm "$*"
gitp