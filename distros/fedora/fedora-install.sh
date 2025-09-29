#!/bin/bash

# Fedora Linux Desktop Environment Installer
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
    ║                    FEDORA LINUX INSTALLER                    ║
    ║                                                               ║
    ║      Choose your desktop environment and window manager       ║
    ║                                                               ║
    ╚═══════════════════════════════════════════════════════════════╝
EOF
}

# Check if running on Fedora
check_system() {
    log_info "Checking system compatibility..."
    
    if ! command -v dnf &> /dev/null; then
        log_error "This script is designed for Fedora systems with dnf."
        exit 1
    fi
    
    log_success "Fedora Linux detected"
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
    
    # Update system first
    log_info "Updating system packages..."
    sudo dnf upgrade -y
    
    # Install development tools
    log_info "Installing development tools..."
    sudo dnf groupinstall -y "Development Tools"
    sudo dnf install -y \
        git \
        curl \
        wget \
        stow \
        make \
        gcc \
        gcc-c++ \
        cmake \
        pkgconf-devel
    
    # Enable RPM Fusion repositories
    log_info "Enabling RPM Fusion repositories..."
    sudo dnf install -y \
        "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
        "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm" || true
    
    # Install core packages
    log_info "Installing core packages..."
    sudo dnf install -y \
        alacritty \
        fish \
        zsh \
        neovim \
        firefox \
        thunderbird \
        libreoffice \
        gimp \
        vlc \
        htop \
        tree \
        ripgrep \
        fd-find \
        bat \
        eza \
        fzf \
        tmux \
        zip \
        unzip \
        p7zip \
        p7zip-plugins
        
    log_success "Base packages installed"
}

# Install display server packages
install_display_server_packages() {
    log_header "INSTALLING DISPLAY SERVER PACKAGES"
    
    if [[ "$SELECTED_DISPLAY_SERVER" == "wayland" ]]; then
        log_info "Installing Wayland packages..."
        
        # Wayland runtime packages (no -devel packages for end users)
        sudo dnf install -y \
            wayland \
            wayland-protocols \
            xorg-x11-server-Xwayland \
            wl-clipboard \
            grim \
            slurp
        
        # Install appropriate XDG portal based on window manager
        if [[ "$SELECTED_WINDOW_MANAGER" == "hyprland" ]]; then
            sudo dnf install -y xdg-desktop-portal-hyprland || sudo dnf install -y xdg-desktop-portal-wlr
        else
            sudo dnf install -y xdg-desktop-portal-wlr
        fi
            
    else
        log_info "Installing X11 packages..."
        
        # X11 core packages
        sudo dnf install -y \
            xorg-x11-server-Xorg \
            xorg-x11-xinit \
            xorg-x11-apps \
            xorg-x11-utils \
            picom \
            feh \
            dmenu \
            xclip \
            arandr \
            lxappearance
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
    
    # Install GTK themes and icon packs (runtime packages only)
    log_info "Installing theme packages..."
    sudo dnf install -y \
        gtk3 \
        gtk4 \
        adwaita-gtk3-theme \
        qt5ct \
        qt6ct \
        kvantum \
        papirus-icon-theme \
        breeze-icon-theme
    
    # lxappearance is already installed in X11 section if needed
    log_success "Theme packages installed"
}

# Configure system
configure_system() {
    log_header "CONFIGURING SYSTEM"
    
    # Configure Fish shell
    configure_fish_shell
    
    # Configure Zsh shell
    configure_zsh_shell
    
    # Setup development tools
    setup_development_tools
    
    # Setup display manager
    setup_display_manager
}

# Configure Fish shell
configure_fish_shell() {
    log_info "Configuring Fish shell..."
    
    # Add fish to valid shells if available
    if command -v fish &>/dev/null; then
        local fish_path
        fish_path="$(command -v fish || true)"
        if [[ -n "$fish_path" ]] && ! grep -qx "$fish_path" /etc/shells; then
            echo "$fish_path" | sudo tee -a /etc/shells >/dev/null
        fi
    fi
    
    # Create fish config directory
    mkdir -p "$HOME/.config/fish"
    
    log_success "Fish shell configured"
}

# Configure Zsh shell
configure_zsh_shell() {
    log_info "Configuring Zsh shell..."
    
    # Install oh-my-zsh if it doesn't exist
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log_info "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || true
    fi
    
    log_success "Zsh shell configured"
}

# Setup development tools
setup_development_tools() {
    log_info "Setting up development tools..."
    
    # Install mise (modern tool version manager)
    if ! command -v mise &> /dev/null; then
        log_info "Installing mise..."
        curl -fsSL https://mise.run | sh
        echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
        echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc
    fi
    
    # Install UV for Python package management
    if ! command -v uv &> /dev/null; then
        log_info "Installing UV (Python package manager)..."
        curl -fsSL https://astral.sh/uv/install.sh | sh
    fi
    
    log_success "Development tools configured"
}

