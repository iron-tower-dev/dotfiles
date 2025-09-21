#!/bin/bash

# SDDM Setup Script for Catppuccin Macchiato Theme
# Part of the Arch Linux dotfiles configuration

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root"
        exit 1
    fi
}

# Create backup of existing configuration
backup_existing_config() {
    local backup_dir="/etc/sddm.conf.backup.$(date +%Y%m%d_%H%M%S)"
    
    if [[ -f "/etc/sddm.conf" ]]; then
        log_info "Creating backup of existing SDDM configuration..."
        sudo cp "/etc/sddm.conf" "${backup_dir}"
        log_success "Backup created at ${backup_dir}"
    fi
}

# Install SDDM and dependencies
install_sddm() {
    log_info "Installing SDDM and dependencies..."
    
    # Install SDDM
    if ! pacman -Qi sddm &> /dev/null; then
        sudo pacman -S --needed --noconfirm sddm qt5-quickcontrols2 qt5-graphicaleffects
        log_success "SDDM installed successfully"
    else
        log_info "SDDM already installed"
    fi
    
    # Install Catppuccin Macchiato theme from AUR
    log_info "Installing Catppuccin Macchiato SDDM theme..."
    if ! paru -Qi catppuccin-sddm-theme-macchiato &> /dev/null; then
        paru -S --needed --noconfirm catppuccin-sddm-theme-macchiato
        log_success "Catppuccin Macchiato SDDM theme installed"
    else
        log_info "Catppuccin Macchiato SDDM theme already installed"
    fi
    
    # Install Catppuccin cursors for complete theming
    log_info "Installing Catppuccin cursor theme..."
    if ! paru -Qi catppuccin-cursors-macchiato &> /dev/null; then
        paru -S --needed --noconfirm catppuccin-cursors-macchiato || log_warning "Catppuccin cursors not available, using default"
    fi
}

# Deploy SDDM configuration
deploy_config() {
    log_info "Deploying SDDM configuration..."
    
    # Create backup
    backup_existing_config
    
    # Copy configuration file
    if [[ -f "${DOTFILES_DIR}/sddm/sddm.conf" ]]; then
        sudo cp "${DOTFILES_DIR}/sddm/sddm.conf" "/etc/sddm.conf"
        sudo chmod 644 "/etc/sddm.conf"
        log_success "SDDM configuration deployed to /etc/sddm.conf"
    else
        log_error "SDDM configuration file not found in dotfiles"
        exit 1
    fi
}

# Enable and configure SDDM service
configure_service() {
    log_info "Configuring SDDM service..."
    
    # Disable other display managers
    local other_dms=("gdm" "lightdm" "lxdm" "xdm")
    for dm in "${other_dms[@]}"; do
        if systemctl is-enabled "${dm}.service" &> /dev/null; then
            log_warning "Disabling ${dm}.service..."
            sudo systemctl disable "${dm}.service"
        fi
    done
    
    # Enable SDDM
    sudo systemctl enable sddm.service
    log_success "SDDM service enabled"
    
    # Check if we should restart the display manager
    if systemctl is-active display-manager.service &> /dev/null; then
        log_warning "Display manager is currently running"
        log_info "SDDM will be used after next reboot, or you can restart now with:"
        log_info "sudo systemctl restart display-manager.service"
    fi
}

# Verify theme installation
verify_theme() {
    log_info "Verifying Catppuccin Macchiato theme installation..."
    
    local theme_path="/usr/share/sddm/themes/catppuccin-macchiato"
    if [[ -d "${theme_path}" ]]; then
        log_success "Catppuccin Macchiato theme found at ${theme_path}"
        
        # List theme contents
        log_info "Theme contents:"
        ls -la "${theme_path}" | head -10
    else
        log_error "Catppuccin Macchiato theme not found"
        log_info "Available themes:"
        ls -la "/usr/share/sddm/themes/" 2>/dev/null || log_warning "No themes directory found"
    fi
}

# Create Qt configuration for SDDM (system-wide)
configure_qt_theme() {
    log_info "Configuring Qt theme for SDDM..."
    
    # Create sddm Qt configuration directory
    sudo mkdir -p /var/lib/sddm/.config
    
    # Create Qt configuration for Catppuccin theming
    sudo tee /var/lib/sddm/.config/qt5ct.conf > /dev/null <<EOF
[Appearance]
color_scheme_path=/usr/share/qt5ct/colors/catppuccin-macchiato.conf
custom_palette=false
icon_theme=Papirus-Dark
standard_dialogs=default
style=kvantum-dark

[Fonts]
fixed="JetBrainsMono Nerd Font,10,-1,5,50,0,0,0,0,0"
general="Inter,10,-1,5,50,0,0,0,0,0"

[Interface]
activate_item_on_single_click=1
buttonbox_layout=0
cursor_flash_time=1000
dialog_buttons_have_icons=1
double_click_interval=400
gui_effects=@Invalid()
keyboard_scheme=2
menus_have_icons=true
show_shortcuts_in_context_menus=true
stylesheets=@Invalid()
toolbutton_style=4
underline_shortcut=1
wheel_scroll_lines=3

[SettingsWindow]
geometry=@ByteArray(\x1\xd9\xd0\xcb\0\x3\0\0\0\0\x2\x80\0\0\x1\x37\0\0\x5\x7f\0\0\x3\x94\0\0\x2\x80\0\0\x1\x37\0\0\x5\x7f\0\0\x3\x94\0\0\0\0\0\0\0\0\a\x80\0\0\x2\x80\0\0\x1\x37\0\0\x5\x7f\0\0\x3\x94)
EOF
    
    sudo chown -R sddm:sddm /var/lib/sddm/.config
    log_success "Qt configuration created for SDDM"
}

# Main installation function
main() {
    log_info "Starting SDDM Catppuccin Macchiato setup..."
    
    check_root
    install_sddm
    deploy_config
    configure_service
    configure_qt_theme
    verify_theme
    
    log_success "SDDM setup completed successfully!"
    log_info ""
    log_info "Next steps:"
    log_info "1. Reboot your system to use SDDM with Catppuccin Macchiato theme"
    log_info "2. Or restart the display manager: sudo systemctl restart display-manager.service"
    log_info ""
    log_info "SDDM Configuration: /etc/sddm.conf"
    log_info "Theme Location: /usr/share/sddm/themes/catppuccin-macchiato"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
