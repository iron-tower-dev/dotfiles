#!/usr/bin/env bash

# NixOS Deployment Script
# Deploys NixOS configuration with flakes and Home Manager

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_header() { echo -e "${PURPLE}[DEPLOY]${NC} $1"; }

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLAKE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
HOSTNAME="${HOSTNAME:-$(hostnamectl --static)}"
USERNAME="${USER}"

# Banner
display_banner() {
    cat << 'EOF'
    ╔═══════════════════════════════════════════════════════════════╗
    ║                        NIXOS DEPLOY                           ║
    ║                                                               ║
    ║              Flakes + Home Manager Deployment                ║
    ║                                                               ║
    ╚═══════════════════════════════════════════════════════════════╝
EOF
}

# Check if we're on NixOS
check_nixos() {
    log_info "Checking if running on NixOS..."
    
    if [[ ! -f /etc/nixos/configuration.nix ]] && [[ ! -d /etc/nixos ]]; then
        log_error "This script is designed for NixOS systems."
        exit 1
    fi
    
    log_success "NixOS detected"
}

# Check if flakes are enabled
check_flakes() {
    log_info "Checking if Nix flakes are enabled..."
    
    if ! nix --version | grep -q "flakes"; then
        log_warning "Nix flakes support not detected. Adding temporarily..."
        export NIX_CONFIG="experimental-features = nix-command flakes"
    fi
    
    log_success "Nix flakes are available"
}

# Validate flake configuration
validate_flake() {
    log_info "Validating flake configuration..."
    
    cd "$FLAKE_DIR"
    
    if ! nix flake check --no-build; then
        log_error "Flake validation failed"
        exit 1
    fi
    
    log_success "Flake configuration is valid"
}

# Deploy NixOS system configuration
deploy_system() {
    local hostname="$1"
    
    log_header "DEPLOYING NIXOS SYSTEM CONFIGURATION"
    log_info "Deploying for hostname: $hostname"
    
    cd "$FLAKE_DIR"
    
    # Check if the host configuration exists
    if ! nix eval ".#nixosConfigurations.${hostname}" --no-warn-dirty >/dev/null 2>&1; then
        log_warning "Host configuration '$hostname' not found. Available hosts:"
        nix eval '.#nixosConfigurations' --apply 'builtins.attrNames' --json | jq -r '.[]' | sed 's/^/  - /'
        
        read -p "Enter hostname to use (or 'skip' to skip system deployment): " new_hostname
        if [[ "$new_hostname" == "skip" ]]; then
            log_warning "Skipping system deployment"
            return 0
        fi
        hostname="$new_hostname"
    fi
    
    log_info "Building NixOS configuration..."
    if sudo --preserve-env=NIX_CONFIG,NIX_PATH,XDG_CONFIG_HOME nixos-rebuild switch --flake ".#${hostname}"; then
        log_success "NixOS system deployed successfully"
    else
        log_error "NixOS system deployment failed"
        exit 1
    fi
}

# Deploy Home Manager configuration
deploy_home() {
    local username="$1"
    local hostname="$2"
    local config_name="${username}@${hostname}"
    
    log_header "DEPLOYING HOME MANAGER CONFIGURATION"
    log_info "Deploying for user: $config_name"
    
    cd "$FLAKE_DIR"
    
    # Check if the home configuration exists
    if ! nix eval ".#homeConfigurations.\"${config_name}\"" --no-warn-dirty >/dev/null 2>&1; then
        log_warning "Home configuration '$config_name' not found. Available configurations:"
        nix eval '.#homeConfigurations' --apply 'builtins.attrNames' --json | jq -r '.[]' | sed 's/^/  - /'
        
        read -p "Enter configuration to use (or 'skip' to skip home deployment): " new_config
        if [[ "$new_config" == "skip" ]]; then
            log_warning "Skipping home deployment"
            return 0
        fi
        config_name="$new_config"
    fi
    
    log_info "Building Home Manager configuration..."
    if home-manager switch --flake ".#${config_name}"; then
        log_success "Home Manager configuration deployed successfully"
    else
        log_error "Home Manager deployment failed"
        exit 1
    fi
}

