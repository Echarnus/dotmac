# dotmac

Personal macOS dotfiles for system configuration and development environment setup.

## 📦 What's Included

### 🚀 Aerospace
Window management configuration for [AeroSpace](https://github.com/nikitabobko/AeroSpace), a tiling window manager for macOS.
- `.aerospace.toml` - Main configuration file

### 💻 Tmux
Terminal multiplexer configuration for enhanced terminal productivity.
- `.tmux.conf` - Tmux settings and keybindings
- `.gitmux.conf` - Git status integration for tmux status bar
- `.tmux-status-bar-left.sh` / `.tmux-status-bar-right.sh` - Custom status bar with technology version detection (󰪮 .NET,  Angular,  React,  Python)

### 🐚 Zsh
Z shell configuration for a powerful command-line experience.
- `.zshrc` - Shell configuration, aliases, and functions with Oh My Zsh integration
- `.zprofile` - Login shell configuration
- Uses [Agnoster theme](https://github.com/agnosterj/agnoster-zsh-theme) with git status disabled (shown in tmux instead)

### 🤖 Claude Code Skills & Agents
Personal Claude Code **skills** and **agents** are kept in a **separate private repo**
— [`Echarnus/Claude`](https://github.com/Echarnus/Claude) — since some skills contain
company-internal logic. They are **not** stored in this repo; dotmac only references them.

Install (clone the private repo, then symlink each skill/agent into `~/.claude` so
`git pull` keeps them current):

```bash
# requires access to the private repo (GitHub auth: `gh auth login`)
git clone https://github.com/Echarnus/Claude.git ~/Developer/Claude
mkdir -p ~/.claude/skills ~/.claude/agents
for d in ~/Developer/Claude/skills/*/; do
  [ -f "$d/SKILL.md" ] && ln -sfn "$d" ~/.claude/skills/"$(basename "$d")"
done
for f in ~/Developer/Claude/agents/*.md; do
  ln -sfn "$f" ~/.claude/agents/"$(basename "$f")"
done
```

Claude Code auto-discovers `~/.claude/skills` and `~/.claude/agents` on start.
For the **Claude Desktop** app, skills are added via *Customize → Skills* (upload a zip).

### 📝 Neovim
LazyVim configuration with modern development features.
- **Configuration files**:
  - `lua/config/options.lua` - Editor settings (line numbers, clipboard, tabs)
  - `lua/config/keymaps.lua` - Custom keybindings
  - `lua/plugins/neo-tree.lua` - File explorer configuration
  - `lua/plugins/colorscheme.lua` - Theme configuration
- **Features**:
  - LazyVim-based setup with automatic plugin management
  - Neo-tree file explorer positioned on the right side (width: 35)
  - Tokyo Night color scheme
  - Full LSP, autocompletion, and syntax highlighting support
  - Git status integration in file explorer
  - Relative line numbers with clipboard integration

## 🔧 Installation

### Prerequisites
- macOS
- [Homebrew](https://brew.sh/)
- [GNU Stow](https://www.gnu.org/software/stow/)
- **Nerd Font** - Required for icons to display properly (recommended: [JetBrainsMono Nerd Font](https://www.nerdfonts.com/))

### Quick Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/Echarnus/dotmac.git ~/dotfiles
   cd ~/dotfiles
   ```

2. **Install dependencies**
   ```bash
   # Install GNU Stow
   brew install stow
   
   # Install Nerd Font (required for icons)
   brew install font-jetbrains-mono-nerd-font
   
   # Install AeroSpace
   brew install --cask nikitabobko/tap/aerospace
   
   # Install tmux and gitmux
   brew install tmux
   brew install arl/arl/gitmux
   
   # Install Oh My Zsh (if not already installed)
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
   
   # Install Zsh plugins
   brew install zsh-autosuggestions
   brew install zsh-syntax-highlighting
   brew install zoxide  # Modern cd replacement
   brew install fzf     # Fuzzy finder
   
   # Install neofetch (optional, for system info display)
   brew install neofetch
   ```

3. **Create symlinks with Stow**
   ```bash
   # Stow all configurations
   stow aerospace tmux zsh nvim
   
   # Or stow individual configurations
   stow aerospace
   stow tmux
   stow zsh
   stow nvim
   ```

4. **Configure your terminal font**
   - Open iTerm2 (or your terminal) Preferences
   - Go to Profiles → Text
   - Set Font to "JetBrainsMono Nerd Font" (or another Nerd Font)
   - Apply to both "Font" and "Non-ASCII Font"

5. **Apply configurations**
   ```bash
   # Reload zsh
   source ~/.zshrc
   
   # Start AeroSpace
   aerospace start
   
   # Start or reload tmux
   tmux
   # Or reload existing session: Ctrl+b then r
   ```

## 🔄 Updating

To update your dotfiles:

```bash
cd ~/dotfiles
git pull
```

Reload the respective configuration:
- Zsh: `source ~/.zshrc`
- Tmux: `tmux source-file ~/.tmux.conf`
- AeroSpace: Restart the application

## ✨ Features

### Tmux Status Bar
The custom status bar automatically detects and displays:
- **Technology versions** with icons:
  - 󰪮 .NET (searches up to 3 levels deep for `.csproj` files)
  -  Angular (detects from `angular.json` and `package.json`)
  -  React (detects from `package.json`)
  -  Python (detects from `requirements.txt`, `pyproject.toml`, or `setup.py`)
- **Git status** via gitmux integration
-  **Date and time** with icons
- Color-coded icons (dimmed) and values (bright/bold) for better visual hierarchy

### Zsh Configuration
- **Oh My Zsh** with Agnoster theme
- **Plugins**:
  - `git` - Git aliases and functions
  - `zsh-autosuggestions` - Fish-like autosuggestions
  - `dotnet` - .NET CLI completions
  - `docker` & `docker-compose` - Docker completions
- **Custom aliases**:
  - `ls='ls -Gla'` - Detailed colorized listing
  - `clr='clear'` - Quick clear
  - `py='python3'` - Python shortcut
- **Integrations**:
  - Angular CLI autocompletion
  - fzf fuzzy finder
  - zoxide (smart cd)
  - Syntax highlighting

### AeroSpace
Tiling window manager for macOS with vim-like keybindings.

## 📝 Customization

Feel free to fork this repository and customize the configurations to your needs. Each configuration file is well-commented to help you understand and modify settings.

### Customizing the Status Bar
Edit `tmux/status-bar.sh` to:
- Add more technology detections
- Change icon colors (modify the color variables at the top)
- Adjust search depth for project files
- Add custom status information

## 📄 License

This is a personal configuration repository. Feel free to use anything you find useful!

## 🙏 Acknowledgments

Thanks to the open-source community for the amazing tools that make development on macOS enjoyable.