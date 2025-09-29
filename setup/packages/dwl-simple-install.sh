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

# Try dwl (stable) first, then dwl-git as fallback
log_info "Checking available dwl packages..."
echo ""

# Try stable version first
log_info "Attempting to install dwl (stable) from AUR..."
log_info "This will install compatible wlroots version"
echo ""

if $AUR_HELPER -S --needed dwl 2>/dev/null; then
    PACKAGE="dwl"
else
    log_warning "dwl (stable) not available, trying dwl-git..."
    if $AUR_HELPER -S --needed dwl-git; then
        PACKAGE="dwl-git"
    else
        log_error "Both dwl and dwl-git failed to install"
        echo ""
        log_info "Possible solutions:"
        echo "  1. Check AUR package availability: $AUR_HELPER -Ss dwl"
        echo "  2. Try manual installation: $AUR_HELPER -S dwl"
        echo "  3. Install specific wlroots version if needed"
        exit 1
    fi
fi

echo ""
log_success "$PACKAGE installed successfully!"
echo ""
log_info "dwl binary location: $(which dwl)"
echo ""
log_info "Next steps:"
echo "  1. Deploy configuration: cd ~/dotfiles && stow dwl"
echo "  2. Log out and select 'dwl' from your display manager"
echo ""
log_info "To customize dwl configuration, use: dwl-rebuild"
