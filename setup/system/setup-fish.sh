#!/bin/bash

# Fish Shell Setup Script
# This script configures Fish as the default shell and sets up integrations

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

log_info "Setting up Fish shell..."

# Check if Fish is installed
if ! command -v fish &> /dev/null; then
    log_error "Fish shell is not installed. Please run the packages installation script first."
    exit 1
fi

# Get Fish shell path
FISH_PATH=$(which fish)
log_info "Fish shell found at: $FISH_PATH"

# Add Fish to /etc/shells if not already there
if ! grep -q "$FISH_PATH" /etc/shells; then
    log_info "Adding Fish to /etc/shells..."
    echo "$FISH_PATH" | sudo tee -a /etc/shells >/dev/null
    log_success "Fish added to /etc/shells"
else
    log_info "Fish already present in /etc/shells"
fi

# Change default shell to Fish
current_shell=$(getent passwd "$USER" | cut -d: -f7)
if [[ "$current_shell" != "$FISH_PATH" ]]; then
    log_info "Changing default shell to Fish..."
    if chsh -s "$FISH_PATH"; then
        log_success "Default shell changed to Fish"
        log_warning "You'll need to log out and log back in for the shell change to take effect"
    else
        log_error "Failed to change default shell"
        exit 1
    fi
else
    log_info "Fish is already the default shell"
fi

# Initialize Fish configuration directory
log_info "Initializing Fish configuration..."
mkdir -p ~/.config/fish/{functions,completions,conf.d}

# Install Fisher (Fish plugin manager) if not already installed
if ! fish -c "functions -q fisher" 2>/dev/null; then
    log_info "Installing Fisher (Fish plugin manager)..."
    fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
    log_success "Fisher installed"
else
    log_info "Fisher already installed"
fi

# Install useful Fish plugins
log_info "Installing Fish plugins..."

FISH_PLUGINS=(
    "jorgebucaran/autopair.fish"        # Auto-close parentheses, brackets, etc.
    "PatrickF1/fzf.fish"               # FZF integration
    "franciscolourenco/done"           # Notifications when commands finish
    "gazorby/fish-abbreviation-tips"   # Show full command from abbreviations
)

for plugin in "${FISH_PLUGINS[@]}"; do
    log_info "Installing $plugin..."
    fish -c "fisher install $plugin" 2>/dev/null || log_warning "Failed to install $plugin"
done

# Set up Fish abbreviations (like aliases but better)
log_info "Setting up Fish abbreviations..."
fish -c "
    # Git abbreviations
    abbr -a g git
    abbr -a ga 'git add'
    abbr -a gaa 'git add .'
    abbr -a gc 'git commit'
    abbr -a gcm 'git commit -m'
    abbr -a gp 'git push'
    abbr -a gpl 'git pull'
    abbr -a gs 'git status'
    abbr -a gd 'git diff'
    abbr -a gl 'git log --oneline --graph --decorate'
    
    # System abbreviations
    abbr -a ll 'ls -la'
    abbr -a la 'ls -A'
    abbr -a l 'ls -CF'
    abbr -a c clear
    abbr -a h history
    abbr -a q exit
    
    # Package management abbreviations
    abbr -a pacs 'sudo pacman -S'
    abbr -a pacu 'sudo pacman -Syu'
    abbr -a pacr 'sudo pacman -R'
    abbr -a pacss 'pacman -Ss'
    
    # Modern command replacements
    abbr -a cat bat
    abbr -a ls exa
    abbr -a find fd
    abbr -a grep rg
    abbr -a top btop
    abbr -a htop btop
"

log_success "Fish abbreviations configured"

# Enable Oh My Posh prompt
if command -v oh-my-posh &> /dev/null; then
    log_info "Oh My Posh is available and will be initialized in Fish config"
else
    log_warning "Oh My Posh not found. Install it for a better prompt experience."
fi

# Enable zoxide if available
if command -v zoxide &> /dev/null; then
    log_info "Zoxide is available and will be initialized in Fish config"
else
    log_warning "Zoxide not found. Install it for smart directory navigation."
fi

# Set Fish as terminal default for terminal emulators
log_info "Fish shell setup completed!"
echo
log_info "Fish features enabled:"
echo "  - Modern shell with better defaults"
echo "  - Syntax highlighting and autocompletion"
echo "  - Catppuccin Macchiato theming"
echo "  - Useful abbreviations and functions"
echo "  - Fisher plugin manager"
echo "  - FZF integration"
echo "  - Oh My Posh prompt (if available)"
echo
log_warning "To start using Fish immediately, run: fish"
log_warning "Or log out and log back in to use Fish as your default shell"
