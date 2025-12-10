# Custom Scripts

This directory contains custom shell scripts that are automatically loaded by `.zshrc`.

## Azure DevOps Helper (`gdev`)

Creates git branches from Azure DevOps work items in development.

### Setup

1. **Install Azure CLI:**
   ```bash
   brew install azure-cli
   ```

2. **Install Azure DevOps extension:**
   ```bash
   az extension add --name azure-devops
   ```

3. **Login to Azure DevOps:**
   ```bash
   az login --allow-no-subscriptions
   ```
   
   Note: Use `--allow-no-subscriptions` flag if you only have Azure DevOps access without Azure subscriptions.

4. **Set default organization and project (optional):**
   ```bash
   az devops configure --defaults organization=https://dev.azure.com/YOUR_ORG project=YOUR_PROJECT
   ```

### Usage

```bash
# In any git repository
gdev
```

The command will:
1. Auto-detect or prompt for your Azure DevOps organization
2. Show an fzf menu to select your project (if not configured)
3. Fetch work items in development (Active, In Progress, etc.)
4. Show an fzf menu to select a work item
5. Create and checkout a branch named: `<work-item-id>-<sanitized-title>`

### Examples

If you select work item #12345 titled "Implement User Authentication":
```
Branch created: 12345-implement-user-authentication
```

### Troubleshooting

**"Could not list projects"**
- Make sure you've logged in: `az login --allow-no-subscriptions`
- Verify you have access to the organization in your browser
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
