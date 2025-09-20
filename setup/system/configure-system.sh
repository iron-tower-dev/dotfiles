#!/bin/bash

# System Configuration Script
# This script configures system services and permissions

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

log_info "Configuring system services and permissions..."

# Enable and start essential services
log_info "Enabling system services..."

SERVICES=(
    "NetworkManager"
    "bluetooth"
    "pipewire"
    "pipewire-pulse" 
    "wireplumber"
)

for service in "${SERVICES[@]}"; do
    log_info "Enabling $service..."
    if sudo systemctl enable --now "$service" 2>/dev/null; then
        log_success "$service enabled and started"
    else
        log_warning "Failed to enable $service (may already be enabled)"
    fi
done

# Add user to necessary groups
log_info "Adding user to necessary groups..."

GROUPS=(
    "audio"
    "video"
    "input"
    "storage"
    "wheel"
)

for group in "${GROUPS[@]}"; do
    if sudo usermod -aG "$group" "$USER" 2>/dev/null; then
        log_success "Added $USER to $group group"
    else
        log_warning "Failed to add $USER to $group group (may already be member)"
    fi
done

# Set up sudo permissions for brightness and power management
log_info "Setting up sudo permissions..."

SUDOERS_CONTENT="# Allow users in wheel group to control brightness and power
%wheel ALL=(ALL) NOPASSWD: /usr/bin/brightnessctl
%wheel ALL=(ALL) NOPASSWD: /usr/bin/systemctl suspend
%wheel ALL=(ALL) NOPASSWD: /usr/bin/systemctl hibernate
%wheel ALL=(ALL) NOPASSWD: /usr/bin/systemctl poweroff
%wheel ALL=(ALL) NOPASSWD: /usr/bin/systemctl reboot"

echo "$SUDOERS_CONTENT" | sudo tee /etc/sudoers.d/10-hyprland-system >/dev/null
sudo chmod 440 /etc/sudoers.d/10-hyprland-system

log_success "Sudo permissions configured"

# Configure login manager (if using SDDM or GDM)
if command -v sddm &> /dev/null; then
    log_info "Configuring SDDM..."
    sudo systemctl enable sddm
    log_success "SDDM enabled"
elif command -v gdm &> /dev/null; then
    log_info "Configuring GDM..."
    sudo systemctl enable gdm
    log_success "GDM enabled"
else
    log_warning "No display manager found. You may need to configure one manually."
fi

# Set up polkit authentication agent autostart
log_info "Setting up polkit authentication agent..."
mkdir -p ~/.config/autostart

POLKIT_DESKTOP="[Desktop Entry]
Name=Polkit GNOME Authentication Agent
Comment=PolicyKit Authentication Agent
Exec=/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
Terminal=false
Type=Application
Categories=
NoDisplay=true
OnlyShowIn=GNOME;Unity;MATE;XFCE;Hyprland;
X-GNOME-AutoRestart=true"

echo "$POLKIT_DESKTOP" > ~/.config/autostart/polkit-gnome-authentication-agent-1.desktop

log_success "Polkit authentication agent configured"

# Configure desktop portal
log_info "Configuring desktop portal..."
mkdir -p ~/.config/xdg-desktop-portal

PORTAL_CONFIG="[preferred]
default=hyprland;gtk
org.freedesktop.impl.portal.ScreenCast=hyprland
org.freedesktop.impl.portal.Screenshot=hyprland
org.freedesktop.impl.portal.FileChooser=gtk"

echo "$PORTAL_CONFIG" > ~/.config/xdg-desktop-portal/portals.conf

log_success "Desktop portal configured"

# Set up environment for Wayland
log_info "Setting up Wayland environment..."

ENV_VARS="# Wayland/Hyprland environment variables
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=Hyprland
export GDK_BACKEND=wayland,x11
export QT_QPA_PLATFORM=wayland;xcb
export SDL_VIDEODRIVER=wayland
export CLUTTER_BACKEND=wayland
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1"

# Add to shell profile if not already present
if ! grep -q "XDG_CURRENT_DESKTOP=Hyprland" ~/.profile 2>/dev/null; then
    echo "" >> ~/.profile
    echo "$ENV_VARS" >> ~/.profile
    log_success "Environment variables added to ~/.profile"
else
    log_info "Environment variables already configured in ~/.profile"
fi

log_success "System configuration completed!"
log_warning "You may need to reboot for all changes to take effect."
