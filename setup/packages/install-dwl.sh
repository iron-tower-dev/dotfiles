#!/usr/bin/env bash
# install-dwl.sh - Clean dwl installation for Arch Linux
# Builds dwl and slstatus from source with Catppuccin theming

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                  dwl Installation Script                      ║"
echo "║        Suckless Wayland Compositor + slstatus                 ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Check Arch Linux
if [ ! -f /etc/arch-release ]; then
    log_error "This script is for Arch Linux"
    exit 1
fi

log_success "Arch Linux detected"
echo ""

# Install dependencies
log_info "Installing dependencies..."
sudo pacman -S --needed --noconfirm \
    wayland \
    wayland-protocols \
    wlroots0.19 \
    foot \
    base-devel \
    git \
    wmenu \
    wl-clipboard \
    grim \
    slurp \
    swaybg \
    firefox \
    ttf-jetbrains-mono-nerd

if [ $? -eq 0 ]; then
    log_success "Dependencies installed"
else
    log_error "Failed to install dependencies"
    exit 1
fi

echo ""

# Build dwl
log_info "Building dwl..."
DWL_SRC="/tmp/dwl-install-$$"
rm -rf "$DWL_SRC"

git clone https://codeberg.org/dwl/dwl.git "$DWL_SRC"
cd "$DWL_SRC"

# Copy custom config if it exists
if [ -f "$HOME/dotfiles/dwl/.config/dwl/config.h" ]; then
    log_info "Using custom config.h"
    cp "$HOME/dotfiles/dwl/.config/dwl/config.h" config.h
else
    log_info "Using default config (will be customized)"
fi

# Build and install
make clean
make
sudo make install

log_success "dwl installed to /usr/local/bin/dwl"
cd -
rm -rf "$DWL_SRC"

echo ""

# Build slstatus
log_info "Building slstatus..."
SLSTATUS_SRC="/tmp/slstatus-install-$$"
rm -rf "$SLSTATUS_SRC"

git clone https://git.suckless.org/slstatus "$SLSTATUS_SRC"
cd "$SLSTATUS_SRC"

# Copy custom config if it exists
if [ -f "$HOME/dotfiles/dwl/.config/slstatus/config.h" ]; then
    log_info "Using custom slstatus config"
    cp "$HOME/dotfiles/dwl/.config/slstatus/config.h" config.h
else
    log_info "Using default slstatus config (will be customized)"
fi

# Build and install
make clean
make
sudo make install

log_success "slstatus installed to /usr/local/bin/slstatus"
cd -
rm -rf "$SLSTATUS_SRC"

echo ""

# Create session file
log_info "Creating dwl session file..."
sudo tee /usr/share/wayland-sessions/dwl.desktop > /dev/null << 'EOF'
[Desktop Entry]
Name=dwl
Comment=dwl - dwm for Wayland
Exec=dwl
Type=Application
EOF

log_success "Session file created"

echo ""
log_success "Installation complete!"
echo ""
log_info "Next steps:"
echo "  1. Deploy configuration: cd ~/dotfiles && stow dwl"
echo "  2. Log out and select 'dwl' from your display manager"
echo ""