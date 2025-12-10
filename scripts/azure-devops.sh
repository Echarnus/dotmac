#!/bin/zsh

# ============================================================================
# Azure DevOps Helper Script
# ============================================================================
# Description: Creates a new git branch from an Azure DevOps work item
# Usage: gdev
#
# Features:
#   - Auto-detects organization and project from git remote
#   - Filters work items assigned to the logged-in user
#   - Creates branches with feature/ or fix/ prefix based on work item type
#   - Interactive work item selection with fzf
#
# Requirements:
#   - Azure CLI (az)
#   - Azure DevOps extension
#   - jq (JSON processor)
#   - fzf (fuzzy finder)
# ============================================================================

gdev() {
    # ========================================
    # Pre-flight checks
    # ========================================
    
    # Verify we're in a git repository
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        echo "❌ Error: Not in a git repository"
        return 1
    fi

    # Check for Azure CLI installation
    if ! command -v az &>/dev/null; then
        echo "❌ Error: Azure CLI is not installed"
        echo "   Install with: brew install azure-cli"
        return 1
    fi

    # Check for required dependencies
    if ! command -v jq &>/dev/null; then
        echo "❌ Error: jq is not installed"
        echo "   Install with: brew install jq"
        return 1
    fi

    if ! command -v fzf &>/dev/null; then
        echo "❌ Error: fzf is not installed"
        echo "   Install with: brew install fzf"
        return 1
    fi

    # Ensure Azure DevOps extension is installed
    if ! az extension list --query "[?name=='azure-devops'].name" -o tsv 2>/dev/null | grep -q "azure-devops"; then
        echo "📦 Installing Azure DevOps extension..."
        az extension add --name azure-devops --only-show-errors
        if [[ $? -ne 0 ]]; then
            echo "❌ Failed to install Azure DevOps extension"
            return 1
        fi
    fi

    # Verify Azure authentication
    if ! az account show &>/dev/null; then
        echo "🔐 Please login to Azure DevOps:"
        az login --allow-no-subscriptions
        if [[ $? -ne 0 ]]; then
            echo "❌ Login failed"
            return 1
        fi
    fi

    # ========================================
    # Extract organization and project
    # ========================================
    
    local git_remote=$(git remote get-url origin 2>/dev/null)
    local org_url=""
    local project=""

    # Parse Azure DevOps URL from git remote
    # Supports both formats:
    #   - https://dev.azure.com/org/project/_git/repo
    #   - https://org.visualstudio.com/project/_git/repo
    if [[ "$git_remote" =~ "dev.azure.com" ]]; then
        local temp="${git_remote#*dev.azure.com/}"
        org_url="${temp%%/*}"
        temp="${temp#*/}"
        project="${temp%%/*}"
    elif [[ "$git_remote" =~ "visualstudio.com" ]]; then
        local temp="${git_remote#*https://}"
        org_url="${temp%%.visualstudio.com*}"
        temp="${git_remote#*visualstudio.com/}"
        project="${temp%%/*}"
        # URL decode project name (e.g., %20 -> space)
        project=$(echo "$project" | sed 's/%20/ /g')
    fi

    # Fallback to configured Azure DevOps settings
    if [[ -z "$org_url" ]] || [[ "$org_url" == "null" ]]; then
        local configured_org=$(az devops configure -l 2>/dev/null | grep 'organization' | cut -d'=' -f2 | xargs | sed 's|https://dev.azure.com/||' | sed 's|/$||')
        if [[ -n "$configured_org" ]] && [[ "$configured_org" != "null" ]]; then
            org_url="$configured_org"
        else
            org_url=""
        fi
    fi

    # Prompt for organization if not found
    if [[ -z "$org_url" ]]; then
        echo ""
        echo "🏢 Enter your Azure DevOps organization name:"
        echo "   Example: 'certia' for https://dev.azure.com/certia"
        echo -n "   > "
        read -r org_url
        org_url=$(echo "$org_url" | sed 's|https://dev.azure.com/||' | sed 's|/$||' | xargs)
    fi

    if [[ -z "$org_url" ]]; then
        echo "❌ Organization is required"
        return 1
    fi

    # Set full organization URL and configure defaults
    local org_full="https://dev.azure.com/$org_url"
    az devops configure --defaults organization="$org_full" &>/dev/null

    # ========================================
    # Get or select project
    # ========================================
    
    if [[ -z "$project" ]]; then
        project=$(az devops configure -l 2>/dev/null | grep 'project' | cut -d'=' -f2 | xargs)
    fi

    # Interactive project selection if not found
    if [[ -z "$project" ]]; then
        echo ""
        echo "📋 Fetching projects..."
        local projects_json=$(az devops project list --org "$org_full" 2>/dev/null)
        
        if [[ -n "$projects_json" ]] && [[ "$projects_json" != "[]" ]]; then
            local project_names=$(echo "$projects_json" | jq -r '.value[]?.name // empty' 2>/dev/null)
            if [[ -n "$project_names" ]]; then
                project=$(echo "$project_names" | fzf --height=15 --border --prompt="Select project: " --header="Use ↑↓ arrows, Enter to select")
            fi
        fi
        
        # Manual input if fzf was cancelled or no projects found
        if [[ -z "$project" ]]; then
            echo ""
            echo "📝 Enter project name:"
            echo -n "   > "
            read -r project
        fi
    fi

    if [[ -z "$project" ]]; then
        echo "❌ Project is required"
        return 1
    fi

    # Save project as default
    az devops configure --defaults project="$project" &>/dev/null
    
    # ========================================
    # Query work items
    # ========================================
    
    echo ""
    echo "🔍 Fetching your work items from: $org_url/$project"

    local work_items=""
    
    # Query 1: Active work items assigned to me
    work_items=$(az boards query --org "$org_full" --project "$project" \
        --wiql "SELECT [System.Id], [System.WorkItemType], [System.Title], [System.State] FROM WorkItems WHERE [System.AssignedTo] = @Me AND [System.State] IN ('Active', 'In Progress', 'Committed', 'Development', 'New') ORDER BY [System.ChangedDate] DESC" \
        --output json 2>/dev/null)

    # Query 2: All non-completed work items assigned to me
    if [[ -z "$work_items" ]] || [[ "$work_items" == "[]" ]]; then
        work_items=$(az boards query --org "$org_full" --project "$project" \
            --wiql "SELECT [System.Id], [System.WorkItemType], [System.Title], [System.State] FROM WorkItems WHERE [System.AssignedTo] = @Me AND [System.State] NOT IN ('Removed', 'Closed', 'Done') ORDER BY [System.ChangedDate] DESC" \
            --output json 2>/dev/null)
    fi

    # Query 3: All work items assigned to me (including completed)
    if [[ -z "$work_items" ]] || [[ "$work_items" == "[]" ]]; then
        work_items=$(az boards query --org "$org_full" --project "$project" \
            --wiql "SELECT [System.Id], [System.WorkItemType], [System.Title], [System.State] FROM WorkItems WHERE [System.AssignedTo] = @Me ORDER BY [System.ChangedDate] DESC" \
            --output json 2>/dev/null)
    fi

    if [[ -z "$work_items" ]] || [[ "$work_items" == "[]" ]]; then
        echo "❌ No work items found assigned to you"
        echo "   Check: $org_full/$project/_workitems"
        return 1
    fi

    # ========================================
    # Select work item
    # ========================================
    
    # Format and display work items with fzf
    local selected=$(echo "$work_items" | jq -r '.[]? | "\(.fields["System.Id"]) | \(.fields["System.WorkItemType"]) | \(.fields["System.State"]) | \(.fields["System.Title"])"' 2>/dev/null | \
        fzf --height=20 --border --prompt="Select work item: " --header="ID | Type | State | Title" --preview-window=hidden)

    if [[ -z "$selected" ]]; then
        echo "❌ No work item selected"
        return 1
    fi

    # ========================================
    # Create branch
    # ========================================
    
    # Parse selected work item
    local work_item_id=$(echo "$selected" | cut -d'|' -f1 | xargs)
    local work_item_type=$(echo "$selected" | cut -d'|' -f2 | xargs)
    local work_item_title=$(echo "$selected" | cut -d'|' -f4 | xargs)

    # Sanitize title for branch name (lowercase, alphanumeric with hyphens, max 50 chars)
    local sanitized_title=$(echo "$work_item_title" | \
        tr '[:upper:]' '[:lower:]' | \
        sed 's/[^a-z0-9]/-/g' | \
        sed 's/--*/-/g' | \
        sed 's/^-//' | \
        sed 's/-$//' | \
        cut -c1-50)

    # Determine branch prefix based on work item type
    local prefix="feature"
    if [[ "$work_item_type" =~ [Bb]ug ]]; then
        prefix="fix"
    fi

    local branch_name="${prefix}/${work_item_id}-${sanitized_title}"

    echo ""
    echo "🌿 Creating branch: $branch_name"
    echo ""

    # Create and checkout branch
    if git checkout -b "$branch_name" 2>/dev/null; then
        echo "✅ Successfully created and checked out branch: $branch_name"
        echo "   Work item: $org_full/$project/_workitems/edit/$work_item_id"
        return 0
    else
        echo "❌ Failed to create branch"
        
        # Check if branch already exists
        if git rev-parse --verify "$branch_name" &>/dev/null; then
            echo "   Branch already exists. Checkout with: git checkout $branch_name"
        fi
        
        return 1
    fi
}
