#!/usr/bin/env bash

# ================================================================================================
# TITLE : Mise Setup Script  
# ABOUT : Install and configure Mise with all language tools and LSP servers
# AUTHOR: Enhanced setup for Neovim LSP development environment
# ================================================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

log_info "Setting up mise (programming language version manager)..."

# Check if mise is installed
if ! command -v mise &> /dev/null; then
    log_error "Mise is not installed. Please run the packages installation script first."
    exit 1
fi

# Initialize mise for the current session
export PATH="$HOME/.local/share/mise/shims:$PATH"

log_info "Configuring mise..."

# Create mise config directory if it doesn't exist
mkdir -p ~/.config/mise

# Activate mise for current session
eval "$(mise activate bash)"

# Install required plugins first
log_info "Installing mise plugins..."
plugins=("node" "python" "go" "rust" "java" "elixir" "erlang" "clojure" "dotnet" "kotlin" "bun" "deno" "zig" "terraform" "kubectl" "helm" "uv")
for plugin in "${plugins[@]}"; do
    if ! mise plugins list | grep -q "^$plugin$"; then
        log_info "Installing plugin: $plugin"
        mise plugins install "$plugin" || log_warning "Failed to install plugin: $plugin"
    fi
done

# Install all tools from config.toml
log_info "Installing programming languages and tools from configuration..."
mise install || {
    log_warning "Batch install failed. Installing individual tools..."
    
    # Core languages for LSP servers
    core_tools=(
        "node@lts"          # TypeScript/Angular/JavaScript LSP (ts_ls, angularls)
        "python@3.12"       # Python development and tooling
        "go@latest"         # Go LSP (gopls)
        "rust@stable"       # Rust development and tooling
        "java@21"           # Required for Kotlin LSP
        "elixir@1.16"       # Elixir LSP (elixirls)
        "erlang@26"         # Required by Elixir
        "clojure@latest"    # Clojure LSP (clojure_lsp)
        "dotnet@8.0"        # C# LSP (roslyn)
        "kotlin@2.0"        # Kotlin LSP (kotlin_language_server)
    )
    
    # Additional development tools
    additional_tools=(
        "bun@latest"        # Alternative Node.js runtime
        "deno@latest"       # Alternative TypeScript runtime
        "zig@latest"        # Systems programming
        "terraform@latest"  # Infrastructure as code
        "kubectl@latest"    # Kubernetes CLI
        "helm@latest"       # Kubernetes package manager
        "uv@latest"         # Fast Python package manager
    )
    
    # Install core tools
    for tool in "${core_tools[@]}"; do
        log_info "Installing core tool: $tool"
        if ! mise list | grep -q "${tool%%@*}"; then
            mise install "$tool" || log_warning "Failed to install: $tool"
        else
            log_info "$tool already installed"
        fi
    done
    
    # Install additional tools
    for tool in "${additional_tools[@]}"; do
        log_info "Installing additional tool: $tool"
        mise install "$tool" || log_warning "Failed to install: $tool"
    done
}

# Optional tools - ask user
echo
log_info "Optional programming languages available:"
echo "1. Java 21"
echo "2. Ruby 3.3"  
echo "3. Bun latest"
echo "4. Deno latest"
echo "5. PHP 8.3"
echo "6. Elixir 1.16 (with Erlang 26)"
echo

read -p "Install optional languages? (y/N): " install_optional
if [[ $install_optional =~ ^[Yy]$ ]]; then
    echo "Enter numbers separated by spaces (e.g., '1 3 6' for Java, Bun, and Elixir):"
    read -p "Selection: " selections
    
    for selection in $selections; do
        case $selection in
            1)
                log_info "Installing Java 21..."
                mise install java@21 && mise use -g java@21
                ;;
            2)
                log_info "Installing Ruby 3.3..."
                mise install ruby@3.3 && mise use -g ruby@3.3
                ;;
            3)
                log_info "Installing Bun latest..."
                mise install bun@latest && mise use -g bun@latest
                ;;
            4)
                log_info "Installing Deno latest..."
                mise install deno@latest && mise use -g deno@latest
                ;;
            5)
                log_info "Installing PHP 8.3..."
                mise install php@8.3 && mise use -g php@8.3
                ;;
            6)
                log_info "Installing Erlang 26 and Elixir 1.16..."
                mise install erlang@26 && mise use -g erlang@26
                mise install elixir@1.16 && mise use -g elixir@1.16
                ;;
            *)
                log_warning "Unknown selection: $selection"
                ;;
        esac
    done
else
    log_info "Skipping optional languages"
fi

# Install Node.js language servers and tools
if command -v node &> /dev/null; then
    log_info "Installing Node.js language servers and tools..."
    npm install -g \
        typescript \
        typescript-language-server \
        @angular/cli \
        @angular/language-server \
        vscode-langservers-extracted \
        prettier \
        eslint \
        @typescript-eslint/parser \
        @typescript-eslint/eslint-plugin \
        yarn \
        pnpm 2>/dev/null || log_warning "Some npm packages may have failed to install"
    log_success "Node.js language servers and tools installed"
fi

# Install useful Python packages using uv
if command -v uv &> /dev/null; then
    log_info "Installing Python language servers and tools using uv..."
    
    # Install development tools globally with uv tool
    python_tools=(
        "python-lsp-server"     # Python LSP server
        "ruff"                  # Fast Python linter and formatter  
        "mypy"                  # Static type checker
        "black"                 # Code formatter (fallback)
        "isort"                 # Import sorter
        "pytest"                # Testing framework
        "jupyterlab"            # Jupyter Lab
        "pylsp-mypy"            # MyPy plugin for python-lsp-server
        "python-lsp-ruff"       # Ruff plugin for python-lsp-server
    )
    
    for tool in "${python_tools[@]}"; do
        log_info "Installing Python tool: $tool"
        uv tool install "$tool" 2>/dev/null || log_warning "Failed to install: $tool"
    done
    
    log_success "Python tools installed with uv"
else
    log_warning "uv not found. Install uv first: 'mise install uv@latest'"
fi

# Install Go language servers and tools
if command -v go &> /dev/null; then
    log_info "Installing Go language servers and tools..."
    go install golang.org/x/tools/gopls@latest
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
    go install honnef.co/go/tools/cmd/staticcheck@latest
    go install github.com/go-delve/delve/cmd/dlv@latest
    log_success "Go language servers installed"
fi

# Install Rust language servers and tools
if command -v rustup &> /dev/null; then
    log_info "Installing Rust language servers and components..."
    rustup component add rust-analyzer rustfmt clippy
    
    # Install useful Rust CLI tools
    if command -v cargo &> /dev/null; then
        log_info "Installing useful Rust CLI tools..."
        cargo install \
            ripgrep \
            fd-find \
            bat \
            eza \
            tokei \
            cargo-watch \
            cargo-edit 2>/dev/null || log_warning "Some Rust tools may have failed to install"
    fi
    
    log_success "Rust language servers and tools installed"
fi

# Show installed tools
echo
log_info "Installed programming languages and tools:"
mise ls

# Show mise status
echo
log_info "Mise environment status:"
mise doctor || true

log_success "Mise setup completed!"
echo
log_info "Useful mise commands:"
echo "  mise ls                 - List installed tools"
echo "  mise install <tool>     - Install a tool"
echo "  mise use <tool>@<ver>   - Use version in current directory"
echo "  mise use -g <tool>@<ver> - Set global version"
echo "  mise upgrade            - Update all tools"
echo "  mise doctor             - Check mise configuration"
echo
log_warning "Restart your shell or source your shell config to use the newly installed tools."
