# VS Code Configuration

This directory contains VS Code settings, keybindings, and extensions.

## Installation

### 1. Stow the configuration

```bash
cd ~/dotfiles
stow vscode
```

This will create a symlink from `~/.config/Code` to `~/Library/Application Support/Code`.

### 2. Install extensions

```bash
cat ~/.config/Code/User/extensions.txt | xargs -L 1 code --install-extension
```

Or manually install each extension from the list in `extensions.txt`.

## Files

- `settings.json` - VS Code settings
- `keybindings.json` - Custom keybindings
- `extensions.txt` - List of installed extensions

## Updating

To update the extensions list after installing new extensions:

```bash
code --list-extensions > ~/.config/Code/User/extensions.txt
```