# Setup dotfiles symlinks
setup_dotfiles() {
    log_header "SETTING UP DOTFILES"
    
    local dotfiles_dir="$HOME/dotfiles"
    local nixos_dir="$HOME/dotfiles/nixos"
    
    # Create dotfiles symlink if it doesn't exist
    if [[ ! -L "$dotfiles_dir" ]] && [[ ! -d "$dotfiles_dir" ]]; then
        log_info "Creating dotfiles symlink..."
        ln -sf "$(dirname "$FLAKE_DIR")" "$dotfiles_dir"
        log_success "Dotfiles symlink created"
    elif [[ -L "$dotfiles_dir" ]]; then
        log_info "Dotfiles symlink already exists"
    else
        log_warning "Dotfiles directory exists but is not a symlink"
    fi
    
    # Ensure wallpapers are accessible
    if [[ -d "$dotfiles_dir/wallpapers" ]]; then
        log_success "Wallpapers directory found"
    else
        log_warning "Wallpapers directory not found"
    fi
}

# Update flake inputs
update_flake() {
    log_header "UPDATING FLAKE INPUTS"
    
    cd "$FLAKE_DIR"
    
    log_info "Updating flake inputs..."
    if nix flake update; then
        log_success "Flake inputs updated"
    else
        log_warning "Failed to update flake inputs"
    fi
}

# Interactive menu
interactive_menu() {
    echo
    log_header "DEPLOYMENT OPTIONS"
    echo "1. Full deployment (system + home)"
    echo "2. System deployment only"
    echo "3. Home Manager deployment only"
    echo "4. Setup dotfiles only"
    echo "5. Update flake inputs"
    echo "6. Validate configuration"
    echo "7. Exit"
    echo
    
    read -p "Choose an option (1-7): " choice
    
    case $choice in
        1)
            validate_flake
            setup_dotfiles
            deploy_system "$HOSTNAME"
            deploy_home "$USERNAME" "$HOSTNAME"
            ;;
        2)
            validate_flake
            deploy_system "$HOSTNAME"
            ;;
        3)
            validate_flake
            deploy_home "$USERNAME" "$HOSTNAME"
            ;;
        4)
            setup_dotfiles
            ;;
        5)
            update_flake
            ;;
        6)
            validate_flake
            ;;
        7)
            log_info "Exiting..."
            exit 0
            ;;
        *)
            log_error "Invalid option selected"
            exit 1
            ;;
    esac
}

# Show final instructions
show_final_instructions() {
    log_success "Deployment completed!"
    echo
    log_info "Next steps:"
    echo "1. Restart your system to ensure all changes take effect"
    echo "2. Your desktop should be themed with Catppuccin Macchiato"
    echo "3. Wallpaper system should be configured and ready to use"
    echo
    log_info "Useful commands:"
    echo "  rebuild                : Rebuild NixOS system"
    echo "  home-rebuild          : Rebuild Home Manager config"
    echo "  Super + W             : Change wallpaper"
    echo
    log_info "Configuration files:"
    echo "  NixOS config          : ~/dotfiles/nixos/"
    echo "  Flake file           : ~/dotfiles/nixos/flake.nix"
    echo "  Host config          : ~/dotfiles/nixos/hosts/"
    echo "  User config          : ~/dotfiles/nixos/users/"
}

# Main execution
main() {
    display_banner
    echo
    
    check_nixos
    check_flakes
    
    # Check for command line arguments
    if [[ $# -eq 0 ]]; then
        interactive_menu
    else
        case "$1" in
            --full)
                validate_flake
                setup_dotfiles
                deploy_system "$HOSTNAME"
                deploy_home "$USERNAME" "$HOSTNAME"
                ;;
            --system)
                validate_flake
                deploy_system "${2:-$HOSTNAME}"
                ;;
            --home)
                validate_flake
                deploy_home "$USERNAME" "${2:-$HOSTNAME}"
                ;;
            --setup)
                setup_dotfiles
                ;;
            --update)
                update_flake
                ;;
            --check)
                validate_flake
                ;;
            --help)
                echo "Usage: $0 [option] [hostname]"
                echo "Options:"
                echo "  --full         : Full deployment (system + home)"
                echo "  --system       : System deployment only"
                echo "  --home         : Home Manager deployment only"
                echo "  --setup        : Setup dotfiles only"
                echo "  --update       : Update flake inputs"
                echo "  --check        : Validate configuration"
                echo "  --help         : Show this help"
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
