#!/bin/bash

# Arch Linux Desktop Environment Installer
# Support for multiple window managers: Hyprland (Wayland), Qtile (X11), DWM (X11), DWL (Wayland)

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
log_header() { echo -e "${PURPLE}[SETUP]${NC} $1"; }

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
SETUP_DIR="$DOTFILES_DIR/setup"

# Global variables
SELECTED_DISPLAY_SERVER=""
SELECTED_WINDOW_MANAGER=""

# Banner
display_banner() {
    cat << "EOF"
    ╔═══════════════════════════════════════════════════════════════╗
    ║                    ARCH LINUX INSTALLER                      ║
    ║                                                               ║
    ║      Choose your desktop environment and window manager       ║
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
    find "$SETUP_DIR" -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true
    find "$DOTFILES_DIR/window_managers" -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true
    log_success "Setup scripts are now executable"
}

# Display server selection
select_display_server() {
    echo
    log_header "DISPLAY SERVER SELECTION"
    echo "1. Wayland (Modern, secure, better for HiDPI)"
    echo "2. X11 (Traditional, broader compatibility)"
    echo
    
    while true; do
        read -p "Choose display server (1-2): " choice
        case $choice in
            1)
                SELECTED_DISPLAY_SERVER="wayland"
                log_info "Selected: Wayland"
                break
                ;;
            2)
                SELECTED_DISPLAY_SERVER="x11"
                log_info "Selected: X11"
                break
                ;;
            *)
                log_error "Invalid choice. Please select 1 or 2."
                ;;
        esac
    done
}

# Window manager selection based on display server
select_window_manager() {
    echo
    log_header "WINDOW MANAGER SELECTION"
    
    if [[ "$SELECTED_DISPLAY_SERVER" == "wayland" ]]; then
        echo "Available Wayland window managers:"
        echo "1. Hyprland (Feature-rich, animations, tiling)"
        echo "2. DWL (Lightweight, minimalist, suckless)"
        echo
        
        while true; do
            read -p "Choose window manager (1-2): " choice
            case $choice in
                1)
                    SELECTED_WINDOW_MANAGER="hyprland"
                    log_info "Selected: Hyprland (Wayland)"
                    break
                    ;;
                2)
                    SELECTED_WINDOW_MANAGER="dwl"
                    log_info "Selected: DWL (Wayland)"
                    break
                    ;;
                *)
                    log_error "Invalid choice. Please select 1 or 2."
                    ;;
            esac
        done
    else
        echo "Available X11 window managers:"
        echo "1. Qtile (Python-based, highly configurable)"
        echo "2. DWM (Lightweight, suckless, C-based)"
        echo
        
        while true; do
            read -p "Choose window manager (1-2): " choice
            case $choice in
                1)
                    SELECTED_WINDOW_MANAGER="qtile"
                    log_info "Selected: Qtile (X11)"
                    break
                    ;;
                2)
                    SELECTED_WINDOW_MANAGER="dwm"
                    log_info "Selected: DWM (X11)"
                    break
                    ;;
                *)
                    log_error "Invalid choice. Please select 1 or 2."
                    ;;
            esac
        done
    fi
}

