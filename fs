#!/bin/bash

# repo-fuzzy-find: Interactive fuzzy file+text search with preview and jump (requires fzf, ripgrep, less)
# Usage: repo-fuzzy-find
# - Instantly start searching for a string in the repo.
# - Navigate with up/down, see file+preview, press enter to jump to match in less.

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    cat << 'EOF'
fs - Interactive fuzzy file+text search with preview and jump

USAGE:
    fs [--help|-h]

DESCRIPTION:
    Interactive fuzzy file and text search with live preview. Searches through
    all files in the repository using ripgrep and displays results with fzf.
    Navigate with arrow keys, see file preview, press enter to jump to match
    in Cursor editor.

FEATURES:
    • Real-time fuzzy search through file contents
    • Live preview with syntax highlighting
    • Case-insensitive search
    • Jump directly to match location in Cursor
    • Supports all file types in repository

REQUIREMENTS:
    • fzf (fuzzy finder)
    • ripgrep (rg)
    • bat (for syntax highlighting, optional)
    • cursor (for opening files)

KEYBINDINGS:
    • ↑↓ or j/k: Navigate results
    • Enter: Open file at match location
    • Esc: Quit
    • Type: Refine search query

EXAMPLES:
    fs                  # Start interactive search
    fs --help           # Show this help
EOF
    exit 0
fi

if ! command -v fzf &> /dev/null; then
    echo "fzf is required. Install it first." >&2
    exit 1
fi
if ! command -v rg &> /dev/null; then
    echo "ripgrep (rg) is required. Install it first." >&2
    exit 1
fi

# Start with empty query, let user type immediately in fzf (case-insensitive search)
rg --vimgrep --color=never --max-columns=200 -i "" . \
| fzf --ansi --delimiter : \
--with-nth=1,2,4 \
--preview 'bat --style=numbers --color=always --highlight-line {2} {1} 2>/dev/null || tail -n +{2} {1} | head -n 20' \
--preview-window=up:wrap:60% \
--bind "change:reload:rg --vimgrep --color=never --max-columns=200 -i {q} . || true" \
--prompt="Match (insensitive)> " \
--header="Navigate with ↑↓, enter to open, type to refine (case-insensitive). Esc to quit." \
--height=80% --layout=reverse \
| while IFS=: read -r file line col match; do
    if [ -n "$file" ] && [ -n "$line" ] && [ -n "$col" ]; then
        # Open file at line and column using cursor -r -g file:line:col
        cursor -r -g "$file:$line:$col"
    fi
done

# End Generation Here
