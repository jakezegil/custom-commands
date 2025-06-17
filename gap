#!/bin/bash

# ga-gcm-gitp: Stage, commit, and push with PR prompt in one beautiful flow.
# Usage: gap <commit message>
# Stages all changes, commits with the given message, pushes, and prompts for PR.

if [ $# -eq 0 ]; then
    echo "Usage: gap <commit message>"
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