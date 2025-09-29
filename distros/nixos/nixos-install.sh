#!/bin/bash

# NixOS Desktop Environment Installer with Flakes
# Modern NixOS setup with flakes, modules, and home-manager
# Support for multiple window managers: Hyprland (Wayland), Qtile (X11), DWM (X11), DWL (Wayland)

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
DOTFILES_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
NIXOS_CONFIG_DIR="$DOTFILES_DIR/nixos"

# Global variables
SELECTED_DISPLAY_SERVER=""
SELECTED_WINDOW_MANAGER=""
HOSTNAME=""
USERNAME="$USER"
USE_EXISTING_NIXOS_CONFIG=false

# Banner
display_banner() {
    cat << "EOF"
    ╔═══════════════════════════════════════════════════════════════╗
    ║                 NIXOS FLAKES INSTALLER                       ║
    ║                                                               ║
    ║       Modern NixOS with Flakes, Modules & Home Manager       ║
    ║                                                               ║
    ╚═══════════════════════════════════════════════════════════════╝
EOF
}

# Check if running on NixOS
check_system() {
    log_info "Checking system compatibility..."
    
    if [[ ! -f /etc/NIXOS ]]; then
        log_error "This script is designed for NixOS systems."
        log_info "If you're on another system, consider using the appropriate installer."
        exit 1
    fi
    
    if ! command -v nix-env &> /dev/null; then
        log_error "Nix package manager not found."
        exit 1
    fi
    
    log_success "NixOS detected"
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

# Select configuration method
select_config_method() {
    echo
    log_header "CONFIGURATION METHOD SELECTION"
    echo "1. System configuration (requires root access to modify /etc/nixos/)"
    echo "2. Home Manager configuration (user-level configuration)"
    echo
    
    while true; do
        read -p "Choose configuration method (1-2): " choice
        case $choice in
            1)
                CONFIG_TYPE="system"
                log_info "Selected: System configuration"
                break
                ;;
            2)
                CONFIG_TYPE="home-manager"
                log_info "Selected: Home Manager configuration"
                break
                ;;
            *)
                log_error "Invalid choice. Please select 1 or 2."
                ;;
        esac
    done
}

# Generate system configuration
generate_system_config() {
    log_header "GENERATING SYSTEM CONFIGURATION"
    
    local config_file="/tmp/nixos-dotfiles-config.nix"
    
    log_info "Creating system configuration template..."
    
    cat > "$config_file" << EOF
# NixOS Desktop Environment Configuration
# Generated by dotfiles installer for $SELECTED_WINDOW_MANAGER ($SELECTED_DISPLAY_SERVER)

{ config, pkgs, ... }:

{
  # Enable the X11 windowing system or Wayland
$(if [[ "$SELECTED_DISPLAY_SERVER" == "wayland" ]]; then
cat << 'WAYLAND_CONFIG'
  services.xserver = {
    enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
  };
  
  # Wayland-specific packages
  environment.systemPackages = with pkgs; [
    wayland
    wayland-protocols
    xwayland
    wl-clipboard
    grim
    slurp
WAYLAND_CONFIG
else
cat << 'X11_CONFIG'
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    
    # Enable touchpad support (enabled default in most desktopManager).
    libinput.enable = true;
  };
  
  # X11-specific packages
  environment.systemPackages = with pkgs; [
    xorg.xorgserver
    xorg.xinit
    picom
    feh
    dmenu
    xclip
    arandr
    lxappearance
X11_CONFIG
fi)
$(generate_window_manager_config)

    # Core applications and tools
    alacritty
    firefox
    git
    curl
    wget
    stow
    neovim
    fish
    zsh
    htop
    tree
    ripgrep
    fd
    bat
    eza
    fzf
    tmux
    
    # Development tools
    gcc
    cmake
    pkg-config
    
    # Fonts
    jetbrains-mono
    fira-code
    noto-fonts
    noto-fonts-emoji
    font-awesome
    
    # Theme packages
    lxappearance
    qt5ct
    libsForQt5.qtstyleplugin-kvantum
    papirus-icon-theme
    breeze-icons
  ];
  
  # Enable sound with pipewire
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  
  # Enable networking
  networking.networkmanager.enable = true;
  
  # Enable bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  
  # Configure shells
  programs.fish.enable = true;
  programs.zsh.enable = true;
  
  # Enable home-manager for user configuration
  programs.home-manager.enable = true;
  
  # Configure fonts
  fonts.packages = with pkgs; [
    jetbrains-mono
    fira-code
    noto-fonts
    noto-fonts-emoji
    font-awesome
  ];
  
  # Enable polkit for authentication
  security.polkit.enable = true;
  
  # Enable dbus
  services.dbus.enable = true;
  
  # Enable location service
  services.geoclue2.enable = true;
}
EOF
    
    log_success "System configuration generated: $config_file"
    
    echo
    log_info "To apply this configuration:"
    echo "1. Review the generated configuration: $config_file"
    echo "2. Merge it with your existing /etc/nixos/configuration.nix"
    echo "3. Run: sudo nixos-rebuild switch"
    echo
    log_warning "IMPORTANT: Back up your existing configuration before merging!"
}

