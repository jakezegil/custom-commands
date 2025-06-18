# repo-fuzzy-find: Interactive fuzzy file+text search with preview and jump (requires fzf, ripgrep, less)
# Usage: repo-fuzzy-find
# - Type at least 3 characters to search for a string in the repo.
# - Navigate with up/down, see file+preview, press enter to jump to match in less.

if ! command -v fzf &> /dev/null; then
    echo "fzf is required. Install it first." >&2
    exit 1
fi
if ! command -v rg &> /dev/null; then
    echo "ripgrep (rg) is required. Install it first." >&2
    exit 1
fi

while true; do
    read -p "Search string (min 3 chars): " query
    if [ ${#query} -ge 3 ]; then
        break
    fi
    echo "Please enter at least 3 characters."
done

# Use ripgrep to find matches: file:line:col:match
# Feed to fzf with preview, on select open file at line in less
rg --vimgrep --color=never --max-columns=200 "$query" . \
| fzf --ansi --delimiter : \
--with-nth=1,2,4 \
--preview 'bat --style=numbers --color=always --highlight-line {2} {1} 2>/dev/null || tail -n +{2} {1} | head -n 20' \
--preview-window=up:wrap:60% \
--bind "change:reload:rg --vimgrep --color=never --max-columns=200 {q} . || true" \
--query="$query" \
--prompt="Match> " \
--header="Navigate with ↑↓, enter to open, type to refine. Esc to quit." \
--height=80% --layout=reverse \
| while IFS=: read -r file line col match; do
    if [ -n "$file" ] && [ -n "$line" ]; then
        # Open file at line and column 1 using cursor -r -g file:line
        cursor -r -g "$file:$line"
    fi
done

# End Generation Here
