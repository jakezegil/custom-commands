#!/bin/bash

# ga-gcm-gitp: Stage, commit, and push with PR prompt in one beautiful flow.
# Usage: gap <commit message>
# Stages all changes, commits with the given message, pushes, and prompts for PR.

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    cat << 'EOF'
gap - Stage, commit, and push with PR prompt in one flow

USAGE:
    gap <commit message>
    gap --help|-h

DESCRIPTION:
    Combines git add, commit, and push operations in a single command with
    beautiful feedback. Stages all changes, commits with the provided message,
    pushes to remote, and prompts to create a pull request.

    This is a convenience command that executes:
    1. git add . (stage all changes)
    2. git commit -m "<commit message>"
    3. git push --set-upstream origin <current-branch>
    4. Prompt to open pull request

EXAMPLES:
    gap Add new feature           # Stage, commit, and push
    gap Fix bug in user auth      # With descriptive message
    gap --help                      # Show this help

REQUIREMENTS:
    • git
    • Current directory must be a git repository
    • GitHub CLI (gh) recommended for PR creation
EOF
    exit 0
fi

if [ $# -eq 0 ]; then
    echo "Usage: gap <commit message>"
    echo "Use 'gap --help' for more information."
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