# Generate window manager specific configuration
generate_window_manager_config() {
    case "$SELECTED_WINDOW_MANAGER" in
        hyprland)
            cat << 'HYPRLAND_CONFIG'
  
  # Hyprland configuration
  programs.hyprland = {
    enable = true;
    enableNvidiaPatches = true; # Enable if using NVIDIA
  };
  
  # XDG portal for Hyprland
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };
  
  # Hyprland-specific packages
    waybar
    rofi-wayland
    dunst
    hyprpicker
    hypridle
    hyprlock
    swww
    networkmanagerapplet
    blueman
    pavucontrol
    xfce.thunar
    xfce.thunar-archive-plugin
    file-roller
HYPRLAND_CONFIG
            ;;
        qtile)
            cat << 'QTILE_CONFIG'
  
  # Qtile configuration  
  services.xserver.windowManager.qtile.enable = true;
  
  # Qtile-specific packages
    python3Packages.qtile
    python3Packages.psutil
    python3Packages.dbus-python
    rofi
    dunst
    networkmanagerapplet
    blueman  
    pavucontrol
    xfce.thunar
    xfce.thunar-archive-plugin
    file-roller
    scrot
QTILE_CONFIG
            ;;
        dwm)
            cat << 'DWM_CONFIG'
  
  # DWM configuration (requires building from source)
  services.xserver.windowManager.dwm.enable = true;
  
  # DWM-specific packages
    dwm
    dmenu
    st
    rofi
    dunst
    networkmanagerapplet
    blueman
    pavucontrol
    xfce.thunar
    xfce.thunar-archive-plugin
    file-roller
    scrot
DWM_CONFIG
            ;;
        dwl)
            cat << 'DWL_CONFIG'
  
  # DWL configuration (Wayland suckless WM)
  # Note: DWL may need to be built from source or overlay
  
  # DWL-specific packages
    # dwl  # May need overlay or manual build
    foot
    wofi
    dunst
    networkmanagerapplet
    blueman
    pavucontrol
    xfce.thunar
    xfce.thunar-archive-plugin
    file-roller
    wlopm
    wbg
    brightnessctl
DWL_CONFIG
            ;;
    esac
}

