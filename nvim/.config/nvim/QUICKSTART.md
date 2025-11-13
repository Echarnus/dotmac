# Quick Reference - Neovim with LazyVim

## First Launch
When you first open `nvim`, you'll see a blank editor. The file explorer is **hidden by default**.

## Toggle File Explorer (Neo-tree)
- **`Space + e`** - Toggle the file explorer on/off (appears on RIGHT side)
- **`Space + f + e`** - Focus the file explorer

## Inside the File Explorer
- **`Enter`** or **`o`** - Open file/folder
- **`h`** - Close folder
- **`l`** - Open folder  
- **`a`** - Add new file
- **`A`** - Add new directory
- **`d`** - Delete
- **`r`** - Rename
- **`s`** - Open in vertical split
- **`S`** - Open in horizontal split
- **`q`** - Close explorer
- **`?`** - Show all commands

## Common LazyVim Commands
- **`Space + f + f`** - Find files (fuzzy finder)
- **`Space + /`** - Search in current file
- **`Space + Space`** - Find buffers
- **`:q`** - Quit
- **`:w`** - Save
- **`:wq`** - Save and quit

## Tips
- The explorer **doesn't show automatically** - you must press `Space + e`
- Plugins load automatically on first launch
- If you don't see plugins, run `:Lazy sync` inside nvim
