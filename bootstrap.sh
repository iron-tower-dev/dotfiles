#!/bin/bash

# Dotfiles Bootstrap Script
# This script sets up a complete Hyprland environment with Catppuccin theming

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_header() { echo -e "${PURPLE}[SETUP]${NC} $1"; }

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_DIR="$SCRIPT_DIR/setup"

# Banner
display_banner() {
    cat << "EOF"
    ╔═══════════════════════════════════════════════════════════════╗
    ║                     DOTFILES BOOTSTRAP                       ║
    ║                                                               ║
    ║            Hyprland + Waybar + Catppuccin Setup              ║
    ║                                                               ║
    ╚═══════════════════════════════════════════════════════════════╝
EOF
}

# Check if running on Arch Linux
check_system() {
    log_info "Checking system compatibility..."
    
    if ! command -v pacman &> /dev/null; then
        log_error "This script is designed for Arch Linux systems with pacman."
        exit 1
    fi
    
    log_success "Arch Linux detected"
}

# Make scripts executable
make_scripts_executable() {
    log_info "Making setup scripts executable..."
    find "$SETUP_DIR" -name "*.sh" -type f -exec chmod +x {} \;
    log_success "Setup scripts are now executable"
}

# Install packages
install_packages() {
    log_header "INSTALLING PACKAGES"
    
    if [[ -f "$SETUP_DIR/packages/01-core-packages.sh" ]]; then
        log_info "Installing core packages..."
        bash "$SETUP_DIR/packages/01-core-packages.sh"
    else
        log_error "Core packages script not found"
        exit 1
    fi
    
    if [[ -f "$SETUP_DIR/packages/02-aur-packages.sh" ]]; then
        log_info "Installing AUR packages..."
        bash "$SETUP_DIR/packages/02-aur-packages.sh"
    else
        log_warning "AUR packages script not found, skipping..."
    fi
}

# Setup themes
setup_themes() {
    log_header "SETTING UP THEMES"
    
    if [[ -f "$SETUP_DIR/themes/setup-themes.sh" ]]; then
        bash "$SETUP_DIR/themes/setup-themes.sh"
    else
        log_warning "Theme setup script not found, skipping..."
    fi
}

# Configure system
configure_system() {
    log_header "CONFIGURING SYSTEM"
    
    if [[ -f "$SETUP_DIR/system/configure-system.sh" ]]; then
        bash "$SETUP_DIR/system/configure-system.sh"
    else
        log_warning "System configuration script not found, skipping..."
    fi
    
    # Setup Fish shell
    if [[ -f "$SETUP_DIR/system/setup-fish.sh" ]]; then
        bash "$SETUP_DIR/system/setup-fish.sh"
    else
        log_warning "Fish setup script not found, skipping..."
    fi
    
    # Setup Zsh shell
    if [[ -f "$SETUP_DIR/system/setup-zsh.sh" ]]; then
        bash "$SETUP_DIR/system/setup-zsh.sh"
    else
        log_warning "Zsh setup script not found, skipping..."
    fi
    
    # Setup Mise
    if [[ -f "$SETUP_DIR/system/setup-mise.sh" ]]; then
        bash "$SETUP_DIR/system/setup-mise.sh"
    else
        log_warning "Mise setup script not found, skipping..."
    fi
    
    # Setup Git
    if [[ -f "$SETUP_DIR/system/setup-git.sh" ]]; then
        bash "$SETUP_DIR/system/setup-git.sh"
    else
        log_warning "Git setup script not found, skipping..."
    fi
    
    # Setup SDDM
    if [[ -f "$SETUP_DIR/system/setup-sddm.sh" ]]; then
        bash "$SETUP_DIR/system/setup-sddm.sh"
    else
        log_warning "SDDM setup script not found, skipping..."
    fi
}

# Deploy dotfiles with stow
deploy_dotfiles() {
    log_header "DEPLOYING DOTFILES"
    
    if ! command -v stow &> /dev/null; then
        log_error "GNU Stow is not installed. Install it first with: sudo pacman -S stow"
        exit 1
    fi
    
    log_info "Deploying configuration files with GNU Stow..."
    
    # Available stow packages
    STOW_PACKAGES=(
        "hyprland"
        "waybar"
        "alacritty"
        "rofi"
        "fish"
        "nushell"
        "mise"
        "zsh"
        "git"
        "neovim"
        "themes"
        "sddm"
    )
    
    cd "$SCRIPT_DIR"
    
    for package in "${STOW_PACKAGES[@]}"; do
        if [[ -d "$package" ]]; then
            log_info "Deploying $package configuration..."
            if stow -t "$HOME" "$package"; then
                log_success "$package configuration deployed"
            else
                log_warning "Failed to deploy $package configuration (may already exist)"
            fi
        else
            log_warning "$package directory not found, skipping..."
        fi
    done
    
    log_success "Dotfiles deployment completed"
}

