#!/bin/bash

# Dotfiles Bootstrap Script
# Multi-distribution and multi-window manager dotfiles installer

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
DISTROS_DIR="$SCRIPT_DIR/distros"

# Global variables
DETECTED_DISTRO=""
DISTRO_SCRIPT=""

# Banner
display_banner() {
    cat << "EOF"
    ╔═══════════════════════════════════════════════════════════════╗
    ║                     DOTFILES BOOTSTRAP                       ║
    ║                                                               ║
    ║      Multi-Distribution Desktop Environment Installer         ║
    ║                                                               ║
    ╚═══════════════════════════════════════════════════════════════╝
EOF
}

# Detect Linux distribution
detect_distribution() {
    log_info "Detecting Linux distribution..."
    
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        case "$ID" in
            "arch")
                DETECTED_DISTRO="arch"
                DISTRO_SCRIPT="$DISTROS_DIR/arch/arch-install.sh"
                ;;
            "manjaro")
                DETECTED_DISTRO="arch"  # Manjaro uses pacman like Arch
                DISTRO_SCRIPT="$DISTROS_DIR/arch/arch-install.sh"
                ;;
            "ubuntu"|"debian"|"pop"|"elementary")
                DETECTED_DISTRO="debian"
                DISTRO_SCRIPT="$DISTROS_DIR/debian/debian-install.sh"
                log_warning "Debian-based distributions not yet fully supported"
                ;;
            "fedora"|"centos"|"rhel")
                DETECTED_DISTRO="fedora"
                DISTRO_SCRIPT="$DISTROS_DIR/fedora/fedora-install.sh"
                log_warning "Red Hat-based distributions not yet fully supported"
                ;;
            "nixos")
                DETECTED_DISTRO="nixos"
                DISTRO_SCRIPT="$DISTROS_DIR/nixos/nixos-install.sh"
                log_warning "NixOS supported via flakes-based installer (experimental)"
                ;;
            *)
                log_error "Unsupported distribution: $ID"
                log_info "Currently supported: Arch Linux (including Manjaro)"
                log_info "Planned support: Debian/Ubuntu, Fedora, NixOS"
                exit 1
                ;;
        esac
    else
        log_error "Cannot detect distribution (/etc/os-release not found)"
        exit 1
    fi
    
    log_success "Detected: $ID (using $DETECTED_DISTRO installer)"
}

# Check if distribution installer exists
check_distro_installer() {
    if [[ ! -f "$DISTRO_SCRIPT" ]]; then
        log_error "Distribution installer not found: $DISTRO_SCRIPT"
        log_info "Available installers:"
        find "$DISTROS_DIR" -name "*-install.sh" -type f | sed 's|.*/||' | sort
        exit 1
    fi
    
    if [[ ! -x "$DISTRO_SCRIPT" ]]; then
        chmod +x "$DISTRO_SCRIPT"
    fi
}

# Make scripts executable
make_scripts_executable() {
    log_info "Making setup scripts executable..."
    find "$SETUP_DIR" -name "*.sh" -type f -exec chmod +x {} \;
    find "$DISTROS_DIR" -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true
    find "$SCRIPT_DIR/window_managers" -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true
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
    
    # Setup Python build dependencies before AUR packages
    if [[ -f "$SETUP_DIR/system/setup-python-build-deps.sh" ]]; then
        log_info "Setting up Python build dependencies for AUR packages..."
        bash "$SETUP_DIR/system/setup-python-build-deps.sh"
    else
        log_warning "Python build dependencies script not found, AUR packages may fail..."
    fi
    
    if [[ -f "$SETUP_DIR/packages/02-aur-packages.sh" ]]; then
        log_info "Installing AUR packages..."
        bash "$SETUP_DIR/packages/02-aur-packages.sh"
    else
        log_warning "AUR packages script not found, skipping..."
    fi
}

# Install gaming packages
install_gaming() {
    log_header "INSTALLING GAMING PACKAGES"
    
    if [[ -f "$SETUP_DIR/packages/03-gaming-packages.sh" ]]; then
        log_info "Installing gaming packages and drivers..."
        bash "$SETUP_DIR/packages/03-gaming-packages.sh"
    else
        log_warning "Gaming packages script not found, skipping..."
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
        log_error "GNU Stow is not installed. Please install it using your distro's package manager"
        log_info "Examples: pacman -S stow | apt install stow | dnf install stow"
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
        "gaming"
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

# Legacy mode for backward compatibility
legacy_mode() {
    log_warning "Running in legacy mode (Arch Linux + Hyprland only)"
    log_info "For the new multi-WM installer, use: $DISTRO_SCRIPT"
    
    echo
    log_header "LEGACY INSTALLATION OPTIONS"
    echo "1. Full Hyprland installation (recommended)"
    echo "2. Install packages only"
    echo "3. Deploy dotfiles only"
    echo "4. Setup themes only"
    echo "5. Configure system only"
    echo "6. Setup git only"
    echo "7. Setup SDDM only"
    echo "8. Setup Zsh shell only"
    echo "9. Setup Python build dependencies only"
    echo "10. Install gaming setup (Steam + GE-Proton)"
    echo "11. Exit"
    echo
    
    read -p "Choose an option (1-11): " choice
    
    case $choice in
        1)
            log_info "Starting full Hyprland installation..."
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
            if [[ -f "$SETUP_DIR/system/setup-python-build-deps.sh" ]]; then
                bash "$SETUP_DIR/system/setup-python-build-deps.sh"
            else
                log_error "Python build dependencies script not found"
            fi
            ;;
        10)
            install_gaming
            if [[ -d "gaming" ]]; then
                log_info "Deploying gaming configurations..."
                if stow -t "$HOME" "gaming"; then
                    log_success "Gaming configurations deployed"
                else
                    log_warning "Failed to deploy gaming configurations"
                fi
            fi
            if [[ -f "$SETUP_DIR/system/setup-ge-proton.sh" ]]; then
                log_info "Setting up GE-Proton..."
                bash "$SETUP_DIR/system/setup-ge-proton.sh"
            else
                log_warning "GE-Proton setup script not found"
            fi
            ;;
        11)
            log_info "Exiting..."
            exit 0
            ;;
        *)
            log_error "Invalid option selected"
            exit 1
            ;;
    esac
}

