#!/bin/bash

# Zsh Shell Setup Script
# This script configures Zsh as an available shell and sets up integrations

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

log_info "Setting up Zsh shell..."

# Check if Zsh is installed
if ! command -v zsh &> /dev/null; then
    log_error "Zsh shell is not installed. Please run the packages installation script first."
    exit 1
fi

# Get Zsh shell path
ZSH_PATH=$(which zsh)
log_info "Zsh shell found at: $ZSH_PATH"

# Add Zsh to /etc/shells if not already there
if ! grep -q "$ZSH_PATH" /etc/shells; then
    log_info "Adding Zsh to /etc/shells..."
    echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
    log_success "Zsh added to /etc/shells"
else
    log_info "Zsh already present in /etc/shells"
fi

# Note: We don't change the default shell automatically for Zsh
# since Fish is the preferred default shell in this setup
current_shell=$(getent passwd "$USER" | cut -d: -f7)
log_info "Current default shell: $current_shell"
log_info "Zsh is now available as an alternative shell"

# Initialize Zsh configuration directory
log_info "Initializing Zsh configuration..."
mkdir -p ~/.config/zsh

# Install Oh My Zsh if not already installed
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    log_info "Installing Oh My Zsh..."
    # Install Oh My Zsh non-interactively
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || {
        log_warning "Failed to install Oh My Zsh automatically. Continuing without it..."
    }
    
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log_success "Oh My Zsh installed"
    fi
else
    log_info "Oh My Zsh already installed"
fi

# Install useful Zsh plugins
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    log_info "Installing additional Zsh plugins..."
    
    # Install zsh-autosuggestions
    if [[ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]]; then
        log_info "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions.git \
            "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
        log_success "zsh-autosuggestions installed"
    fi
    
    # Install zsh-syntax-highlighting
    if [[ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]]; then
        log_info "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
            "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
        log_success "zsh-syntax-highlighting installed"
    fi
    
    # Install fast-syntax-highlighting (alternative to zsh-syntax-highlighting)
    if [[ ! -d "$HOME/.oh-my-zsh/custom/plugins/fast-syntax-highlighting" ]]; then
        log_info "Installing fast-syntax-highlighting..."
        git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git \
            "$HOME/.oh-my-zsh/custom/plugins/fast-syntax-highlighting"
        log_success "fast-syntax-highlighting installed"
    fi
    
    # Install zsh-completions
    if [[ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-completions" ]]; then
        log_info "Installing zsh-completions..."
        git clone https://github.com/zsh-users/zsh-completions.git \
            "$HOME/.oh-my-zsh/custom/plugins/zsh-completions"
        log_success "zsh-completions installed"
    fi
    
    log_success "Zsh plugins installed"
else
    log_warning "Oh My Zsh not available, skipping plugin installation"
fi

# Enable Oh My Posh prompt
if command -v oh-my-posh &> /dev/null; then
    log_info "Oh My Posh is available and will be initialized in Zsh config"
else
    log_warning "Oh My Posh not found. Install it for a better prompt experience."
fi

# Enable zoxide if available
if command -v zoxide &> /dev/null; then
    log_info "Zoxide is available and will be initialized in Zsh config"
else
    log_warning "Zoxide not found. Install it for smart directory navigation."
fi

# Enable mise if available
if command -v mise &> /dev/null; then
    log_info "Mise is available and will be initialized in Zsh config"
else
    log_warning "Mise not found. Install it for programming language version management."
fi

log_success "Zsh shell setup completed!"
echo
log_info "Zsh features enabled:"
echo "  - Z shell with modern features"
echo "  - Oh My Zsh framework (if installed successfully)"
echo "  - Syntax highlighting and autosuggestions"
echo "  - Enhanced completions"
echo "  - Oh My Posh prompt (if available)"
echo "  - Mise integration for development tools"
echo "  - Transient prompt support"
echo
log_info "To use Zsh:"
echo "  - Run 'zsh' to start a Zsh session"
echo "  - Use 'chsh -s $(which zsh)' to set as your default shell"
echo "  - Your .zshrc configuration will be managed by dotfiles"
echo
log_warning "Note: Fish remains the recommended default shell in this setup"
log_warning "Zsh is available as an alternative for users who prefer it"