# Generate home-manager configuration
generate_home_manager_config() {
    log_header "GENERATING HOME MANAGER CONFIGURATION"
    
    local home_config_file="$HOME/.config/nixpkgs/home.nix"
    local home_config_dir="$(dirname "$home_config_file")"
    
    mkdir -p "$home_config_dir"
    
    log_info "Creating home-manager configuration..."
    
    cat > "$home_config_file" << EOF
# Home Manager Configuration
# Generated by dotfiles installer for $SELECTED_WINDOW_MANAGER ($SELECTED_DISPLAY_SERVER)

{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
  
  # Home Manager needs a bit of information about you and the paths it should manage
  home.username = "$USER";
  home.homeDirectory = "$HOME";
  
  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "23.11"; # Adjust to your NixOS version
  
  # Packages to install
  home.packages = with pkgs; [
$(generate_home_manager_packages)
  ];
  
$(generate_home_manager_programs)
  
  # Git configuration
  programs.git = {
    enable = true;
    userName = "$(git config --get user.name 2>/dev/null || echo "Your Name")";
    userEmail = "$(git config --get user.email 2>/dev/null || echo "your.email@example.com")";
  };
  
  # Shell configuration
  programs.fish = {
    enable = true;
    shellAliases = {
      ll = "ls -l";
      la = "ls -la";
      grep = "rg";
      cat = "bat";
      ls = "eza";
    };
  };
  
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" "sudo" "docker" "kubectl" ];
    };
  };
  
  # Terminal configuration
  programs.alacritty = {
    enable = true;
    settings = {
      colors = {
        primary = {
          background = "#24273a";
          foreground = "#cad3f5";
        };
        cursor = {
          text = "#24273a";
          cursor = "#f4dbd6";
        };
        normal = {
          black = "#494d64";
          red = "#ed8796";
          green = "#a6da95";
          yellow = "#eed49f";
          blue = "#8aadf4";
          magenta = "#f5bde6";
          cyan = "#8bd5ca";
          white = "#b8c0e0";
        };
        bright = {
          black = "#5b6078";
          red = "#ed8796";
          green = "#a6da95";
          yellow = "#eed49f";
          blue = "#8aadf4";
          magenta = "#f5bde6";
          cyan = "#8bd5ca";
          white = "#a5adcb";
        };
      };
      font = {
        normal = {
          family = "JetBrains Mono Nerd Font";
          style = "Regular";
        };
        size = 12;
      };
    };
  };
  
  # Neovim configuration
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
}
EOF
    
    log_success "Home Manager configuration generated: $home_config_file"
    
    echo
    log_info "To apply this configuration:"
    echo "1. Review the generated configuration: $home_config_file"
    echo "2. Install home-manager if not already installed:"
    echo "   nix-channel --add https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz home-manager"
    echo "   nix-channel --update"
    echo "   nix-shell '<home-manager>' -A install"
    echo "3. Run: home-manager switch"
}

# Generate home-manager packages list
generate_home_manager_packages() {
    local packages="
    # Core applications
    firefox
    git
    curl
    wget
    stow
    htop
    tree
    ripgrep
    fd
    bat
    eza
    fzf
    tmux
    
    # Development tools
    gcc
    cmake
    pkg-config"

    if [[ "$SELECTED_DISPLAY_SERVER" == "wayland" ]]; then
        packages+="
    
    # Wayland packages
    wayland
    wayland-protocols
    wl-clipboard
    grim
    slurp"
    else
        packages+="
    
    # X11 packages
    xorg.xorgserver
    xorg.xinit
    picom
    feh
    dmenu
    xclip
    arandr
    lxappearance"
    fi

    case "$SELECTED_WINDOW_MANAGER" in
        hyprland)
            packages+="
    
    # Hyprland packages
    waybar
    rofi-wayland
    dunst
    hyprpicker
    swww"
            ;;
        qtile)
            packages+="
    
    # Qtile packages
    python3Packages.qtile
    python3Packages.psutil
    rofi
    dunst
    scrot"
            ;;
        dwm)
            packages+="
    
    # DWM packages
    dwm
    dmenu
    st
    rofi
    dunst
    scrot"
            ;;
        dwl)
            packages+="
    
    # DWL packages
    foot
    wofi
    dunst
    wlopm
    brightnessctl"
            ;;
    esac

    echo "$packages"
}

