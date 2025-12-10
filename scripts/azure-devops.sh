#!/bin/zsh

# Azure DevOps Helper Script
# Creates a new branch from a work item in development
# Usage: gdev

gdev() {
    # Check if we're in a git repository
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        echo "❌ Error: Not in a git repository"
        return 1
    fi

    # Check if Azure DevOps CLI is installed
    if ! command -v az &>/dev/null; then
        echo "❌ Error: Azure CLI is not installed"
        echo "Install with: brew install azure-cli"
        return 1
    fi

    # Check if devops extension is installed
    if ! az extension list --query "[?name=='azure-devops'].name" -o tsv 2>/dev/null | grep -q "azure-devops"; then
        echo "📦 Installing Azure DevOps extension..."
        az extension add --name azure-devops --only-show-errors
    fi

    # Check if logged in to Azure
    if ! az account show &>/dev/null; then
        echo "🔐 Please login to Azure DevOps:"
        az login --allow-no-subscriptions
        if [[ $? -ne 0 ]]; then
            echo "❌ Login failed"
            return 1
        fi
    fi

    # Get the organization and project from git remote
    local git_remote=$(git remote get-url origin 2>/dev/null)
    local org_url=""
    local project=""

    # Extract org and project from Azure DevOps URL
    if [[ "$git_remote" =~ "dev.azure.com" ]]; then
        # Format: https://dev.azure.com/org/project/_git/repo
        local temp="${git_remote#*dev.azure.com/}"
        org_url="${temp%%/*}"
        temp="${temp#*/}"
        project="${temp%%/*}"
    elif [[ "$git_remote" =~ "visualstudio.com" ]]; then
        # Format: https://org.visualstudio.com/project/_git/repo
        local temp="${git_remote#*https://}"
        org_url="${temp%%.visualstudio.com*}"
        temp="${git_remote#*visualstudio.com/}"
        project="${temp%%/*}"
        # URL decode project name (e.g., %20 -> space)
        project=$(echo "$project" | sed 's/%20/ /g')
    fi

    # Try to get from az devops configure if not from git
    if [[ -z "$org_url" ]] || [[ "$org_url" == "null" ]]; then
        local configured_org=$(az devops configure -l 2>/dev/null | grep 'organization' | cut -d'=' -f2 | xargs | sed 's|https://dev.azure.com/||' | sed 's|/$||')
        if [[ -n "$configured_org" ]] && [[ "$configured_org" != "null" ]]; then
            org_url="$configured_org"
        else
            org_url=""
        fi
    fi

    # Prompt for organization if still not found
    if [[ -z "$org_url" ]]; then
        echo ""
        echo "Enter your Azure DevOps organization name:"
        echo "  (e.g., 'certia' for https://dev.azure.com/certia)"
        echo -n "> "
        read -r org_url
        org_url=$(echo "$org_url" | sed 's|https://dev.azure.com/||' | sed 's|/$||' | xargs)
    fi

    if [[ -z "$org_url" ]]; then
        echo "❌ Organization is required"
        return 1
    fi

    local org_full="https://dev.azure.com/$org_url"
    az devops configure --defaults organization="$org_full" &>/dev/null

    # Get project if not detected
    if [[ -z "$project" ]]; then
        project=$(az devops configure -l 2>/dev/null | grep 'project' | cut -d'=' -f2 | xargs)
    fi

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
        
        if [[ -z "$project" ]]; then
            echo ""
            echo "Enter project name:"
            echo -n "> "
            read -r project
        fi
    fi

    if [[ -z "$project" ]]; then
        echo "❌ Project is required"
        return 1
    fi

    az devops configure --defaults project="$project" &>/dev/null
    
    echo ""
    echo "🔍 Fetching your work items from: $org_url/$project"

    # Query for work items assigned to the logged-in user
    local work_items=""
    
    # Try 1: My work items in active development states
    work_items=$(az boards query --org "$org_full" --project "$project" \
        --wiql "SELECT [System.Id], [System.WorkItemType], [System.Title], [System.State] FROM WorkItems WHERE [System.AssignedTo] = @Me AND [System.State] IN ('Active', 'In Progress', 'Committed', 'Development', 'New') ORDER BY [System.ChangedDate] DESC" \
        --output json 2>/dev/null)

    # Try 2: All my work items (any state except removed/closed)
    if [[ -z "$work_items" ]] || [[ "$work_items" == "[]" ]]; then
        work_items=$(az boards query --org "$org_full" --project "$project" \
            --wiql "SELECT [System.Id], [System.WorkItemType], [System.Title], [System.State] FROM WorkItems WHERE [System.AssignedTo] = @Me AND [System.State] NOT IN ('Removed', 'Closed', 'Done') ORDER BY [System.ChangedDate] DESC" \
            --output json 2>/dev/null)
    fi

    # Try 3: All my work items including completed
    if [[ -z "$work_items" ]] || [[ "$work_items" == "[]" ]]; then
        work_items=$(az boards query --org "$org_full" --project "$project" \
            --wiql "SELECT [System.Id], [System.WorkItemType], [System.Title], [System.State] FROM WorkItems WHERE [System.AssignedTo] = @Me ORDER BY [System.ChangedDate] DESC" \
            --output json 2>/dev/null)
    fi

    if [[ -z "$work_items" ]] || [[ "$work_items" == "[]" ]]; then
        echo "❌ No work items found"
        echo "   Check: $org_full/$project/_workitems"
        return 1
    fi

    # Parse and display with fzf
    local selected=$(echo "$work_items" | jq -r '.[]? | "\(.fields["System.Id"]) | \(.fields["System.WorkItemType"]) | \(.fields["System.State"]) | \(.fields["System.Title"])"' 2>/dev/null | \
        fzf --height=20 --border --prompt="Select work item: " --header="Use ↑↓ arrows, Enter to select" --preview-window=hidden)

    if [[ -z "$selected" ]]; then
        echo "❌ No work item selected"
        return 1
    fi

    # Extract ID, type, and title
    local work_item_id=$(echo "$selected" | cut -d'|' -f1 | xargs)
    local work_item_type=$(echo "$selected" | cut -d'|' -f2 | xargs)
    local work_item_title=$(echo "$selected" | cut -d'|' -f4 | xargs)

    # Sanitize title for branch name
    local sanitized_title=$(echo "$work_item_title" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//' | cut -c1-50)

    # Determine prefix based on work item type
    local prefix=""
    if [[ "$work_item_type" =~ [Bb]ug ]]; then
        prefix="fix"
    else
        prefix="feature"
    fi

    local branch_name="${prefix}/${work_item_id}-${sanitized_title}"

    echo ""
    echo "🌿 Creating branch: $branch_name"
    echo ""

    if git checkout -b "$branch_name" 2>/dev/null; then
        echo "✅ Successfully created and checked out branch: $branch_name"
        return 0
    else
        echo "❌ Failed to create branch (may already exist)"
        echo "   Try: git checkout $branch_name"
        return 1
    fi
}
