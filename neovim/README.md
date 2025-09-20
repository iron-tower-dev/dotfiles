# Neovim Configuration

This directory contains a comprehensive Neovim configuration using Lazy.nvim plugin manager with Catppuccin theming.

## Features

### Core Configuration
- **Lazy.nvim**: Modern plugin manager with lazy loading
- **Catppuccin Macchiato**: Consistent theming matching the desktop environment
- **Treesitter**: Advanced syntax highlighting and code understanding
- **LSP Support**: Language Server Protocol integration via blink.cmp
- **Modern UI**: Clean interface with transparent backgrounds

### Key Plugins

#### Completion & LSP
- **blink.cmp**: Fast completion engine with LSP, buffer, and snippet support
- **blink-emoji**: Emoji completion for markdown and git commits
- **cmp-sql**: SQL completion support

#### Navigation & File Management
- **fzf-lua**: Fast fuzzy finder for files, grep, buffers, and more
- **oil.nvim**: File explorer that works like a buffer
- **project.nvim**: Project management and detection
- **project-fzf.nvim**: Project-aware fuzzy finding

#### Editing Enhancement
- **mini.nvim**: Collection of minimal useful plugins:
  - `mini.ai`: Enhanced text objects
  - `mini.surround`: Surround text objects
  - `mini.comment`: Smart commenting
  - `mini.pairs`: Auto-pairing of brackets
  - `mini.move`: Move lines and selections
  - `mini.indentscope`: Indent scope visualization
  - `mini.cursorword`: Highlight word under cursor
  - `mini.trailspace`: Trailing whitespace management
  - `mini.statusline`: Minimal status line
  - `mini.notify`: Notification system
  - `mini.bufremove`: Smart buffer deletion

#### Language Support
- **rustaceanvim**: Enhanced Rust development
- **nvim-treesitter-textobjects**: Advanced text objects based on treesitter
- **vim-sleuth**: Automatic indentation detection

#### UI & UX
- **which-key.nvim**: Key binding hints and discovery
- **dressing.nvim**: Improved UI for input and select

## Installation

The configuration is automatically deployed when running:
```bash
stow -t ~ neovim
```

Or as part of the full dotfiles deployment:
```bash
./bootstrap.sh --dotfiles
```

## Key Bindings

### Leader Key
The leader key is set to `<Space>` (default).

### File Navigation
- `<leader>ff` - Find files in project
- `<leader>fg` - Live grep in project
- `<leader>fc` - Find files in Neovim config
- `<leader>fb` - Find in FZF builtins
- `<leader>fo` - Find old/recent files
- `<leader><leader>` - Find open buffers
- `<leader>/` - Live grep current buffer

### Buffer Management
- `<leader>bn` - Next buffer
- `<leader>bp` - Previous buffer

### Window Management
- `<C-h/j/k/l>` - Navigate between windows
- `<leader>sv` - Split vertically
- `<leader>sh` - Split horizontally
- `<C-Up/Down/Left/Right>` - Resize windows

### File Explorer
- `<leader>e` - Toggle file explorer
- `<leader>m` - Focus file explorer

### Search & Navigation
- `n/N` - Next/previous search result (centered)
- `<C-d/u>` - Half page down/up (centered)
- `J` - Join lines (keep cursor position)

### Configuration
- `<leader>rc` - Edit init.lua

### Help & Discovery
- `<leader>fh` - Find help tags
- `<leader>fk` - Find keymaps
- `<leader>fw` - Find word under cursor
- `<leader>fd` - Find diagnostics
- `<leader>fr` - Resume last search

## Configuration Structure

```
neovim/.config/nvim/
├── init.lua                    # Entry point
├── lazy-lock.json             # Plugin lockfile
└── lua/
    ├── config/
    │   ├── lazy.lua           # Plugin manager setup
    │   ├── options.lua        # Neovim options
    │   ├── keymaps.lua        # Key mappings
    │   ├── autocmds.lua       # Auto commands
    │   └── globals.lua        # Global variables
    └── plugins/
        ├── blink-cmp.lua      # Completion engine
        ├── catppuccin.lua     # Color scheme
        ├── fzf-lua.lua        # Fuzzy finder
        ├── oil.lua            # File manager
        ├── mini.lua           # Mini plugin suite
        ├── rustacean.lua      # Rust support
        ├── dressing.lua       # UI improvements
        ├── which-key.lua      # Key hints
        ├── sleuth-vim.lua     # Auto indentation
        ├── project.lua        # Project management
        ├── project-fzf.lua    # Project fuzzy finding
        └── nvim-treesitter*.lua # Syntax highlighting
```

## Dependencies

The following packages are required and installed via the dotfiles setup:
- `neovim` - The editor itself
- `ripgrep` - Fast grep tool (used by fzf-lua)
- `fd` - Fast find tool
- `fzf` - Fuzzy finder binary
- `git` - Version control (for plugin management)
- Nerd fonts (JetBrains Mono) - For icons

## Customization

### Adding Plugins
Add new plugin specifications to the `lua/plugins/` directory. Each file should return a plugin spec compatible with lazy.nvim.

### Modifying Options
Edit `lua/config/options.lua` to change Neovim settings.

### Custom Keybindings
Add custom keymaps to `lua/config/keymaps.lua`.

### Theme Customization
The Catppuccin theme is configured in `lua/plugins/catppuccin.lua` with transparent backgrounds to match the desktop theme.

## Language Server Setup

The configuration supports LSP via blink.cmp. Language servers should be installed via Mise or your system package manager:

```bash
# Example: Install language servers via Mise
mise install node@lts
npm install -g typescript-language-server
mise install rust@stable  # Includes rust-analyzer
mise install go@latest    # Includes gopls
```

## Troubleshooting

### Plugin Issues
```bash
# Update all plugins
:Lazy update

# Check plugin status
:Lazy

# Clear plugin cache
rm -rf ~/.local/share/nvim/lazy/
```

### LSP Issues
```bash
# Check LSP status
:LspInfo

# Restart LSP servers
:LspRestart
```

### Performance Issues
The configuration is optimized for performance with lazy loading and efficient plugins. If you experience issues:
1. Check `:checkhealth` for problems
2. Use `:Lazy profile` to identify slow plugins
3. Ensure ripgrep and fd are installed for fast file operations

## Migration Notes

This configuration uses modern Neovim features and plugins:
- Lazy.nvim instead of packer or vim-plug
- blink.cmp instead of nvim-cmp (faster Rust-based completion)
- oil.nvim instead of nvim-tree (buffer-based file management)
- mini.nvim suite for lightweight, consistent plugins

If migrating from an older configuration, some keybindings and plugin APIs may differ.
