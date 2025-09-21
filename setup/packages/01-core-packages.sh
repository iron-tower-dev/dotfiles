#!/bin/bash

# Core Packages Installation Script
# This script installs essential packages for the Hyprland + Waybar setup

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

log_info "Installing core packages..."

# Core system packages
CORE_PACKAGES=(
    "base-devel"            # Essential build tools
    "git"                   # Version control
    "github-cli"            # GitHub CLI tool
    "git-delta"             # Better git diff viewer
    "curl"                  # HTTP client
    "wget"                  # File downloader
    "unzip"                 # Archive extraction
    "stow"                  # Dotfiles symlink manager
    "neovim"               # Text editor
    "btop"                  # System monitor
    "playerctl"            # Media player control
    "brightnessctl"        # Backlight control
    "grim"                 # Wayland screenshot
    "slurp"                # Screen area selection
    "wl-clipboard"         # Wayland clipboard
    "xdg-desktop-portal-hyprland"  # Desktop portal for Hyprland
    "polkit-gnome"         # Authentication agent
    "dunst"                # Notification daemon
    "libnotify"            # Notification library
    "fish"                  # Modern shell
    "nushell"              # Structured data shell
    "starship"             # Modern prompt
    "exa"                  # Modern ls replacement
    "bat"                  # Modern cat replacement
    "fd"                   # Modern find replacement
    "ripgrep"              # Modern grep replacement
    "fzf"                  # Fuzzy finder
    "zoxide"               # Smart cd replacement
    "fastfetch"            # System info tool
    "direnv"               # Directory-based environment
    "mise"                 # Programming language version manager
)

# Wayland/Hyprland specific packages
WAYLAND_PACKAGES=(
    "hyprland"             # Wayland compositor
    "waybar"               # Status bar
    "rofi-wayland"         # Application launcher
    "alacritty"            # Terminal emulator
    "thunar"               # File manager
    "thunar-volman"        # Volume management for Thunar
    "gvfs"                 # Virtual filesystem
    "tumbler"              # Thumbnail generator
    "hypridle"             # Idle daemon
    "hyprlock"             # Screen locker
)

# Audio packages
AUDIO_PACKAGES=(
    "pipewire"             # Audio server
    "pipewire-alsa"        # ALSA support
    "pipewire-pulse"       # PulseAudio compatibility
    "wireplumber"          # Session manager
    "pavucontrol"          # Volume control GUI
    "bluez"                # Bluetooth support
    "bluez-utils"          # Bluetooth utilities
    "blueman"              # Bluetooth manager
)

# Network packages
NETWORK_PACKAGES=(
    "networkmanager"       # Network management
    "nm-connection-editor" # Network GUI
    "network-manager-applet"  # Network system tray
)

# Font packages
FONT_PACKAGES=(
    "ttf-jetbrains-mono-nerd"  # JetBrains Mono Nerd Font
    "noto-fonts"              # Google Noto fonts
    "noto-fonts-emoji"        # Emoji support
    "ttf-liberation"          # Liberation fonts
    "ttf-dejavu"              # DejaVu fonts
)

# Combine all package arrays
ALL_PACKAGES=(
    "${CORE_PACKAGES[@]}"
    "${WAYLAND_PACKAGES[@]}"
    "${AUDIO_PACKAGES[@]}"
    "${NETWORK_PACKAGES[@]}"
    "${FONT_PACKAGES[@]}"
)

# Function to install packages
install_packages() {
    local packages=("$@")
    log_info "Installing packages: ${packages[*]}"
    
    if sudo pacman -S --needed --noconfirm "${packages[@]}"; then
        log_success "Successfully installed packages"
    else
        log_error "Failed to install some packages"
        return 1
    fi
}

# Update system first
log_info "Updating system packages..."
sudo pacman -Syu --noconfirm

# Install packages in groups for better error handling
log_info "Installing core packages..."
install_packages "${CORE_PACKAGES[@]}"

log_info "Installing Wayland/Hyprland packages..."
install_packages "${WAYLAND_PACKAGES[@]}"

log_info "Installing audio packages..."
install_packages "${AUDIO_PACKAGES[@]}"

log_info "Installing network packages..."
install_packages "${NETWORK_PACKAGES[@]}"

log_info "Installing font packages..."
install_packages "${FONT_PACKAGES[@]}"

# Enable essential services
log_info "Enabling essential services..."
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth

log_success "Core package installation completed!"
log_info "You may need to reboot for all changes to take effect."
