#!/bin/bash

# Themes Setup Script
# This script sets up Qt and GTK theming components

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

log_info "Setting up Qt and GTK theming..."

# Install Qt theming packages
QT_THEME_PACKAGES=(
    "kvantum"              # Qt theme engine
    "qt5ct"                # Qt5 configuration tool
    "qt6ct"                # Qt6 configuration tool
)

log_info "Installing Qt theming packages..."
if sudo pacman -S --needed --noconfirm "${QT_THEME_PACKAGES[@]}"; then
    log_success "Qt theming packages installed"
else
    log_error "Failed to install Qt theming packages"
    exit 1
fi

# Apply gsettings for GTK themes
log_info "Applying GTK theme settings..."

# Set GTK theme
gsettings set org.gnome.desktop.interface gtk-theme "catppuccin-macchiato-mauve-standard+default"
gsettings set org.gnome.desktop.interface cursor-theme "catppuccin-macchiato-mauve-cursors"
gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
gsettings set org.gnome.desktop.interface font-name "JetBrainsMono Nerd Font 11"

log_success "GTK theme settings applied"

# Set environment variables for the current session
log_info "Setting up environment variables..."
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_QPA_PLATFORMTHEME_QT6=qt6ct
export QT_STYLE_OVERRIDE=kvantum
export GTK_THEME=catppuccin-macchiato-mauve-standard+default
export XCURSOR_THEME=catppuccin-macchiato-mauve-cursors

log_success "Environment variables set for current session"

# Update icon cache
log_info "Updating icon cache..."
if command -v gtk-update-icon-cache &> /dev/null; then
    gtk-update-icon-cache -f -t ~/.local/share/icons/ 2>/dev/null || true
    gtk-update-icon-cache -f -t /usr/share/icons/Papirus-Dark/ 2>/dev/null || true
    log_success "Icon cache updated"
fi

# Update font cache
log_info "Updating font cache..."
if command -v fc-cache &> /dev/null; then
    fc-cache -fv
    log_success "Font cache updated"
fi

log_success "Theme setup completed!"
log_info "Note: You may need to restart applications or log out/in for all changes to take effect."
log_info "For Hyprland, restart Hyprland for environment variables to be fully applied."
