#!/bin/bash
# Tmux status bar LEFT - version tags only

PANE_PATH="${1:-$(pwd)}"

output=""

# Check if we're in a git repository and get the root
if cd "$PANE_PATH" && GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null); then
    
    # .NET version (check in git repo root for .NET project files)
    if command -v dotnet &> /dev/null; then
        if ls "$GIT_ROOT"/*.csproj &>/dev/null || ls "$GIT_ROOT"/*.sln &>/dev/null || [[ -f "$GIT_ROOT"/global.json ]] || [[ -f "$GIT_ROOT"/Directory.Build.props ]]; then
            # Priority: Directory.Build.props > global.json > .csproj files
            if [[ -f "$GIT_ROOT"/Directory.Build.props ]]; then
                dotnet_version=$(grep '<TargetFramework>net' "$GIT_ROOT"/Directory.Build.props 2>/dev/null | sed -E 's/.*<TargetFramework>net([0-9.]+).*/\1/' | head -1)
            fi
            if [[ -z "$dotnet_version" ]] && [[ -f "$GIT_ROOT"/global.json ]]; then
                dotnet_version=$(grep '"version"' "$GIT_ROOT"/global.json 2>/dev/null | sed -E 's/.*"version"[[:space:]]*:[[:space:]]*"([0-9]+\.[0-9]+).*/\1/')
            fi
            if [[ -z "$dotnet_version" ]]; then
                # Try to find TargetFramework in .csproj files
                dotnet_version=$(grep '<TargetFramework>net' "$GIT_ROOT"/*.csproj 2>/dev/null | sed -E 's/.*<TargetFramework>net([0-9.]+).*/\1/' | head -1)
            fi
            if [[ -n "$dotnet_version" ]]; then
                output+="#[fg=colour81] # .NET ${dotnet_version}  "
            fi
        fi
    fi

    # Angular version (check in git repo root and subdirectories)
    angular_json=$(find "$GIT_ROOT" -name "angular.json" -not -path "*/node_modules/*" -not -path "*/.angular/*" 2>/dev/null | head -1)
    if [[ -n "$angular_json" ]]; then
        angular_dir=$(dirname "$angular_json")
        if [[ -f "$angular_dir"/package.json ]]; then
            ng_version=$(grep '"@angular/core"' "$angular_dir"/package.json 2>/dev/null | sed -E 's/.*"@angular\/core"[[:space:]]*:[[:space:]]*"\^?([0-9]+).*/\1/')
            if [[ -n "$ng_version" ]]; then
                output+="#[fg=colour208] ⚡ ng ${ng_version}  "
            fi
        fi
    fi

    # Python version (check in git repo root and subdirectories)
    if find "$GIT_ROOT" -maxdepth 2 \( -name "requirements.txt" -o -name "pyproject.toml" -o -name "setup.py" \) 2>/dev/null | grep -q .; then
        if command -v python3 &> /dev/null; then
            # Check for .python-version file or use system version
            if [[ -f "$GIT_ROOT"/.python-version ]]; then
                python_version=$(cat "$GIT_ROOT"/.python-version 2>/dev/null | cut -d'.' -f1-2)
            else
                python_version=$(python3 --version 2>/dev/null | awk '{print $2}' | cut -d'.' -f1-2)
            fi
            if [[ -n "$python_version" ]]; then
                output+="#[fg=colour228] 🐍 py ${python_version}  "
            fi
        fi
    fi

    # React version (check in git repo root and subdirectories - exclude Angular projects)
    if [[ -z "$angular_json" ]]; then
        package_json=$(find "$GIT_ROOT" -maxdepth 3 -name "package.json" -not -path "*/node_modules/*" -not -path "*/.angular/*" 2>/dev/null | head -1)
        if [[ -n "$package_json" ]]; then
            react_version=$(grep '"react"' "$package_json" 2>/dev/null | sed -E 's/.*"react"[[:space:]]*:[[:space:]]*"\^?([0-9]+).*/\1/')
            if [[ -n "$react_version" ]]; then
                output+="#[fg=colour81] ⚛ react ${react_version}  "
            fi
        fi
    fi
fi

echo "$output"
