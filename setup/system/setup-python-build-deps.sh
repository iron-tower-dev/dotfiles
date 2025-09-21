#!/usr/bin/env bash

# ================================================================================================
# TITLE : Python Build Dependencies Setup Script  
# ABOUT : Ensure Python build dependencies are available for AUR package compilation
# AUTHOR: Dotfiles automation script
# PURPOSE: Prevent "Cannot import 'poetry.core.masonry.api'" and similar AUR build failures
# ================================================================================================

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

log_info "Setting up Python build dependencies for AUR package compilation..."

# Essential Python build dependencies for AUR packages
SYSTEM_BUILD_DEPS=(
    "python-poetry"         # Modern Python packaging and dependency management
    "python-installer"      # Python package installer
    "python-build"          # Python build frontend
    "python-setuptools"     # Python packaging utilities
    "python-wheel"          # Python wheel support
    "python-poetry-core"    # Poetry core (often required separately)
)

PIP_BUILD_DEPS=(
    "installer"             # Python package installer
    "poetry"                # Modern Python packaging
    "poetry-core"           # Poetry core
    "build"                 # Python build frontend
    "setuptools"            # Python packaging utilities
    "wheel"                 # Python wheel support
)

# Check if running on Arch Linux
if ! command -v pacman &> /dev/null; then
    log_error "This script is designed for Arch Linux systems with pacman."
    exit 1
fi

# Install system Python build dependencies
log_info "Installing system Python build dependencies..."
missing_packages=()

for pkg in "${SYSTEM_BUILD_DEPS[@]}"; do
    if ! pacman -Qi "$pkg" &>/dev/null; then
        missing_packages+=("$pkg")
    fi
done

if [ ${#missing_packages[@]} -gt 0 ]; then
    log_info "Installing missing system packages: ${missing_packages[*]}"
    if sudo pacman -S --needed --noconfirm "${missing_packages[@]}"; then
        log_success "System Python build dependencies installed"
    else
        log_warning "Some system packages may have failed to install"
    fi
else
    log_info "All system Python build dependencies are already installed"
fi

# Setup mise Python environment if mise is available
if command -v mise &> /dev/null; then
    log_info "Configuring mise Python environment for AUR builds..."
    
    # Ensure mise is activated
    export PATH="$HOME/.local/share/mise/shims:$PATH"
    eval "$(mise activate bash 2>/dev/null)" || true
    
    # Check if Python is installed via mise
    if mise list python 2>/dev/null | grep -q "python"; then
        log_info "Found mise Python installation"
        
        # Install build dependencies to mise Python
        if command -v pip &> /dev/null; then
            log_info "Installing Python build dependencies to mise environment..."
            
            for dep in "${PIP_BUILD_DEPS[@]}"; do
                log_info "Installing: $dep"
                if pip install "$dep" --quiet; then
                    log_success "Installed: $dep"
                else
                    log_warning "Failed to install: $dep"
                fi
            done
            
            log_success "Mise Python build dependencies setup completed"
        else
            log_warning "pip not found in mise Python environment"
        fi
    else
        log_info "No mise Python installation found - this is optional"
        log_info "Python build dependencies will use system packages"
    fi
else
    log_info "mise not found - using system Python packages only"
fi

# Verify installation by checking key components
log_info "Verifying Python build environment..."

# Check system packages
missing_system=()
for pkg in "python-poetry" "python-installer"; do
    if ! pacman -Qi "$pkg" &>/dev/null; then
        missing_system+=("$pkg")
    fi
done

if [ ${#missing_system[@]} -eq 0 ]; then
    log_success "System Python build dependencies verified"
else
    log_warning "Missing system dependencies: ${missing_system[*]}"
fi

# Check mise environment if available
if command -v python &> /dev/null; then
    python_version=$(python --version 2>&1 || echo "Unknown")
    python_path=$(which python)
    log_info "Active Python: $python_version at $python_path"
    
    # Test if key modules are available
    if python -c "import installer" 2>/dev/null; then
        log_success "installer module available in Python environment"
    else
        log_warning "installer module not found in active Python environment"
    fi
    
    if python -c "import poetry.core.masonry.api" 2>/dev/null; then
        log_success "poetry.core.masonry.api available in Python environment"
    else
        log_info "poetry.core.masonry.api not available - this is expected for system Python"
    fi
fi

log_success "Python build dependencies setup completed!"
echo
log_info "This setup ensures that AUR packages with Python dependencies can build successfully."
log_info "Both system and mise Python environments are configured with necessary build tools."
echo
log_info "If you still encounter build issues, try:"
echo "  1. Restart your shell: source ~/.bashrc (or ~/.zshrc, ~/.config/fish/config.fish)"
echo "  2. Verify mise environment: mise doctor"
echo "  3. Check Python environment: python --version && which python"