# Install base packages
install_base_packages() {
    log_header "INSTALLING BASE PACKAGES"
    
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

# Install display server packages
install_display_server_packages() {
    log_header "INSTALLING DISPLAY SERVER PACKAGES"
    
    if [[ "$SELECTED_DISPLAY_SERVER" == "wayland" ]]; then
        log_info "Installing Wayland packages..."
        
        # Wayland core packages
        sudo pacman -S --needed --noconfirm \
            wayland wayland-protocols \
            xorg-xwayland \
            wl-clipboard \
            grim slurp
        if [[ "$SELECTED_WINDOW_MANAGER" == "hyprland" ]]; then
          sudo pacman -S --needed --noconfirm xdg-desktop-portal-hyprland || sudo pacman -S --needed --noconfirm xdg-desktop-portal-wlr
        else
          sudo pacman -S --needed --noconfirm xdg-desktop-portal-wlr
        fi
            
    else
        log_info "Installing X11 packages..."
        
        # X11 core packages
        sudo pacman -S --needed --noconfirm \
            xorg-server xorg-xinit xorg-xsetroot \
            xorg-xrandr xorg-xrdb \
            picom \
            feh \
            dmenu \
            xclip
    fi
}

# Install window manager
install_window_manager() {
    log_header "INSTALLING WINDOW MANAGER: $SELECTED_WINDOW_MANAGER"
    
    case "$SELECTED_WINDOW_MANAGER" in
        hyprland)
            if [[ -x "$DOTFILES_DIR/window_managers/hyprland/install-hyprland.sh" ]]; then
              bash "$DOTFILES_DIR/window_managers/hyprland/install-hyprland.sh"
            else
              log_error "Hyprland installer not found"; exit 1
            fi
            ;;
        qtile)
            if [[ -x "$DOTFILES_DIR/window_managers/qtile/install-qtile.sh" ]]; then
              bash "$DOTFILES_DIR/window_managers/qtile/install-qtile.sh"
            else
              log_error "Qtile installer not found"; exit 1
            fi
            ;;
        dwm)
            if [[ -x "$DOTFILES_DIR/window_managers/dwm/install-dwm.sh" ]]; then
              bash "$DOTFILES_DIR/window_managers/dwm/install-dwm.sh"
            else
              log_error "DWM installer not found"; exit 1
            fi
            ;;
        dwl)
            if [[ -x "$DOTFILES_DIR/window_managers/dwl/install-dwl.sh" ]]; then
              bash "$DOTFILES_DIR/window_managers/dwl/install-dwl.sh"
            else
              log_error "DWL installer not found"; exit 1
            fi
            ;;
        *)
            log_error "Unknown window manager: $SELECTED_WINDOW_MANAGER"
            exit 1
            ;;
    esac
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
    
    # Setup display manager
    setup_display_manager
}

# Setup display manager
setup_display_manager() {
    log_info "Setting up display manager..."
    
    if [[ "$SELECTED_DISPLAY_SERVER" == "wayland" ]]; then
        # Use SDDM for Wayland
        if [[ -f "$SETUP_DIR/system/setup-sddm.sh" ]]; then
            bash "$SETUP_DIR/system/setup-sddm.sh"
        else
            log_warning "SDDM setup script not found, manual setup required..."
        fi
    else
        # For X11, we can use lighter alternatives
        log_info "For X11 setup, you can use startx or setup a display manager manually"
        log_info "Consider: sudo systemctl enable gdm (or lightdm, or sddm)"
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
    
    # Base packages that are always deployed
    STOW_PACKAGES=(
        "alacritty"
        "fish"
        "nushell"
        "mise"
        "zsh"
        "git"
        "neovim"
        "themes"
    )
    
    # Add window manager specific packages
    case "$SELECTED_WINDOW_MANAGER" in
        hyprland)
            STOW_PACKAGES+=("hyprland" "waybar" "rofi" "sddm")
            ;;
        qtile)
            STOW_PACKAGES+=("qtile")
            ;;
        dwm)
            STOW_PACKAGES+=("dwm")
            ;;
        dwl)
            STOW_PACKAGES+=("dwl")
            ;;
    esac
    
    cd "$DOTFILES_DIR"
    
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
        ".config/qtile"
        ".config/dwm"
        ".config/alacritty"
        ".config/rofi"
        ".config/gtk-3.0"
        ".config/gtk-4.0"
        ".config/qt5ct"
        ".config/qt6ct"
        ".config/Kvantum"
        ".zshrc"
        ".gtkrc-2.0"
        ".xinitrc"
    )
    
    for config in "${CONFIGS_TO_BACKUP[@]}"; do
        if [[ -e "$HOME/$config" ]]; then
            cp -r "$HOME/$config" "$BACKUP_DIR/" 2>/dev/null || true
            log_info "Backed up $config"
        fi
    done
    
    log_success "Backup created at $BACKUP_DIR"
}

# Create startup files
create_startup_files() {
    log_header "CREATING STARTUP FILES"
    
    case "$SELECTED_WINDOW_MANAGER" in
        hyprland)
            log_info "Hyprland startup is handled by display manager"
            ;;
        qtile|dwm)
            log_info "Creating .xinitrc for $SELECTED_WINDOW_MANAGER..."
            create_xinitrc
            ;;
        dwl)
            log_info "DWL startup is handled by display manager"
            ;;
    esac
}

