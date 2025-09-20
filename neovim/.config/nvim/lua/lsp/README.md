# LSP Configuration

This directory contains a comprehensive LSP (Language Server Protocol) setup for Neovim using modern tools and practices.

## Architecture

### Core Components

- **Mason**: Package manager for LSP servers, formatters, and debuggers
- **nvim-lspconfig**: Official LSP configurations for Neovim
- **blink.cmp**: Fast completion engine (integrates with existing configuration)
- **nvim-dap**: Debug Adapter Protocol for debugging support
- **Fidget**: LSP progress notifications

### Directory Structure

```
lsp/
├── servers/               # Individual LSP server configurations
│   ├── ts_ls.lua         # TypeScript/JavaScript
│   ├── angularls.lua     # Angular
│   ├── elixirls.lua      # Elixir
│   ├── gopls.lua         # Go
│   └── roslyn.lua        # C# (Roslyn)
└── utils/                # Shared utilities
    ├── defaults.lua      # Default LSP configuration
    ├── keymaps.lua       # LSP key bindings
    ├── autocmds.lua      # Auto-commands and diagnostics
    └── dap.lua           # Debugging configuration
```

## Features

### Modern Neovim Integration

- **Native LSP**: Uses Neovim's built-in LSP client
- **Inlay Hints**: Type hints displayed inline (Neovim 0.10+)
- **Semantic Tokens**: Enhanced syntax highlighting
- **Document Highlighting**: Reference highlighting
- **Auto-formatting**: Format on save for configured languages

### Enhanced Diagnostics

- **Custom Signs**: Visual indicators for different diagnostic types
- **Floating Windows**: Hover diagnostics with rounded borders
- **Severity Filtering**: Configurable diagnostic levels
- **Virtual Text**: Inline diagnostic messages

### Completion Integration

- **blink.cmp**: Fast, modern completion engine
- **LSP-based**: Completions from language servers
- **Snippet Support**: Code snippet integration
- **Import Resolution**: Automatic import suggestions

### Debugging Support

- **Multi-language**: Go, JavaScript/TypeScript, C#, Elixir
- **DAP UI**: Visual debugging interface
- **Virtual Text**: Inline variable values
- **Breakpoints**: Conditional and log breakpoints

## Supported Languages

### TypeScript/JavaScript (`ts_ls`)

**Features:**
- Inlay hints for types and parameters
- Import organization and cleanup
- Source definitions navigation
- Automatic formatting

**Key Bindings:**
- `<leader>to` - Organize imports
- `<leader>tu` - Remove unused imports
- `<leader>ta` - Add missing imports
- `<leader>tf` - Fix all fixable issues
- `<leader>tr` - Restart TypeScript server

### Angular (`angularls`)

**Features:**
- Template and component navigation
- Standalone component support
- Strict template checking
- Angular CLI integration

**Key Bindings:**
- `<leader>ac` - Go to component
- `<leader>at` - Go to template  
- `<leader>as` - Go to styles
- `<leader>ae` - Extract component
- `<leader>av` - Show Angular version

### Elixir (`elixirls`)

**Features:**
- Dialyzer integration
- Mix task execution
- Pipe operator transformations
- IEx integration

**Key Bindings:**
- `<leader>et` - Run tests
- `<leader>ep` - Convert to pipe
- `<leader>em` - Expand macro
- `<leader>ei` - Open IEx
- `<leader>ef` - Format with Mix

### Go (`gopls`)

**Features:**
- Advanced static analysis
- Test generation and execution
- Vulnerability checking
- Module management

**Key Bindings:**
- `<leader>gi` - Organize imports
- `<leader>gt` - Go mod tidy
- `<leader>gr` - Run tests
- `<leader>gf` - Fill struct
- `<leader>gv` - Vulnerability check

### C# (`roslyn`)

**Features:**
- .NET project management
- NuGet package management
- Code generation
- Test execution with coverage

**Key Bindings:**
- `<leader>cb` - Build project
- `<leader>cr` - Run project
- `<leader>ct` - Test project
- `<leader>cp` - Add package
- `<leader>cn` - New class

## Installation

The LSP configuration is automatically loaded when you open supported files. Mason will auto-install language servers as needed.

### Manual Installation

#### Registry Setup

The configuration includes a custom Mason registry for Roslyn LSP. If you need to manually register it:

```bash
# The custom registry is automatically configured in lua/plugins/lsp.lua
# But if you need to verify or troubleshoot:
:Mason
# Check that "github:Crashdummyy/mason-registry" appears in registries
```

#### Language Server Installation

**Important**: Before installing via Mason, verify package availability:

```bash
# Open Mason UI to verify available packages
:Mason

# Install language servers manually (verify IDs first)
:MasonInstall ts_ls angularls elixirls gopls roslyn
```

**Note for Go and Elixir**: These languages are managed via [Mise](../../../mise/.config/mise/) in this repository:

```bash
# Use mise instead of Mason for Go and Elixir runtimes
mise install go@latest     # Installs Go with gopls
mise install elixir@latest # Installs Elixir with ElixirLS

# See setup/system/setup-mise.sh for automated setup
./setup/system/setup-mise.sh
```

#### Prerequisites by Language

**C# (Roslyn)**:
- **.NET SDK**: Required for compilation and project management
  ```bash
  # Arch Linux
  sudo pacman -S dotnet-sdk
  
  # Verify installation
  dotnet --version
  ```
