# Custom Commands

Beautiful CLI tools for development workflows.

## Quick Start

```bash
npm run register && source ~/.zshrc
```

## Commands

| Command | Purpose                       |
| ------- | ----------------------------- |
| `ff`    | Fast AI command generator     |
| `fk`    | Context-aware AI commands     |
| `fs`    | Fuzzy file+text search        |
| `ga`    | Git add with feedback         |
| `gap`   | Stage, commit, push + PR      |
| `gb`    | Interactive branch creator    |
| `gbc`   | Show current branch           |
| `gcm`   | Git commit with message       |
| `gitp`  | Push with upstream + PR       |
| `glog`  | Interactive git log           |
| `gsa`   | Interactive stash browser     |
| `nr`    | npm run with completion       |

## Usage

```bash
# AI Assistant
ff list all python files      # Pre-fills: find . -name "*.py"
ff find large files           # Pre-fills command in terminal

# Context-Aware AI
fk update npm script          # Uses directory + history context
fk -f package.json add test   # Include specific file context
fk -f src/app.js fix port     # Analyze code for better suggestions

# Search
fs                    # Interactive file+text search

# Git workflow
ga file.js            # Stage files (or all with no args)
gap commit message    # Complete git workflow (ga, gcm <message>, gitp)
gb                    # Create branch interactively
gbc                   # Show current branch
gcm fix bug           # Commit with message
gitp                  # Push + open PR
glog                  # Interactive browser for commit history
gsa                   # Interactive browser for git stashes

# Node.js
nr                    # List available scripts
nr build              # Run script with completion
```

## Installation

**Prerequisites:**

```bash
# macOS
brew install fzf ripgrep bat jq gh

# Ubuntu
sudo apt install fzf ripgrep bat jq
```

**Setup:**

```bash
npm run register
source ~/.zshrc       # or restart terminal
```

All commands support `--help` for details.

## Configuration

Customize commands by creating your personal config:

```bash
cp config.example.json config.json
```

Edit `config.json` to set your preferences:

```json
{
  "user": {
    "name": "your-username"
  },
...
}
```

**Note:** `config.json` is gitignored to keep your personal settings private.
