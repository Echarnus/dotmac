# LazyVim Configuration with Right-Side File Explorer

## Installation

1. **Backup existing config** (if any):
   ```bash
   mv ~/.config/nvim ~/.config/nvim.backup
   ```

2. **Create symlink from dotfiles**:
   ```bash
   ln -s ~/dotfiles/nvim ~/.config/nvim
   ```

3. **Launch Neovim**:
   ```bash
   nvim
   ```
   LazyVim will automatically install all plugins on first launch.

## File Explorer Usage (Neo-tree on Right Side)

### Opening/Closing the Explorer

- **Toggle Explorer**: Press `<Space>e` (Leader key + e)
- **Focus Explorer**: Press `<Space>fe` (Leader key + f + e)
- **Close Explorer**: Press `q` when focused on the explorer

### Navigation

- **j/k** or **Arrow keys**: Move up/down
- **Enter** or **o**: Open file/folder
- **h**: Close folder
- **l**: Open folder
- **C**: Close node (folder)
- **z**: Close all nodes

### File Operations

- **a**: Add new file
- **A**: Add new directory
- **d**: Delete file/directory
- **r**: Rename file/directory
- **c**: Copy file
- **m**: Move file
- **y**: Copy to clipboard
- **x**: Cut to clipboard
- **p**: Paste from clipboard

### Window Splits

- **s**: Open in vertical split
- **S**: Open in horizontal split
- **t**: Open in new tab

### Other Commands

- **R**: Refresh the tree
- **?**: Show help with all keybindings

## Common LazyVim Keybindings

- **Leader key**: `<Space>`
- **<Space>ff**: Find files
- **<Space>fg**: Live grep (search in files)
- **<Space>fb**: List buffers
- **<Space>/**: Search in current buffer
- **<C-/>**: Toggle terminal
- **<Space>w**: Save file
- **<Space>q**: Quit

## Configuration Files

- `init.lua`: Entry point
- `lua/config/lazy.lua`: Lazy.nvim setup
- `lua/config/options.lua`: Vim options
- `lua/config/keymaps.lua`: Custom keybindings
- `lua/plugins/neo-tree.lua`: File explorer config
- `lua/plugins/colorscheme.lua`: Theme configuration

## Customization

To modify the explorer position, width, or behavior, edit `lua/plugins/neo-tree.lua`.
