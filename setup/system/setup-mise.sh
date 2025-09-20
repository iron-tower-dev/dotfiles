#!/bin/bash

# Mise Setup Script
# This script configures mise and installs default programming languages

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

# Install default tools based on config
log_info "Installing default programming languages and tools..."

# Check and install Node.js LTS
if ! mise ls node | grep -q "lts"; then
    log_info "Installing Node.js LTS..."
    mise install node@lts
    mise use -g node@lts
    log_success "Node.js LTS installed"
else
    log_info "Node.js LTS already installed"
fi

# Check and install Python 3.12
if ! mise ls python | grep -q "3.12"; then
    log_info "Installing Python 3.12..."
    mise install python@3.12
    mise use -g python@3.12
    log_success "Python 3.12 installed"
else
    log_info "Python 3.12 already installed"
fi

# Check and install Go latest
if ! mise ls go | grep -q "latest"; then
    log_info "Installing Go latest..."
    mise install go@latest
    mise use -g go@latest
    log_success "Go latest installed"
else
    log_info "Go latest already installed"
fi

# Check and install Rust stable
if ! mise ls rust | grep -q "stable"; then
    log_info "Installing Rust stable..."
    mise install rust@stable
    mise use -g rust@stable
    log_success "Rust stable installed"
else
    log_info "Rust stable already installed"
fi

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

# Install some useful Node.js global packages
if command -v node &> /dev/null; then
    log_info "Installing useful Node.js global packages..."
    npm install -g \
        yarn \
        pnpm \
        typescript \
        @angular/cli \
        @vue/cli \
        create-react-app \
        prettier \
        eslint 2>/dev/null || log_warning "Some npm packages may have failed to install"
    log_success "Node.js global packages installed"
fi

# Install useful Python packages
if command -v python &> /dev/null; then
    log_info "Installing useful Python packages..."
    python -m pip install --user \
        pip \
        setuptools \
        wheel \
        pipenv \
        poetry \
        black \
        flake8 \
        pytest \
        jupyter 2>/dev/null || log_warning "Some Python packages may have failed to install"
    log_success "Python packages installed"
fi

# Install useful Rust tools
if command -v cargo &> /dev/null; then
    log_info "Installing useful Rust tools..."
    cargo install \
        ripgrep \
        fd-find \
        bat \
        exa \
        tokei \
        cargo-watch \
        cargo-edit 2>/dev/null || log_warning "Some Rust tools may have failed to install"
    log_success "Rust tools installed"
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