# Create xinitrc for X11 window managers
create_xinitrc() {
    local xinitrc="$HOME/.xinitrc"
    
    cat > "$xinitrc" << EOF
#!/bin/bash

# Load X resources
[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources

# Set background (if using feh)
[[ -f ~/.fehbg ]] && ~/.fehbg &

# Start compositor (if using picom)
picom -b &

# Start window manager
case "\$1" in
    qtile)
        exec qtile start
        ;;
    dwm)
        exec dwm
        ;;
    *)
        exec $SELECTED_WINDOW_MANAGER
        ;;
esac
EOF
    
    chmod +x "$xinitrc"
    log_success "Created $xinitrc"
    log_info "You can start your desktop with: startx $SELECTED_WINDOW_MANAGER"
}

# Show final instructions
show_final_instructions() {
    log_success "Arch Linux desktop setup completed!"
    echo
    log_info "Configuration Summary:"
    echo "  Display Server: $SELECTED_DISPLAY_SERVER"
    echo "  Window Manager: $SELECTED_WINDOW_MANAGER"
    echo
    log_info "Next steps:"
    
    if [[ "$SELECTED_DISPLAY_SERVER" == "wayland" ]]; then
        echo "1. Reboot your system"
        echo "2. Log in to $SELECTED_WINDOW_MANAGER from SDDM"
        if [[ "$SELECTED_WINDOW_MANAGER" == "hyprland" ]]; then
            echo "3. Your desktop should be themed with Catppuccin Macchiato"
            echo
            log_info "Hyprland keybindings:"
            echo "  Super + Enter  : Open terminal (Alacritty)"
            echo "  Super + Space  : Application launcher (Rofi)"
            echo "  Super + E      : File manager"
            echo "  Super + Q      : Close window"
            echo "  Super + 1-5    : Switch workspaces"
        fi
    else
        echo "1. Reboot your system (or logout/login)"
        if command -v sddm &> /dev/null || command -v gdm &> /dev/null || command -v lightdm &> /dev/null; then
            echo "2. Log in to $SELECTED_WINDOW_MANAGER from your display manager"
        else
            echo "2. Start your desktop with: startx $SELECTED_WINDOW_MANAGER"
            echo "   (or setup a display manager: sudo systemctl enable sddm)"
        fi
        
        if [[ "$SELECTED_WINDOW_MANAGER" == "qtile" ]]; then
            echo
            log_info "Qtile keybindings (default):"
            echo "  Mod + Return     : Open terminal"
            echo "  Mod + r          : Application launcher"
            echo "  Mod + w          : Close window"
            echo "  Mod + Tab        : Switch windows"
            echo "  Mod + 1-9        : Switch workspaces"
        elif [[ "$SELECTED_WINDOW_MANAGER" == "dwm" ]]; then
            echo
            log_info "DWM keybindings (default):"
            echo "  Alt + Shift + Return : Open terminal"
            echo "  Alt + p              : dmenu launcher"
            echo "  Alt + Shift + c      : Close window"
            echo "  Alt + j/k            : Switch windows"
            echo "  Alt + 1-9            : Switch tags"
        fi
    fi
    
    echo
    log_info "Configuration files are managed by GNU Stow."
    log_info "To update configs: edit files in ~/dotfiles/ and run 'stow -t ~ <package>'"
    echo
    log_warning "If you encounter issues, check the backup at ~/.config-backup-*"
}

# Main execution
main() {
    display_banner
    echo
    
    check_system
    make_scripts_executable
    
    # Interactive setup
    select_display_server
    select_window_manager
    
    log_header "STARTING INSTALLATION"
    echo "Display Server: $SELECTED_DISPLAY_SERVER"
    echo "Window Manager: $SELECTED_WINDOW_MANAGER"
    echo
    
    read -p "Continue with installation? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_info "Installation cancelled"
        exit 0
    fi
    
    backup_existing_configs
    install_base_packages
    install_display_server_packages
    install_window_manager
    setup_themes
    configure_system
    create_startup_files
    deploy_dotfiles
    
    show_final_instructions
}

# Command line argument handling
if [[ $# -gt 0 ]]; then
    case "$1" in
        --help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --help          : Show this help"
            echo ""
            echo "Interactive mode will guide you through:"
            echo "  - Display server selection (Wayland/X11)"
            echo "  - Window manager selection"
            echo "  - Full system setup"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
fi

# Run main function
main "$@"
