#!/bin/bash

# npm run with tab autocompletion from package.json scripts
# Provides intelligent autocompletion for npm scripts defined in package.json

# Find package.json in current or parent directories
_find_package_json() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/package.json" ]]; then
            echo "$dir/package.json"
            return 0
        fi
        dir=$(dirname "$dir")
    done
    return 1
}

_nr_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local scripts=""
    local package_json
    
    package_json=$(_find_package_json)
    
    if [[ -n "$package_json" ]]; then
        # Extract script names from package.json using jq if available, otherwise use grep/sed
        if command -v jq &> /dev/null; then
            scripts=$(jq -r '.scripts | keys[]' "$package_json" 2>/dev/null | tr '\n' ' ')
        else
            # Fallback parsing without jq - improved regex
            scripts=$(grep -A 1000 '"scripts"' "$package_json" | \
                sed -n '/^[[:space:]]*"scripts"[[:space:]]*:[[:space:]]*{/,/^[[:space:]]*}/p' | \
                grep -o '"[^"]\+"[[:space:]]*:' | \
            sed 's/"//g' | sed 's/[[:space:]]*://' | tr '\n' ' ')
        fi
    fi
    
    COMPREPLY=($(compgen -W "$scripts" -- "$cur"))
}

# Register completion function for nr command (only when sourced)
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    complete -F _nr_completion nr
fi

# Show help documentation
_nr_help() {
    cat << 'EOF'
nr - npm run with intelligent autocompletion

USAGE:
    nr [script_name] [args...]
    nr -h, --help

DESCRIPTION:
    A smart wrapper for npm run that provides tab autocompletion for scripts
    defined in package.json. Automatically finds package.json in current or
    parent directories.

OPTIONS:
    -h, --help    Show this help message

EXAMPLES:
    nr                  # List all available scripts
    nr build            # Run the 'build' script
    nr test -- --watch  # Run 'test' script with additional arguments

FEATURES:
    • Tab autocompletion for script names
    • Searches for package.json in current and parent directories
    • Works from any subdirectory of your project
    • Passes through additional arguments to npm run

REQUIREMENTS:
    • jq (optional, for better script listing)
    • bash completion support

INSTALLATION:
    Add to your shell profile (~/.bashrc, ~/.zshrc):
    source /path/to/nr
EOF
}

# Main nr function
nr() {
    # Handle help flags
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        _nr_help
        return 0
    fi
    
    # Find package.json in current or parent directories
    local package_json
    package_json=$(_find_package_json)
    
    if [[ -z "$package_json" ]]; then
        echo "Error: No package.json found in current directory or parent directories" >&2
        return 1
    fi
    
    if [[ $# -eq 0 ]]; then
        # Show available scripts if no arguments
        echo "Available scripts:"
        if command -v jq &> /dev/null; then
            local scripts_output
            scripts_output=$(jq -r '.scripts | to_entries[] | "  \(.key): \(.value)"' "$package_json" 2>/dev/null)
            if [[ -n "$scripts_output" ]]; then
                echo "$scripts_output"
            else
                echo "  No scripts found in package.json"
            fi
        else
            echo "  (install jq for better script listing)"
            # Change to the directory containing package.json before running npm
            (cd "$(dirname "$package_json")" && npm run 2>/dev/null | grep -A 100 "available via" || echo "  No scripts found")
        fi
        return 0
    else
        # Change to the directory containing package.json before running npm
        (cd "$(dirname "$package_json")" && npm run "$@")
    fi
}

# If script is executed directly (not sourced), call the nr function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    nr "$@"
fi
