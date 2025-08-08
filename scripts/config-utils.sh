#!/bin/bash

# Configuration utilities for custom commands
# Source this file to get access to config functions

# Get the config directory (assumes this script is in scripts/ folder)
get_config_dir() {
    echo "$(dirname "$(dirname "${BASH_SOURCE[0]}")")"
}

# Read username from config.json, fallback to example then system user
get_username() {
    local config_dir="$(get_config_dir)"
    local config_file="$config_dir/config.json"
    local example_file="$config_dir/config.example.json"
    local username=""
    
    # Try main config first
    if [[ -f "$config_file" ]]; then
        username=$(cat "$config_file" | grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
    fi
    
    # If no config.json, suggest creating from example
    if [[ ! -f "$config_file" && -f "$example_file" ]]; then
        echo "⚠️  No config.json found. Copy config.example.json to config.json and customize it." >&2
        echo "   cp $(get_config_dir)/config.example.json $(get_config_dir)/config.json" >&2
    fi
    
    # Final fallback to system username
    if [[ -z "$username" ]]; then
        username=$(whoami)
    fi
    
    echo "$username"
}

# Read git branch types from config, fallback to defaults
get_branch_types() {
    local config_file="$(get_config_dir)/config.json"
    local types="fix feat nit"  # defaults
    
    if [[ -f "$config_file" ]]; then
        # Extract branch types from JSON array (basic parsing)
        local json_types=$(cat "$config_file" | grep -A 10 '"branchTypes"' | grep -o '"[^"]*"' | grep -v branchTypes | tr -d '"' | tr '\n' ' ')
        if [[ -n "$json_types" ]]; then
            types="$json_types"
        fi
    fi
    
    echo "$types"
}

# Read git worktree types from config, fallback to branch types or defaults
get_worktree_types() {
    local config_file="$(get_config_dir)/config.json"
    local types=""
    
    if [[ -f "$config_file" ]]; then
        # Check if jq is available for proper JSON parsing
        if command -v jq &> /dev/null; then
            # Try to get worktreeTypes using jq
            local json_types=$(jq -r '.git.worktreeTypes[]? // empty' "$config_file" 2>/dev/null | tr '\n' ' ')
            if [[ -n "$json_types" ]]; then
                types="$json_types"
            else
                # Fallback to branchTypes using jq
                json_types=$(jq -r '.git.branchTypes[]? // empty' "$config_file" 2>/dev/null | tr '\n' ' ')
                if [[ -n "$json_types" ]]; then
                    types="$json_types"
                fi
            fi
        else
            # Fallback to basic parsing for branchTypes only (more reliable)
            types=$(get_branch_types)
        fi
    fi
    
    # Default if nothing found
    if [[ -z "$types" ]]; then
        types="fix feat nit"
    fi
    
    echo "$types"
}

# Generic function to get any config value using jq
get_config_value() {
    local key="$1"
    local config_file="$(get_config_dir)/config.json"
    
    if [[ ! -f "$config_file" ]]; then
        echo ""
        return 1
    fi
    
    # Check if jq is available
    if command -v jq &> /dev/null; then
        jq -r ".$key // empty" "$config_file" 2>/dev/null
    else
        echo ""
        return 1
    fi
}