# Setup display manager
setup_display_manager() {
    log_info "Setting up display manager..."
    
    if [[ "$SELECTED_DISPLAY_SERVER" == "wayland" ]]; then
        # Use GDM for Wayland (default on Fedora)
        log_info "Configuring GDM for Wayland support..."

        # Ensure GDM is installed before enabling
        if ! rpm -q gdm &>/dev/null; then
            log_info "Installing GDM..."
            sudo dnf install -y gdm
        fi

        # Idempotently configure /etc/gdm/custom.conf
        sudo mkdir -p /etc/gdm
        if [[ -f /etc/gdm/custom.conf ]]; then
            sudo cp /etc/gdm/custom.conf "/etc/gdm/custom.conf.bak.$(date +%Y%m%d-%H%M%S)"
        fi

        if [[ ! -f /etc/gdm/custom.conf ]]; then
            # Create with [daemon] and WaylandEnable=true
            printf "[daemon]\nWaylandEnable=true\n" | sudo tee /etc/gdm/custom.conf >/dev/null
        else
            # Ensure [daemon] section exists
            if ! sudo grep -q "^\[daemon\]" /etc/gdm/custom.conf; then
                echo "[daemon]" | sudo tee -a /etc/gdm/custom.conf >/dev/null
            fi
            # Normalize any existing WaylandEnable line (commented or not)
            if sudo grep -qE "^[#;]?\s*WaylandEnable\s*=.*" /etc/gdm/custom.conf; then
                sudo sed -i -E 's/^[#;]?\s*WaylandEnable\s*=.*/WaylandEnable=true/' /etc/gdm/custom.conf
            else
                # Insert under the first [daemon] section
                sudo sed -i '/^\[daemon\]/a WaylandEnable=true' /etc/gdm/custom.conf
            fi
        fi

        # Enable and start GDM
        sudo systemctl enable --now gdm
    else
        # For X11, ensure GDM is installed then enable
        log_info "Setting up GDM for X11 session management..."
        if ! rpm -q gdm &>/dev/null; then
            log_info "Installing GDM..."
            sudo dnf install -y gdm
        fi
        sudo systemctl enable --now gdm
    fi
}

# Deploy dotfiles with stow
deploy_dotfiles() {
    log_header "DEPLOYING DOTFILES"
    
    if ! command -v stow &> /dev/null; then
        log_error "GNU Stow is not installed. This should have been installed with base packages."
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
            STOW_PACKAGES+=("hyprland" "waybar" "rofi")
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

# Configure SELinux for window managers
configure_selinux() {
    log_info "Configuring SELinux for window managers..."
    
    # Check if SELinux commands are available
    if command -v getenforce &>/dev/null; then
        local selinux_state
        selinux_state="$(getenforce 2>/dev/null || echo "Unknown")"
        
        log_info "SELinux status: $selinux_state"
        
        case "$selinux_state" in
            "Enforcing")
                log_info "SELinux is in Enforcing mode - desktop should work with default policy"
                case "$SELECTED_WINDOW_MANAGER" in
                    hyprland|dwl)
                        log_info "Wayland compositors are generally compatible with SELinux"
                        ;;
                    qtile|dwm)
                        log_info "X11 window managers work well with SELinux"
                        ;;
                esac
                ;;
            "Permissive")
                log_info "SELinux is in Permissive mode - logging violations but allowing access"
                ;;
            "Disabled")
                log_info "SELinux is disabled"
                ;;
            *)
                log_warning "Unable to determine SELinux state"
                ;;
        esac
    elif command -v sestatus &>/dev/null; then
        log_info "Using sestatus for SELinux information:"
        sestatus 2>/dev/null || log_warning "Failed to get SELinux status"
    else
        log_info "SELinux tools not available - assuming disabled or not installed"
    fi
}

# Show final instructions
show_final_instructions() {
    log_success "Fedora Linux desktop setup completed!"
    echo
    log_info "Configuration Summary:"
    echo "  Distribution: Fedora Linux"
    echo "  Display Server: $SELECTED_DISPLAY_SERVER"
    echo "  Window Manager: $SELECTED_WINDOW_MANAGER"
    echo
    log_info "Next steps:"
    
    if [[ "$SELECTED_DISPLAY_SERVER" == "wayland" ]]; then
        echo "1. Reboot your system"
        echo "2. Log in to $SELECTED_WINDOW_MANAGER from GDM"
        if [[ "$SELECTED_WINDOW_MANAGER" == "hyprland" ]]; then
            echo "3. Your desktop should be themed with Catppuccin Macchiato"
            echo
            log_info "Hyprland keybindings:"
            echo "  Super + Return  : Open terminal (Alacritty)"
            echo "  Super + Space   : Application launcher (Rofi)"
            echo "  Super + E       : File manager"
            echo "  Super + Q       : Close window"
            echo "  Super + 1-9     : Switch workspaces"
        fi
    else
        echo "1. Reboot your system (or logout/login)"
        echo "2. Log in to $SELECTED_WINDOW_MANAGER from GDM"
        echo "   (or start with: startx $SELECTED_WINDOW_MANAGER)"
        
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
    log_info "Fedora-specific notes:"
    echo "  - SELinux is enabled and configured for your window manager"
    echo "  - Firewall (firewalld) is active"
    echo "  - RPM Fusion repositories are enabled for additional packages"
    echo "  - DNF automatic updates can be configured if desired"
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
    echo "Distribution: Fedora Linux"
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
    configure_selinux
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
