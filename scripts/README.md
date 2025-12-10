# Custom Scripts

This directory contains custom shell scripts that are automatically loaded by `.zshrc`.

## Scripts Overview

- **`azure-devops.sh`** - Azure DevOps integration for creating branches from work items
- **`git-aliases.sh`** - Convenient git shortcuts and workflow helpers

---

## Azure DevOps Helper (`gdev`)

Creates git branches from Azure DevOps work items assigned to you.

### Setup

1. **Install Azure CLI:**
   ```bash
   brew install azure-cli
   ```

2. **Install required dependencies:**
   ```bash
   brew install jq fzf
   ```

3. **Install Azure DevOps extension:**
   ```bash
   az extension add --name azure-devops
   ```

4. **Login to Azure DevOps:**
   ```bash
   az login --allow-no-subscriptions
   ```
   
   Note: Use `--allow-no-subscriptions` flag if you only have Azure DevOps access without Azure subscriptions.

5. **Set default organization and project (optional):**
   ```bash
   az devops configure --defaults organization=https://dev.azure.com/YOUR_ORG project=YOUR_PROJECT
   ```

### Usage

```bash
# In any git repository
gdev
# or
g d
```

The command will:
1. Auto-detect organization and project from git remote URL
2. Fallback to configured defaults or prompt for input
3. Fetch work items assigned to you (prioritizes active items)
4. Show an interactive fzf menu to select a work item
5. Create and checkout a branch with appropriate prefix:
   - **Bug** → `fix/<work-item-id>-<sanitized-title>`
   - **Other types** → `feature/<work-item-id>-<sanitized-title>`

### Examples

**Bug work item #12345** titled "Fix Login Button":
```bash
# Creates: fix/12345-fix-login-button
```

**Feature work item #67890** titled "Implement User Authentication":
```bash
# Creates: feature/67890-implement-user-authentication
```

### Supported URL Formats

- `https://dev.azure.com/org/project/_git/repo`
- `https://org.visualstudio.com/project/_git/repo`

### Troubleshooting

**"Could not list projects"**
- Make sure you've logged in: `az login --allow-no-subscriptions`
- Verify you have access to the organization in your browser

**"No work items found"**
- Ensure you have work items assigned to you in Azure DevOps
- Check the work item states (Active, In Progress, etc.)

---

## Git Aliases (`g`)

Convenient shortcuts for common git operations.

### Available Commands

| Command | Description | Example |
|---------|-------------|---------|
| `g c [branch]` | Checkout branch (interactive if no branch specified) | `g c main` |
| `g d` | Create branch from Azure DevOps work item | `g d` |
| `g m <branch>` | Merge specified branch into current branch | `g m feature-123` |
| `g cpm <branch>` | Checkout, pull, return, and merge branch | `g cpm main` |

### Usage Examples

#### Basic Checkout
```bash
# Checkout specific branch
g c main

# Interactive branch selection (uses fzf)
g c
```

#### Create Branch from Work Item
```bash
# Same as running 'gdev'
g d
```

#### Merge Branch
```bash
# Merge feature branch into current branch
g m feature/12345-new-feature
```

#### Checkout-Pull-Merge (CPM)
```bash
# Update main branch and merge into current branch
g cpm main
```

The `g cpm` command workflow:
1. 📍 Saves your current branch
2. ✓ Checks out target branch (e.g., `main`)
3. ⬇️ Pulls latest changes
4. ↩️ Returns to your original branch
5. 🔀 Merges the target branch

**Perfect for:** Keeping your feature branch up-to-date with `main` or `develop` without leaving your current work.

### Interactive Features

- **Branch selection** with fzf when no branch is specified
- **Uncommitted changes warning** before checkout-pull-merge
- **Detailed progress feedback** for multi-step operations
- **Automatic conflict detection** with helpful error messages

---

## Notes

- All scripts are automatically loaded by `.zshrc` on shell startup
- Scripts support both interactive and non-interactive modes
- Error handling includes helpful suggestions for resolution
- Manually enter your organization name when prompted

**"No work items found"**
- Check if work items exist in development states
- Visit: `https://dev.azure.com/YOUR_ORG/YOUR_PROJECT/_workitems`
- Verify you have permissions to view work items

**"Error: Organization is required"**
- The script couldn't detect your org from git remote
- Manually enter it when prompted (just the org name, e.g., "certia")

### Tips

- First run in a repository might prompt for org/project
- Subsequent runs will remember your defaults
- Use `az devops configure --list` to see current defaults