# Create backup of existing configs
backup_existing_configs() {
    log_info "Creating backup of existing configurations..."
    
    BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    CONFIGS_TO_BACKUP=(
        ".config/hypr"
        ".config/waybar"
        ".config/alacritty"
        ".config/rofi"
        ".config/gtk-3.0"
        ".config/gtk-4.0"
        ".config/qt5ct"
        ".config/qt6ct"
        ".config/Kvantum"
        ".zshrc"
        ".gtkrc-2.0"
    )
    
    for config in "${CONFIGS_TO_BACKUP[@]}"; do
        if [[ -e "$HOME/$config" ]]; then
            cp -r "$HOME/$config" "$BACKUP_DIR/" 2>/dev/null || true
            log_info "Backed up $config"
        fi
    done
    
    log_success "Backup created at $BACKUP_DIR"
}

# Interactive menu
interactive_menu() {
    echo
    log_header "INSTALLATION OPTIONS"
    echo "1. Full installation (recommended for new systems)"
    echo "2. Install packages only"
    echo "3. Deploy dotfiles only"
    echo "4. Setup themes only"
    echo "5. Configure system only"
    echo "6. Setup git only"
    echo "7. Setup SDDM only"
    echo "8. Setup Zsh shell only"
    echo "9. Exit"
    echo
    
    read -p "Choose an option (1-9): " choice
    
    case $choice in
        1)
            log_info "Starting full installation..."
            backup_existing_configs
            install_packages
            setup_themes
            configure_system
            deploy_dotfiles
            ;;
        2)
            install_packages
            ;;
        3)
            backup_existing_configs
            deploy_dotfiles
            ;;
        4)
            setup_themes
            ;;
        5)
            configure_system
            ;;
        6)
            if [[ -f "$SETUP_DIR/system/setup-git.sh" ]]; then
                bash "$SETUP_DIR/system/setup-git.sh"
            else
                log_error "Git setup script not found"
            fi
            ;;
        7)
            if [[ -f "$SETUP_DIR/system/setup-sddm.sh" ]]; then
                bash "$SETUP_DIR/system/setup-sddm.sh"
            else
                log_error "SDDM setup script not found"
            fi
            ;;
        8)
            if [[ -f "$SETUP_DIR/system/setup-zsh.sh" ]]; then
                bash "$SETUP_DIR/system/setup-zsh.sh"
            else
                log_error "Zsh setup script not found"
            fi
            ;;
        9)
            log_info "Exiting..."
            exit 0
            ;;
        *)
            log_error "Invalid option selected"
            exit 1
            ;;
    esac
}

# Final instructions
show_final_instructions() {
    log_success "Setup completed!"
    echo
    log_info "Next steps:"
    echo "1. Reboot your system to ensure all changes take effect"
    echo "2. Log in to Hyprland from your display manager"
    echo "3. Your desktop should be themed with Catppuccin Macchiato"
    echo
    log_info "Useful commands after reboot:"
    echo "  Super + Enter  : Open terminal (Alacritty)"
    echo "  Super + Space  : Application launcher (Rofi)"
    echo "  Super + E      : File manager (Thunar)"
    echo "  Super + Q      : Close window"
    echo "  Super + 1-5    : Switch workspaces"
    echo
    log_info "Configuration files are now managed by GNU Stow."
    log_info "To update configs: edit files in ~/dotfiles/ and run 'stow -t ~ <package>'"
    echo
    log_warning "If you encounter any issues, check the backup at ~/.config-backup-*"
}

# Main execution
main() {
    display_banner
    echo
    
    check_system
    make_scripts_executable
    
    # Check for command line arguments
    if [[ $# -eq 0 ]]; then
        interactive_menu
    else
        case "$1" in
            --full)
                backup_existing_configs
                install_packages
                setup_themes
                configure_system
                deploy_dotfiles
                ;;
            --packages)
                install_packages
                ;;
            --dotfiles)
                backup_existing_configs
                deploy_dotfiles
                ;;
            --themes)
                setup_themes
                ;;
            --system)
                configure_system
                ;;
            --git)
                if [[ -f "$SETUP_DIR/system/setup-git.sh" ]]; then
                    bash "$SETUP_DIR/system/setup-git.sh"
                else
                    log_error "Git setup script not found"
                fi
                ;;
            --sddm)
                if [[ -f "$SETUP_DIR/system/setup-sddm.sh" ]]; then
                    bash "$SETUP_DIR/system/setup-sddm.sh"
                else
                    log_error "SDDM setup script not found"
                fi
                ;;
            --zsh)
                if [[ -f "$SETUP_DIR/system/setup-zsh.sh" ]]; then
                    bash "$SETUP_DIR/system/setup-zsh.sh"
                else
                    log_error "Zsh setup script not found"
                fi
                ;;
            --help)
                echo "Usage: $0 [option]"
                echo "Options:"
                echo "  --full      : Full installation"
                echo "  --packages  : Install packages only"
                echo "  --dotfiles  : Deploy dotfiles only"  
                echo "  --themes    : Setup themes only"
                echo "  --system    : Configure system only"
                echo "  --git       : Setup git only"
                echo "  --sddm      : Setup SDDM display manager only"
                echo "  --zsh       : Setup Zsh shell only"
                echo "  --help      : Show this help"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    fi
    
    show_final_instructions
}

# Run main function
main "$@"
