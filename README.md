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

### 🐚 Zsh
Z shell configuration for a powerful command-line experience.
- `.zshrc` - Shell configuration, aliases, and functions
- `.zprofile` - Login shell configuration

## 🔧 Installation

### Prerequisites
- macOS
- [Homebrew](https://brew.sh/)
- [GNU Stow](https://www.gnu.org/software/stow/)

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
   
   # Install AeroSpace
   brew install --cask nikitabobko/tap/aerospace
   
   # Install tmux and gitmux
   brew install tmux
   brew install arl/arl/gitmux
   
   # Zsh is pre-installed on macOS
   ```

3. **Create symlinks with Stow**
   ```bash
   # Stow all configurations
   stow aerospace tmux zsh
   
   # Or stow individual configurations
   stow aerospace
   stow tmux
   stow zsh
   ```

4. **Apply configurations**
   # Reload zsh
   source ~/.zshrc
   
   # Start AeroSpace
   aerospace start
   
   # Reload tmux (if running)
   tmux source-file ~/.tmux.conf
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

## 📝 Customization

Feel free to fork this repository and customize the configurations to your needs. Each configuration file is well-commented to help you understand and modify settings.

## 📄 License

This is a personal configuration repository. Feel free to use anything you find useful!

## 🙏 Acknowledgments

Thanks to the open-source community for the amazing tools that make development on macOS enjoyable.