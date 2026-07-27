#!/bin/bash
# Tmux status bar RIGHT - git status only

PANE_PATH="${1:-$(pwd)}"

output=""

# Check if we're in a git repository
if cd "$PANE_PATH" && git rev-parse --git-dir > /dev/null 2>&1; then
    # Git status (using gitmux if available, otherwise basic git info)
    if command -v gitmux &> /dev/null; then
        git_status=$(gitmux -cfg ~/.gitmux.conf "$PANE_PATH" 2>/dev/null | sed 's/#\[[^]]*\]//g')
        if [[ -n "$git_status" ]]; then
            output+="${git_status}"
        fi
    else
        branch=$(cd "$PANE_PATH" && git branch --show-current 2>/dev/null)
        if [[ -n "$branch" ]]; then
            output+="  ${branch} "
        fi
    fi
fi

echo "$output"
