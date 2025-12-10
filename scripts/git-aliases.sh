#!/bin/zsh

# ============================================================================
# Git Aliases and Helper Functions
# ============================================================================
# Description: Convenient shortcuts for common git operations
# Usage: Source this file in your .zshrc
#
# Aliases:
#   g c [branch]         - git checkout [branch]
#   g d                  - gdev (create branch from Azure DevOps work item)
#   g m [branch]         - git merge [branch]
#   g cpm [branch]       - checkout, pull, return, and merge a branch
# ============================================================================

# Main git wrapper function
g() {
    # No arguments - show help
    if [[ $# -eq 0 ]]; then
        echo "Git Aliases:"
        echo "  g c [branch]    - Checkout branch"
        echo "  g d             - Create branch from Azure DevOps work item"
        echo "  g m [branch]    - Merge branch"
        echo "  g cpm [branch]  - Checkout branch, pull, return, and merge"
        echo ""
        echo "Use 'g help' for more information"
        return 0
    fi

    local subcommand="$1"
    shift

    case "$subcommand" in
        # ========================================
        # g c [branch] - git checkout
        # ========================================
        c|checkout)
            if [[ $# -eq 0 ]]; then
                # No branch specified, show interactive branch selector
                local branch=$(git branch -a | \
                    sed 's/^[* ] //' | \
                    sed 's|remotes/origin/||' | \
                    sort -u | \
                    fzf --height=20 --border --prompt="Select branch: " --header="Use ↑↓ arrows, Enter to select")
                
                if [[ -n "$branch" ]]; then
                    git checkout "$branch"
                else
                    echo "❌ No branch selected"
                    return 1
                fi
            else
                git checkout "$@"
            fi
            ;;

        # ========================================
        # g d - gdev (Azure DevOps work item)
        # ========================================
        d|dev)
            if command -v gdev &>/dev/null; then
                gdev
            else
                echo "❌ Error: gdev command not found"
                echo "   Make sure azure-devops.sh is sourced"
                return 1
            fi
            ;;

        # ========================================
        # g m [branch] - git merge
        # ========================================
        m|merge)
            if [[ $# -eq 0 ]]; then
                echo "❌ Error: Branch name required"
                echo "   Usage: g m <branch>"
                return 1
            fi
            git merge "$@"
            ;;

        # ========================================
        # g cpm [branch] - checkout, pull, merge
        # ========================================
        cpm)
            if [[ $# -eq 0 ]]; then
                echo "❌ Error: Branch name required"
                echo "   Usage: g cpm <branch>"
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
            ;;

        # ========================================
        # Help and unknown commands
        # ========================================
        help|--help|-h)
            echo "Git Aliases - Convenient shortcuts for git operations"
            echo ""
            echo "Usage:"
            echo "  g c [branch]       Checkout a branch (interactive if no branch specified)"
            echo "  g d                Create branch from Azure DevOps work item"
            echo "  g m <branch>       Merge specified branch into current branch"
            echo "  g cpm <branch>     Checkout, pull, return, and merge branch"
            echo ""
            echo "Examples:"
            echo "  g c main           # Checkout main branch"
            echo "  g c                # Interactive branch selection"
            echo "  g d                # Create feature/fix branch from work item"
            echo "  g m feature-123    # Merge feature-123 into current branch"
            echo "  g cpm main         # Update main, return, and merge into current"
            echo ""
            echo "The 'g cpm' command is useful for:"
            echo "  - Keeping your feature branch up-to-date with main/develop"
            echo "  - Safely pulling and merging without staying on the target branch"
            ;;

        *)
            echo "❌ Unknown subcommand: $subcommand"
            echo "   Run 'g help' for available commands"
            return 1
            ;;
    esac
}

# Enable completion for the g command
compdef _git g=git