# Generate home-manager programs section
generate_home_manager_programs() {
    local programs=""

    case "$SELECTED_WINDOW_MANAGER" in
        hyprland)
            programs+="
  # Hyprland configuration
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      monitor = \",preferred,auto,auto\";
      \"exec-once\" = \"waybar & dunst\";
      \"\$mod\" = \"SUPER\";
      bind = [
        \"\$mod, Return, exec, alacritty\"
        \"\$mod, Space, exec, rofi -show drun\"
        \"\$mod, Q, killactive\"
        \"\$mod, E, exec, thunar\"
        \"\$mod, 1, workspace, 1\"
        \"\$mod, 2, workspace, 2\"
        \"\$mod, 3, workspace, 3\"
        \"\$mod, 4, workspace, 4\"
        \"\$mod, 5, workspace, 5\"
      ];
    };
  };"
            ;;
    esac

    echo "$programs"
}

# Deploy dotfiles with stow
deploy_dotfiles() {
    log_header "DEPLOYING DOTFILES"
    
    if ! command -v stow &> /dev/null; then
        log_warning "GNU Stow is not available. Installing via nix-env..."
        nix-env -iA nixpkgs.stow
    fi
    
    log_info "Deploying configuration files with GNU Stow..."
    
    # Base packages that are always deployed
    STOW_PACKAGES=(
        "alacritty"
        "fish"
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

# Show final instructions
show_final_instructions() {
    log_success "NixOS desktop setup configuration generated!"
    echo
    log_info "Configuration Summary:"
    echo "  Distribution: NixOS"
    echo "  Display Server: $SELECTED_DISPLAY_SERVER"
    echo "  Window Manager: $SELECTED_WINDOW_MANAGER"
    echo "  Configuration Type: $CONFIG_TYPE"
    echo
    
    if [[ "$CONFIG_TYPE" == "system" ]]; then
        log_info "System Configuration Next Steps:"
        echo "1. Review the generated configuration in /tmp/nixos-dotfiles-config.nix"
        echo "2. Backup your current /etc/nixos/configuration.nix:"
        echo "   sudo cp /etc/nixos/configuration.nix /etc/nixos/configuration.nix.backup"
        echo "3. Merge the generated config with your system configuration"
        echo "4. Run: sudo nixos-rebuild switch"
    else
        log_info "Home Manager Configuration Next Steps:"
        echo "1. Review the generated configuration in ~/.config/nixpkgs/home.nix"
        echo "2. Install home-manager if not already installed:"
        echo "   nix-channel --add https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz home-manager"
        echo "   nix-channel --update"
        echo "   nix-shell '<home-manager>' -A install"
        echo "3. Run: home-manager switch"
    fi
    
    echo
    log_info "After applying the configuration:"
    echo "1. Reboot your system"
    echo "2. Log in to $SELECTED_WINDOW_MANAGER from your display manager"
    echo
    log_info "NixOS-specific features:"
    echo "  - Declarative configuration management"
    echo "  - Atomic upgrades and rollbacks"
    echo "  - Reproducible system builds"
    echo "  - Nix package manager with isolated environments"
    echo
    log_info "Configuration files are managed by both Nix and GNU Stow."
    log_info "System packages via Nix, dotfiles via Stow."
    echo
    log_warning "Remember to commit your NixOS configuration to version control!"
}

# Main execution
main() {
    display_banner
    echo
    
    check_system
    
    # Interactive setup
    select_display_server
    select_window_manager
    select_config_method
    
    log_header "STARTING CONFIGURATION GENERATION"
    echo "Distribution: NixOS"
    echo "Display Server: $SELECTED_DISPLAY_SERVER"
    echo "Window Manager: $SELECTED_WINDOW_MANAGER"
    echo "Configuration Type: $CONFIG_TYPE"
    echo
    
    read -p "Continue with configuration generation? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_info "Configuration generation cancelled"
        exit 0
    fi
    
    if [[ "$CONFIG_TYPE" == "system" ]]; then
        generate_system_config
    else
        generate_home_manager_config
    fi
    
    # Deploy dotfiles regardless of config type
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
            echo "  - Configuration method (System/Home Manager)"
            echo "  - Configuration file generation"
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
