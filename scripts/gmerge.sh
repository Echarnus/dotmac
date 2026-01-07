#!/bin/zsh

# ============================================================================
# gmerge - Checkout, pull, return, and merge a branch
# ============================================================================
# Description: Safely checkout a branch, pull latest changes, return to
#              original branch, and merge the target branch
# Usage: gmerge <branch>
# ============================================================================

gmerge() {
    if [[ $# -eq 0 ]]; then
        echo "❌ Error: Branch name required"
        echo "   Usage: gmerge <branch>"
        return 1
    fi

    local target_branch="$1"
    
    # Verify we're in a git repository
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        echo "❌ Error: Not in a git repository"
        return 1
    fi

    # Save current branch
    local current_branch=$(git branch --show-current)
    
    if [[ -z "$current_branch" ]]; then
        echo "❌ Error: Not currently on a branch"
        return 1
    fi

    echo "📍 Current branch: $current_branch"
    echo "🎯 Target branch: $target_branch"
    echo ""

    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        echo "⚠️  Warning: You have uncommitted changes"
        echo -n "Continue? (y/N): "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo "❌ Aborted"
            return 1
        fi
    fi

    # Step 1: Checkout target branch
    echo "1️⃣  Checking out $target_branch..."
    if ! git checkout "$target_branch" 2>/dev/null; then
        echo "❌ Failed to checkout $target_branch"
        return 1
    fi

    # Step 2: Pull latest changes
    echo "2️⃣  Pulling latest changes..."
    if ! git pull; then
        echo "❌ Failed to pull changes"
        echo "   Returning to $current_branch..."
        git checkout "$current_branch" 2>/dev/null
        return 1
    fi

    # Step 3: Return to original branch
    echo "3️⃣  Returning to $current_branch..."
    if ! git checkout "$current_branch" 2>/dev/null; then
        echo "❌ Failed to return to $current_branch"
        return 1
    fi

    # Step 4: Merge target branch
    echo "4️⃣  Merging $target_branch into $current_branch..."
    if git merge "$target_branch"; then
        echo ""
        echo "✅ Successfully merged $target_branch into $current_branch"
        return 0
    else
        echo ""
        echo "❌ Merge conflict occurred"
        echo "   Resolve conflicts and commit, or run: git merge --abort"
        return 1
    fi
}
## When sourced from shell startup, don't auto-run.
## To use as script: `zsh gmerge.sh <branch>` or call `gmerge <branch>` in shell.