- **Debug Support**: See [Debug Adapters](#debug-adapters) section below
- **Configuration**: See [roslyn.lua](servers/roslyn.lua) for detailed settings

### Debug Adapters

Some debugging features require additional tools:

**Go Debugging**:
```bash
# Via Mise (recommended - see setup/system/setup-mise.sh)
mise install go@latest  # Includes delve debugger

# Verify delve installation
dlv version
```

**C# Debugging**:
```bash
# Install .NET Core debugger (required for Roslyn)
# Arch Linux
sudo pacman -S netcoredbg

# Other distributions
# Ubuntu/Debian: sudo apt install netcoredbg
# Fedora: sudo dnf install netcoredbg

# Verify installation
netcoredbg --version
```
**Note**: C# debugging also requires .NET SDK (see [Prerequisites](#prerequisites-by-language))

**JavaScript/TypeScript Debugging**:
```bash
# Install VS Code JS debugger
npm install -g @vscode/js-debug

# Alternative: Install via Mise if you manage Node.js that way
mise install node@lts
npm install -g @vscode/js-debug
```

**Elixir Debugging**:
```bash
# Requires Elixir installation via Mise
mise install elixir@latest

# Debug adapter is typically included with ElixirLS
# If needed separately:
mix escript.install github elixir-lsp/elixir_debug_adapter
```

## Configuration

### Adding New Languages

1. Create a new server configuration file in `lua/lsp/servers/`:

```lua
-- lua/lsp/servers/my_language.lua
local defaults = require("lsp.utils.defaults")

local config = {
  settings = {
    -- Language server specific settings
  },
  on_attach = function(client, bufnr)
    defaults.on_attach(client, bufnr)
    -- Add custom keymaps here
  end,
}

return defaults.get_enhanced_config(config)
```

2. Add the server to Mason's `ensure_installed` list in `lua/plugins/lsp.lua`

3. Add Treesitter parser to `lua/plugins/nvim-treesitter.lua`

### Customizing Key Bindings

Key bindings are configured in `lua/lsp/utils/keymaps.lua`. The configuration uses Neovim's modern `LspAttach` autocmd for dynamic binding.

### Diagnostics Configuration

Diagnostic appearance and behavior is configured in `lua/lsp/utils/autocmds.lua`.

## Key Bindings Reference

### Universal LSP Bindings

| Key | Action | Description |
|-----|--------|-------------|
| `gd` | Go to definition | Jump to symbol definition |
| `gr` | Go to references | Find all references |
| `gI` | Go to implementation | Jump to implementation |
| `gy` | Go to type definition | Jump to type definition |
| `K` | Hover documentation | Show documentation |
| `<leader>ca` | Code action | Show available code actions |
| `<leader>rn` | Rename | Rename symbol |
| `<leader>f` | Format | Format document |
| `[d` / `]d` | Navigate diagnostics | Previous/next diagnostic |

### Diagnostic Management

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>d` | Show diagnostic | Open diagnostic float |
| `<leader>dl` | Diagnostic list | Open location list |
| `<leader>dw` | Workspace diagnostics | Open quickfix list |
| `<leader>dd` | Toggle diagnostics | Enable/disable diagnostics |

### Debugging (DAP)

| Key | Action | Description |
|-----|--------|-------------|
| `<F5>` | Start/Continue | Begin or continue debugging |
| `<F1>` | Step into | Step into function |
| `<F2>` | Step over | Step over line |
| `<F3>` | Step out | Step out of function |
| `<leader>b` | Toggle breakpoint | Set/remove breakpoint |
| `<leader>du` | Toggle DAP UI | Show/hide debug interface |

## Troubleshooting

### LSP Server Issues

```bash
# Check LSP status
:LspInfo

# Restart LSP servers  
:LspRestart

# Check Mason installations
:Mason

# View LSP logs
:LspLog
```

### Common Issues

1. **Server not starting**: Check that the language server is installed via Mason
2. **No completions**: Ensure blink.cmp is properly configured and server supports completion
3. **Formatting not working**: Check if server supports formatting or install external formatter
4. **Debugging not working**: Ensure debug adapter is installed and configured

### Performance Issues

The configuration is optimized for performance with:
- Lazy loading of LSP servers
- Debounced text changes
- Efficient diagnostic updates
- Conditional formatting

If you experience issues:
1. Check `:checkhealth lsp` for problems
2. Use `:LspCapabilities` to verify server features
3. Monitor with `:Lazy profile` for plugin loading times

## Advanced Features

### Inlay Hints

Modern language servers support inlay hints (requires Neovim 0.10+):
- `<leader>th` - Toggle inlay hints for current buffer

### Document Highlighting

Automatic highlighting of symbol references:
- `<leader>thl` - Toggle document highlighting

### Workspace Management

- `<leader>wa` - Add workspace folder
- `<leader>wr` - Remove workspace folder  
- `<leader>wl` - List workspace folders

### Custom Commands

Each language server provides custom commands (`:CommandName`):
- `:GoImports` - Organize Go imports
- `:TypescriptReloadProjects` - Restart TypeScript server
- `:ElixirRunTests` - Run Elixir tests
- `:CSharpBuild` - Build C# project

## Integration with Existing Configuration

This LSP setup integrates seamlessly with your existing Neovim configuration:

- **fzf-lua**: Enhanced LSP pickers for references, definitions, symbols
- **which-key**: Automatic key binding hints and discovery
- **Catppuccin**: Consistent theming for LSP UI elements
- **blink.cmp**: Native completion integration

The configuration respects your existing settings while providing enhanced LSP functionality.