# Modern installation (use distro-specific installer)
modern_installation() {
    log_header "MODERN MULTI-WM INSTALLER"
    log_info "Launching distribution-specific installer..."
    log_info "Installer: $DISTRO_SCRIPT"
    echo
    
    # Support non-interactive usage with --yes / -y
    local skip_prompt=0
    local arg
    for arg in "$@"; do
        if [[ "$arg" == "--yes" || "$arg" == "-y" ]]; then
            skip_prompt=1
            break
        fi
    done

    if [[ $skip_prompt -eq 0 ]]; then
        read -p "Continue with modern installer? (Y/n): " choice
        if [[ "$choice" =~ ^[Nn]$ ]]; then
            log_info "Falling back to legacy mode..."
            return 1
        fi
    fi
    
    # Execute the distribution-specific installer (filter out --yes/-y)
    local pass_args=()
    for arg in "$@"; do
        if [[ "$arg" != "--yes" && "$arg" != "-y" ]]; then
            pass_args+=("$arg")
        fi
    done
    bash "$DISTRO_SCRIPT" "${pass_args[@]}"
    exit $?
}

# Final instructions for legacy mode
show_final_instructions() {
    log_success "Legacy setup completed!"
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
    log_info "To update configs: edit files in $SCRIPT_DIR/ and run 'stow -t ~ <package>'"
    echo
    log_warning "If you encounter any issues, check the backup at ~/.config-backup-*"
    echo
    log_info "For future installations, consider using: $DISTRO_SCRIPT"
}

# Main execution
main() {
    display_banner
    echo
    
    detect_distribution
    check_distro_installer
    make_scripts_executable
    
    # Check for command line arguments
    if [[ $# -eq 0 ]]; then
        # Try modern installer first
        if modern_installation "$@"; then
            exit 0
        else
            # Fall back to legacy mode
            if [[ "$DETECTED_DISTRO" == "arch" ]]; then
                legacy_mode
            else
                log_error "Legacy mode only available for Arch Linux"
                log_info "Please use the distribution-specific installer: $DISTRO_SCRIPT"
                exit 1
            fi
        fi
    else
        case "$1" in
            --modern|--new)
                shift  # Remove the flag from arguments
                modern_installation "$@"
                ;;
            --legacy)
                if [[ "$DETECTED_DISTRO" != "arch" ]]; then
                    log_error "Legacy mode only available for Arch Linux"
                    exit 1
                fi
                shift  # Remove the flag
                legacy_command_line "$@"
                ;;
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
            --python-deps)
                if [[ -f "$SETUP_DIR/system/setup-python-build-deps.sh" ]]; then
                    bash "$SETUP_DIR/system/setup-python-build-deps.sh"
                else
                    log_error "Python build dependencies script not found"
                fi
                ;;
            --gaming)
                install_gaming
                if [[ -d "gaming" ]]; then
                    log_info "Deploying gaming configurations..."
                    if stow -t "$HOME" "gaming"; then
                        log_success "Gaming configurations deployed"
                    else
                        log_warning "Failed to deploy gaming configurations"
                    fi
                fi
                if [[ -f "$SETUP_DIR/system/setup-ge-proton.sh" ]]; then
                    log_info "Setting up GE-Proton..."
                    bash "$SETUP_DIR/system/setup-ge-proton.sh"
                else
                    log_warning "GE-Proton setup script not found"
                fi
                ;;
            --help)
                echo "Usage: $0 [option]"
                echo "Options:"
                echo "  --modern       : Use new multi-WM installer (default)"
                echo "  --yes, -y      : Skip prompts in modern installer (non-interactive)"
                echo "  --legacy       : Use legacy Hyprland-only installer (Arch only)"
                echo "  --full         : Full Hyprland installation (legacy)"
                echo "  --packages     : Install packages only (legacy)"
                echo "  --dotfiles     : Deploy dotfiles only (legacy)"
                echo "  --themes       : Setup themes only (legacy)"
                echo "  --system       : Configure system only (legacy)"
                echo "  --git          : Setup git only (legacy)"
                echo "  --sddm         : Setup SDDM display manager only (legacy)"
                echo "  --zsh          : Setup Zsh shell only (legacy)"
                echo "  --python-deps  : Setup Python build dependencies only (legacy)"
                echo "  --gaming       : Install gaming setup (legacy)"
                echo "  --help         : Show this help"
                echo ""
                if [[ "$DETECTED_DISTRO" == "nixos" ]]; then
                    echo "NixOS Flakes installer: $DISTRO_SCRIPT"
                else
                    echo "For multi-window manager support, use: $DISTRO_SCRIPT"
                fi
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

# Handle legacy command line arguments
legacy_command_line() {
    if [[ $# -eq 0 ]]; then
        legacy_mode
        return
    fi
    
    # Process remaining legacy arguments here
    case "$1" in
        --full)
            backup_existing_configs
            install_packages
            setup_themes
            configure_system
            deploy_dotfiles
            ;;
        *)
            log_error "Unknown legacy option: $1"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
