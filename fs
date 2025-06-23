#!/bin/bash

# repo-fuzzy-find: Interactive fuzzy file+text search with preview and jump (requires fzf, ripgrep, less)
# Usage: repo-fuzzy-find
# - Instantly start searching for a string in the repo.
# - Navigate with up/down, see file+preview, press enter to jump to match in less.

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
