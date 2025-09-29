#!/usr/bin/env bash
# dwl-simple-install.sh - Install dwl-git from AUR (easiest method)
# This lets the AUR package handle all dependencies including wlroots

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
echo "║           dwl Simple Installation (AUR Package)               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Check for AUR helper
if command -v yay &> /dev/null; then
    AUR_HELPER="yay"
elif command -v paru &> /dev/null; then
    AUR_HELPER="paru"
else
    log_error "No AUR helper found. Please install yay or paru first."
    echo ""
    echo "Install yay:"
    echo "  git clone https://aur.archlinux.org/yay.git"
    echo "  cd yay"
    echo "  makepkg -si"
    exit 1
fi

log_info "Using AUR helper: $AUR_HELPER"
echo ""

# Install dwl-git from AUR
log_info "Installing dwl-git from AUR..."
log_info "This will also install wlroots and all other dependencies"
echo ""

$AUR_HELPER -S --needed dwl-git

if [ $? -eq 0 ]; then
    echo ""
    log_success "dwl installed successfully!"
    echo ""
    log_info "dwl binary location: $(which dwl)"
    echo ""
    log_info "Next steps:"
    echo "  1. Deploy configuration: cd ~/dotfiles && stow dwl"
    echo "  2. Log out and select 'dwl' from your display manager"
    echo ""
    log_info "To customize dwl configuration, use: dwl-rebuild"
else
    echo ""
    log_error "Installation failed"
    log_info "Try manual installation: $AUR_HELPER -S dwl-git"
    exit 1
fi