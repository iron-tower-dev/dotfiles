#!/bin/bash

# AUR Packages Installation Script
# This script installs paru (if not present) and AUR packages

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

# Check if running on Arch Linux
if ! command -v pacman &> /dev/null; then
    log_error "This script is designed for Arch Linux systems with pacman."
    exit 1
fi

# Function to install paru if not present
install_paru() {
    if command -v paru &> /dev/null; then
        log_info "paru is already installed"
        return 0
    fi
    
    if command -v yay &> /dev/null; then
        log_info "yay is available, using it instead of paru"
        return 0
    fi
    
    log_info "Installing paru AUR helper..."
    
    # Create temp directory
    temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Clone and build paru
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
    
    # Clean up
    cd "$HOME"
    rm -rf "$temp_dir"
    
    log_success "paru installed successfully"
}

# Function to get AUR helper command
get_aur_helper() {
    if command -v paru &> /dev/null; then
        echo "paru"
    elif command -v yay &> /dev/null; then
        echo "yay"
    else
        log_error "No AUR helper found"
        return 1
    fi
}

# AUR packages needed for the setup
AUR_PACKAGES=(
    # Themes
    "catppuccin-gtk-theme-macchiato"
    "catppuccin-cursors-macchiato" 
    "kvantum-theme-catppuccin-git"
    
    # Additional tools
    "visual-studio-code-bin"       # Optional: VS Code
    "firefox-developer-edition"    # Optional: Firefox Dev Edition
    
    # System tools
    "hyprpicker"                   # Color picker for Hyprland
    "grimblast-git"               # Enhanced screenshot tool
    "swww"                        # Wayland wallpaper daemon
    "waypaper"                    # Wallpaper manager for Wayland
)

# Optional packages (user can choose)
OPTIONAL_PACKAGES=(
    "discord"
    "spotify"
    "zoom"
    "slack-desktop"
    "obsidian"
    "postman-bin"
)

# Install paru
install_paru

# Get AUR helper command
AUR_HELPER=$(get_aur_helper)
log_info "Using AUR helper: $AUR_HELPER"

# Install essential AUR packages
log_info "Installing essential AUR packages..."
if $AUR_HELPER -S --needed --noconfirm "${AUR_PACKAGES[@]}"; then
    log_success "Essential AUR packages installed successfully"
else
    log_warning "Some AUR packages may have failed to install"
fi

# Ask about optional packages
echo
log_info "Optional packages available:"
for i in "${!OPTIONAL_PACKAGES[@]}"; do
    echo "  $((i+1)). ${OPTIONAL_PACKAGES[i]}"
done

echo
read -p "Install optional packages? (y/N): " install_optional
if [[ $install_optional =~ ^[Yy]$ ]]; then
    log_info "Installing optional AUR packages..."
    if $AUR_HELPER -S --needed "${OPTIONAL_PACKAGES[@]}"; then
        log_success "Optional AUR packages installed"
    else
        log_warning "Some optional packages may have failed to install"
    fi
else
    log_info "Skipping optional packages"
fi

log_success "AUR package installation completed!"
