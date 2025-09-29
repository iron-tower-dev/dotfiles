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

# Configuration flags
# Set to true to enable passwordless sudo for wheel group users
# WARNING: This reduces security by allowing admin commands without password verification
# Default: false (requires password for sudo commands)
ENABLE_PASSWORDLESS_SUDO=false

# Global variables
SELECTED_DISPLAY_SERVER=""
SELECTED_WINDOW_MANAGER=""
HOSTNAME=""
USERNAME="$USER"
USER_FULL_NAME=""
USER_EMAIL=""
TIMEZONE=""

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
    
    if ! command -v nix &> /dev/null; then
        log_error "Nix package manager not found."
        exit 1
    fi
    
    # Check if flakes are enabled
    if ! nix flake --help &> /dev/null; then
        log_warning "Nix flakes not enabled. We'll enable them as part of the setup."
    fi
    
    log_success "NixOS detected"
}

# Get system information
get_system_info() {
    log_header "SYSTEM INFORMATION"
    
    # Get hostname
    if [[ -z "$HOSTNAME" ]]; then
        HOSTNAME=$(hostname)
        read -p "Hostname [$HOSTNAME]: " hostname_input
        if [[ -n "$hostname_input" ]]; then
            HOSTNAME="$hostname_input"
        fi
    fi
    
    # Get username
    read -p "Username [$USERNAME]: " username_input
    if [[ -n "$username_input" ]]; then
        USERNAME="$username_input"
    fi
    
    # Get user full name
    USER_FULL_NAME=$(getent passwd "$USERNAME" | cut -d: -f5 | cut -d, -f1 2>/dev/null || echo "")
    if [[ -z "$USER_FULL_NAME" ]]; then
        read -p "Full name: " USER_FULL_NAME
    else
        read -p "Full name [$USER_FULL_NAME]: " full_name_input
        if [[ -n "$full_name_input" ]]; then
            USER_FULL_NAME="$full_name_input"
        fi
    fi
    
    # Get email
    read -p "Email address: " USER_EMAIL
    
    # Get timezone (detect current or prompt)
    local detected_timezone
    if command -v timedatectl &> /dev/null; then
        detected_timezone=$(timedatectl show --property=Timezone --value 2>/dev/null || echo "")
    fi
    
    if [[ -n "$detected_timezone" ]]; then
        TIMEZONE="$detected_timezone"
        read -p "Timezone [$TIMEZONE]: " timezone_input
        if [[ -n "$timezone_input" ]]; then
            TIMEZONE="$timezone_input"
        fi
    else
        TIMEZONE="America/New_York"
        read -p "Timezone [$TIMEZONE]: " timezone_input
        if [[ -n "$timezone_input" ]]; then
            TIMEZONE="$timezone_input"
        fi
    fi
    
    # Ask about passwordless sudo
    echo
    log_warning "SECURITY OPTION: Sudo Configuration"
    echo "By default, sudo commands will require your password for security."
    echo "You can optionally enable passwordless sudo for convenience (less secure)."
    echo
    read -p "Enable passwordless sudo? (y/N): " passwordless_sudo_choice
    if [[ "$passwordless_sudo_choice" =~ ^[Yy]$ ]]; then
        ENABLE_PASSWORDLESS_SUDO=true
        log_warning "Passwordless sudo ENABLED - reduced security"
    else
        ENABLE_PASSWORDLESS_SUDO=false
        log_info "Passwordless sudo DISABLED - password required (secure)"
    fi
    
    log_info "System configuration:"
    log_info "  Hostname: $HOSTNAME"
    log_info "  Username: $USERNAME"
    log_info "  Full name: $USER_FULL_NAME"
    log_info "  Email: $USER_EMAIL"
    log_info "  Timezone: $TIMEZONE"
    log_info "  Passwordless sudo: $ENABLE_PASSWORDLESS_SUDO"
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

# Create the NixOS flake structure
create_nixos_flake_structure() {
    log_header "CREATING NIXOS FLAKE STRUCTURE"
    
    mkdir -p "$NIXOS_CONFIG_DIR"/{modules,hosts,users,overlays}
    mkdir -p "$NIXOS_CONFIG_DIR/modules"/{desktop,services,programs,hardware}
    mkdir -p "$NIXOS_CONFIG_DIR/hosts/$HOSTNAME"
    mkdir -p "$NIXOS_CONFIG_DIR/users/$USERNAME"
    
    log_success "Created NixOS flake directory structure"
}

# Generate the main flake.nix
generate_main_flake() {
    log_info "Generating main flake.nix..."
    
    cat > "$NIXOS_CONFIG_DIR/flake.nix" << EOF
{
  description = "NixOS configuration with flakes and home-manager";

  inputs = {
    # NixOS official package source, here using the nixos-unstable branch
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Hardware configuration
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
$(generate_flake_wm_inputs)
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, ... }@inputs: {
    nixosConfigurations = {
      $HOSTNAME = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          # Include the results of the hardware scan
          ./hosts/$HOSTNAME/hardware-configuration.nix
          
          # Main configuration
          ./hosts/$HOSTNAME/configuration.nix
          
          # Common modules
          ./modules/default.nix
          
          # Home manager
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.$USERNAME = import ./users/$USERNAME/home.nix;
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
        ];
      };
    };
    
    # Home manager configurations for standalone use
    homeConfigurations = {
      "$USERNAME" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = { inherit inputs; };
        modules = [
          ./users/$USERNAME/home.nix
        ];
      };
    };
  };
}
EOF
    
    log_success "Generated main flake.nix"
}

# Generate flake inputs for window managers
generate_flake_wm_inputs() {
    case "$SELECTED_WINDOW_MANAGER" in
        hyprland)
            cat << 'EOF'
    
    # Hyprland
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
EOF
            ;;
        *)
            echo ""
            ;;
    esac
}

# Generate host configuration
generate_host_configuration() {
    log_info "Generating host configuration for $HOSTNAME..."
    
    # Derive state versions once (fallback to a sane default if not on NixOS yet)
    STATE_VERSION="$(nixos-version 2>/dev/null | awk '{print $1}' | cut -d. -f1,2 || echo '24.05')"
    log_info "Using NixOS state version: $STATE_VERSION"
    
    cat > "$NIXOS_CONFIG_DIR/hosts/$HOSTNAME/configuration.nix" << EOF
# Host configuration for $HOSTNAME
{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/desktop
    ../../modules/services
    ../../modules/programs
  ];

  # System configuration
  networking.hostName = "$HOSTNAME";
  
  # Enable flakes and nix command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # Set your time zone
  time.timeZone = "$TIMEZONE";
  
  # Select internationalisation properties
  i18n.defaultLocale = "en_US.UTF-8";
  
  # Define a user account
  users.users.$USERNAME = {
    isNormalUser = true;
    description = "$USER_FULL_NAME";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "docker" ];
    shell = pkgs.fish;
  };
  $(if [[ "$ENABLE_PASSWORDLESS_SUDO" == "true" ]]; then
    echo "  "
    echo "  # Enable passwordless sudo for wheel group (SECURITY WARNING: Less secure)"
    echo "  security.sudo.wheelNeedsPassword = false;"
else
    echo "  "
    echo "  # Require password for sudo (secure default)"
    echo "  # security.sudo.wheelNeedsPassword = true;  # This is the default"
fi)
  
  # System packages
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    vim
    htop
    tree
    stow
  ];
  
  # Desktop environment configuration
  desktop = {
    enable = true;
    displayServer = "$SELECTED_DISPLAY_SERVER";
    windowManager = "$SELECTED_WINDOW_MANAGER";
  };
  
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  system.stateVersion = "$STATE_VERSION"; # Did you read the comment?
}
EOF
    
    # Copy existing hardware configuration if it exists
    if [[ -f /etc/nixos/hardware-configuration.nix ]]; then
        log_info "Copying existing hardware configuration..."
        cp /etc/nixos/hardware-configuration.nix "$NIXOS_CONFIG_DIR/hosts/$HOSTNAME/"
    else
        log_warning "No existing hardware configuration found. You'll need to generate one."
        cat > "$NIXOS_CONFIG_DIR/hosts/$HOSTNAME/hardware-configuration.nix" << 'EOF'
# This is a placeholder hardware configuration.
# Replace this with your actual hardware-configuration.nix
# You can generate it with: nixos-generate-config --show-hardware-config

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ];

  # PLACEHOLDER - Replace with your actual hardware configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
EOF
    fi
    
    log_success "Generated host configuration"
}

# Generate modules structure
generate_modules() {
    log_info "Generating NixOS modules..."
    
    # Main modules file
    cat > "$NIXOS_CONFIG_DIR/modules/default.nix" << 'EOF'
{ ... }:

{
  imports = [
    ./desktop
    ./services
    ./programs
    ./hardware
  ];
}
EOF

    # Desktop module
    mkdir -p "$NIXOS_CONFIG_DIR/modules/desktop"
    cat > "$NIXOS_CONFIG_DIR/modules/desktop/default.nix" << EOF
{ config, lib, pkgs, inputs, ... }:

with lib;

let
  cfg = config.desktop;
in {
  options.desktop = {
    enable = mkEnableOption "desktop environment";
    
    displayServer = mkOption {
      type = types.enum [ "wayland" "x11" ];
      default = "wayland";
      description = "Display server to use";
    };
    
    windowManager = mkOption {
      type = types.enum [ "hyprland" "qtile" "dwm" "dwl" ];
      default = "hyprland";
      description = "Window manager to use";
    };
  };
  
  config = mkIf cfg.enable {
    # Common desktop packages
    environment.systemPackages = with pkgs; [
      alacritty
      firefox
      thunar
      pavucontrol
      networkmanagerapplet
      blueman
      
      # Fonts
      jetbrains-mono
      fira-code
      noto-fonts
      noto-fonts-emoji
      font-awesome
      (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" ]; })
    ];
    
    # Font configuration
    fonts = {
      packages = with pkgs; [
        jetbrains-mono
        fira-code
        noto-fonts
        noto-fonts-emoji
        font-awesome
        (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" ]; })
      ];
      fontconfig = {
        defaultFonts = {
          serif = [ "Noto Serif" ];
          sansSerif = [ "Noto Sans" ];
          monospace = [ "JetBrains Mono" ];
        };
      };
    };
    
    # Audio
    sound.enable = true;
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    
    # Networking
    networking.networkmanager.enable = true;
    
    # Bluetooth
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
    
    # Display server and window manager specific configuration
    imports = [
      ./wayland.nix
      ./x11.nix
      ./window-managers
    ];
  };
}
EOF

    # Wayland configuration
    cat > "$NIXOS_CONFIG_DIR/modules/desktop/wayland.nix" << 'EOF'
{ config, lib, pkgs, ... }:

with lib;

{
  config = mkIf (config.desktop.enable && config.desktop.displayServer == "wayland") {
    # Wayland packages
    environment.systemPackages = with pkgs; [
      wayland
      wayland-protocols
      xwayland
      wl-clipboard
      grim
      slurp
    ];
    
    # XDG Portal
    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
    };
    
    # Enable X11 for compatibility
    services.xserver.enable = true;
    services.xserver.displayManager.gdm = {
      enable = true;
      wayland = true;
    };
  };
}
EOF

    # X11 configuration
    cat > "$NIXOS_CONFIG_DIR/modules/desktop/x11.nix" << 'EOF'
{ config, lib, pkgs, ... }:

with lib;

{
  config = mkIf (config.desktop.enable && config.desktop.displayServer == "x11") {
    # X11 packages
    environment.systemPackages = with pkgs; [
      xorg.xorgserver
      xorg.xinit
      picom
      feh
      dmenu
      xclip
      arandr
      lxappearance
    ];
    
    # X11 configuration
    services.xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      libinput.enable = true;
    };
  };
}
EOF

    # Window managers directory
    mkdir -p "$NIXOS_CONFIG_DIR/modules/desktop/window-managers"
    cat > "$NIXOS_CONFIG_DIR/modules/desktop/window-managers/default.nix" << 'EOF'
{ ... }:

{
  imports = [
    ./hyprland.nix
    ./qtile.nix
    ./dwm.nix
    ./dwl.nix
  ];
}
EOF

    # Generate window manager specific configurations
    generate_window_manager_modules
    
    # Programs module
    mkdir -p "$NIXOS_CONFIG_DIR/modules/programs"
    cat > "$NIXOS_CONFIG_DIR/modules/programs/default.nix" << 'EOF'
{ config, pkgs, ... }:

{
  # Shell programs
  programs.fish.enable = true;
  programs.zsh.enable = true;
  
  # Development tools
  programs.git.enable = true;
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
  
  # System programs
  programs.dconf.enable = true;
}
EOF

    # Services module
    mkdir -p "$NIXOS_CONFIG_DIR/modules/services"
    cat > "$NIXOS_CONFIG_DIR/modules/services/default.nix" << 'EOF'
{ config, pkgs, ... }:

{
  # SSH
  services.openssh.enable = true;
  
  # Printing
  services.printing.enable = true;
  
  # Location service
  services.geoclue2.enable = true;
  
  # Polkit
  security.polkit.enable = true;
  
  # DBus
  services.dbus.enable = true;
  
  # Flatpak support
  services.flatpak.enable = true;
}
EOF

    # Hardware module
    mkdir -p "$NIXOS_CONFIG_DIR/modules/hardware"
    cat > "$NIXOS_CONFIG_DIR/modules/hardware/default.nix" << 'EOF'
{ config, lib, pkgs, ... }:

{
  # Graphics drivers (auto-detect)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
}
EOF

    log_success "Generated NixOS modules"
}

# Generate window manager modules
generate_window_manager_modules() {
    # Hyprland module
    cat > "$NIXOS_CONFIG_DIR/modules/desktop/window-managers/hyprland.nix" << EOF
{ config, lib, pkgs, inputs, ... }:

with lib;

{
  config = mkIf (config.desktop.enable && config.desktop.windowManager == "hyprland") {
$(if [[ "$SELECTED_WINDOW_MANAGER" == "hyprland" ]]; then
cat << 'HYPRLAND_CONFIG'
    # Hyprland
    programs.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    };
    
    # Hyprland specific packages
    environment.systemPackages = with pkgs; [
      waybar
      rofi-wayland
      dunst
      swww
      hyprpicker
      hypridle
      hyprlock
    ];
    
    # XDG Portal for Hyprland
    xdg.portal = {
      extraPortals = with pkgs; [
        inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland
      ];
    };
HYPRLAND_CONFIG
else
    echo "    # Hyprland configuration (not selected)"
fi)
  };
}
EOF

    # Qtile module
    cat > "$NIXOS_CONFIG_DIR/modules/desktop/window-managers/qtile.nix" << 'EOF'
{ config, lib, pkgs, ... }:

with lib;

{
  config = mkIf (config.desktop.enable && config.desktop.windowManager == "qtile") {
    # Qtile
    services.xserver.windowManager.qtile.enable = true;
    
    # Qtile specific packages
    environment.systemPackages = with pkgs; [
      python3Packages.qtile
      python3Packages.psutil
      python3Packages.dbus-python
      rofi
      dunst
      scrot
    ];
  };
}
EOF

    # DWM module
    cat > "$NIXOS_CONFIG_DIR/modules/desktop/window-managers/dwm.nix" << 'EOF'
{ config, lib, pkgs, ... }:

with lib;

{
  config = mkIf (config.desktop.enable && config.desktop.windowManager == "dwm") {
    # DWM
    services.xserver.windowManager.dwm.enable = true;
    
    # DWM specific packages
    environment.systemPackages = with pkgs; [
      dwm
      dmenu
      st
      rofi
      dunst
      scrot
    ];
  };
}
EOF

    # DWL module
    cat > "$NIXOS_CONFIG_DIR/modules/desktop/window-managers/dwl.nix" << 'EOF'
{ config, lib, pkgs, ... }:

with lib;

{
  config = mkIf (config.desktop.enable && config.desktop.windowManager == "dwl") {
    # DWL packages (basic ones available in nixpkgs)
    environment.systemPackages = with pkgs; [
      foot
      wofi
      dunst
      brightnessctl
      # NOTE: wbg and wlopm may not be available in nixpkgs
      # Consider adding via overlays or custom derivations
      # wbg
      # wlopm
    ];
  };
}
EOF
}

# Generate user home-manager configuration
generate_user_home_config() {
    log_info "Generating home-manager configuration for user $USERNAME..."
    
    # Home Manager typically tracks NixOS release; adjust if you prefer pinning HM separately
    HM_STATE_VERSION="$(nixos-version 2>/dev/null | awk '{print $1}' | cut -d. -f1,2 || echo '24.05')"
    log_info "Using Home Manager state version: $HM_STATE_VERSION"
    
    cat > "$NIXOS_CONFIG_DIR/users/$USERNAME/home.nix" << EOF
{ config, pkgs, inputs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "$USERNAME";
  home.homeDirectory = "/home/$USERNAME";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  home.stateVersion = "$HM_STATE_VERSION";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # User packages
  home.packages = with pkgs; [
    # Development tools
    git
    curl
    wget
    tree
    htop
    ripgrep
    fd
    bat
    eza
    fzf
    tmux
    
    # Applications
    firefox
    discord
    spotify
    vlc
    gimp
    libreoffice
    
    # CLI tools
    neofetch
    btop
    
$(generate_home_wm_packages)
  ];

  # Git configuration
  programs.git = {
    enable = true;
    userName = "$USER_FULL_NAME";
    userEmail = "$USER_EMAIL";
    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
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
      cd = "z";
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

  # Starship prompt
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
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

$(generate_home_wm_config)

  # XDG configuration
  xdg = {
    enable = true;
    userDirs.enable = true;
  };
}
EOF
    
    log_success "Generated home-manager configuration"
}

# Generate home-manager window manager packages
generate_home_wm_packages() {
    case "$SELECTED_WINDOW_MANAGER" in
        hyprland)
            cat << 'EOF'
    # Hyprland specific packages
    waybar
    rofi-wayland
    dunst
    swww
    hyprpicker
EOF
            ;;
        qtile)
            cat << 'EOF'
    # Qtile specific packages
    rofi
    dunst
    scrot
EOF
            ;;
        dwm)
            cat << 'EOF'
    # DWM specific packages
    dmenu
    rofi
    dunst
    scrot
    feh
EOF
            ;;
        dwl)
            cat << 'EOF'
    # DWL specific packages (basic ones available in nixpkgs)
    foot
    wofi
    dunst
    # NOTE: wbg and wlopm may not be available in nixpkgs
    # Consider adding via overlays if needed:
    # wbg
EOF
            ;;
    esac
}

# Generate home-manager window manager configuration
generate_home_wm_config() {
    case "$SELECTED_WINDOW_MANAGER" in
        hyprland)
            cat << 'EOF'
  # Hyprland configuration
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      monitor = ",preferred,auto,auto";
      "exec-once" = [
        "waybar &"
        "dunst &"
        "swww init &"
        "swww img ~/.config/wallpapers/current.jpg &"
      ];
      "\$mod" = "SUPER";
      bind = [
        "\$mod, Return, exec, alacritty"
        "\$mod, Space, exec, rofi -show drun"
        "\$mod, Q, killactive"
        "\$mod, E, exec, thunar"
        "\$mod, V, togglefloating"
        "\$mod, F, fullscreen"
        "\$mod, 1, workspace, 1"
        "\$mod, 2, workspace, 2"
        "\$mod, 3, workspace, 3"
        "\$mod, 4, workspace, 4"
        "\$mod, 5, workspace, 5"
        "\$mod, 6, workspace, 6"
        "\$mod, 7, workspace, 7"
        "\$mod, 8, workspace, 8"
        "\$mod, 9, workspace, 9"
        "\$mod SHIFT, 1, movetoworkspace, 1"
        "\$mod SHIFT, 2, movetoworkspace, 2"
        "\$mod SHIFT, 3, movetoworkspace, 3"
        "\$mod SHIFT, 4, movetoworkspace, 4"
        "\$mod SHIFT, 5, movetoworkspace, 5"
        "\$mod SHIFT, 6, movetoworkspace, 6"
        "\$mod SHIFT, 7, movetoworkspace, 7"
        "\$mod SHIFT, 8, movetoworkspace, 8"
        "\$mod SHIFT, 9, movetoworkspace, 9"
      ];
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(8aadf4ee) rgba(24273aee) 45deg";
        "col.inactive_border" = "rgba(6e738daa)";
        layout = "dwindle";
      };
      decoration = {
        rounding = 8;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
        drop_shadow = true;
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
      };
      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };
    };
  };
EOF
            ;;
        *)
            echo ""
            ;;
    esac
}

# Deploy dotfiles with stow
deploy_dotfiles() {
    log_header "DEPLOYING DOTFILES"
    
    if ! command -v stow &> /dev/null; then
        log_info "Installing stow via nix-env..."
        # NOTE: Using nix-env for stow is non-declarative but needed for initial dotfiles deployment
        # Consider adding stow to your system packages for full declarative management
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

# Create README for the NixOS configuration
create_readme() {
    cat > "$NIXOS_CONFIG_DIR/README.md" << EOF
# NixOS Configuration

This is a modern NixOS configuration using flakes, modules, and home-manager.

## Structure

\`\`\`
nixos/
├── flake.nix                 # Main flake configuration
├── hosts/                    # Host-specific configurations
│   └── $HOSTNAME/
│       ├── configuration.nix # Host configuration
│       └── hardware-configuration.nix
├── users/                    # User configurations
│   └── $USERNAME/
│       └── home.nix         # Home-manager configuration
├── modules/                  # Reusable NixOS modules
│   ├── desktop/             # Desktop environment modules
│   ├── services/            # Service configurations
│   ├── programs/            # Program configurations
│   └── hardware/            # Hardware-specific modules
└── overlays/               # Custom package overlays
\`\`\`

## Configuration

- **Display Server**: $SELECTED_DISPLAY_SERVER
- **Window Manager**: $SELECTED_WINDOW_MANAGER
- **Hostname**: $HOSTNAME
- **User**: $USERNAME
- **Timezone**: $TIMEZONE
- **Passwordless Sudo**: $ENABLE_PASSWORDLESS_SUDO

### Security Configuration

**Sudo Password Policy**: $(if [[ "$ENABLE_PASSWORDLESS_SUDO" == "true" ]]; then
    echo "⚠️  **PASSWORDLESS SUDO ENABLED** - Admin commands do not require password verification"
    echo ""
    echo "This configuration reduces security but increases convenience. Consider:"
    echo "- Only enable on personal development machines"
    echo "- Never enable on production or shared systems"
    echo "- To disable: Edit \`hosts/$HOSTNAME/configuration.nix\` and set \`security.sudo.wheelNeedsPassword = true;\`"
else
    echo "🔒 **SECURE DEFAULT** - Sudo commands require password verification"
    echo ""
    echo "This is the recommended secure configuration. Sudo commands will prompt for your user password."
fi)

## Usage

### First-time setup
1. Enable flakes in your current NixOS configuration:
   \`\`\`bash
   echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf
   sudo systemctl restart nix-daemon
   \`\`\`

2. Copy your hardware configuration:
   \`\`\`bash
   sudo nixos-generate-config --show-hardware-config > hosts/$HOSTNAME/hardware-configuration.nix
   \`\`\`

3. Build and switch to the new configuration:
   \`\`\`bash
   sudo nixos-rebuild switch --flake .#$HOSTNAME
   \`\`\`

### Regular usage
\`\`\`bash
# Update flake inputs
nix flake update

# Rebuild system configuration
sudo nixos-rebuild switch --flake .#$HOSTNAME

# Home-manager (if using standalone)
home-manager switch --flake .#$USERNAME

# Build without switching (for testing)
nixos-rebuild build --flake .#$HOSTNAME
\`\`\`

### Adding new hosts
1. Create a new directory under \`hosts/\`
2. Copy \`configuration.nix\` and customize
3. Generate hardware configuration
4. Add to \`flake.nix\` nixosConfigurations

### Adding new users
1. Create a new directory under \`users/\`
2. Create \`home.nix\` configuration
3. Add to host configuration or flake outputs

## Modules

The configuration is organized into reusable modules:

- **desktop**: Display server and window manager configurations
- **services**: System services (SSH, printing, etc.)
- **programs**: Program configurations (shells, editors, etc.)
- **hardware**: Hardware-specific settings

Each module can be enabled/disabled and configured through options.

## Customization

- Edit \`hosts/$HOSTNAME/configuration.nix\` for system-wide changes
- Edit \`users/$USERNAME/home.nix\` for user-specific changes
- Create new modules in \`modules/\` for reusable configurations
- Add overlays in \`overlays/\` for custom packages

## Backup and Rollback

NixOS provides atomic upgrades and rollbacks:

\`\`\`bash
# List generations
nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# Delete old generations
sudo nix-collect-garbage --delete-older-than 30d
\`\`\`
EOF
}

# Show final instructions
show_final_instructions() {
    log_success "NixOS flake configuration generated!"
    echo
    log_info "Configuration Summary:"
    echo "  Distribution: NixOS (Flakes)"
    echo "  Display Server: $SELECTED_DISPLAY_SERVER"
    echo "  Window Manager: $SELECTED_WINDOW_MANAGER"
    echo "  Hostname: $HOSTNAME"
    echo "  User: $USERNAME"
    echo "  Timezone: $TIMEZONE"
    echo "  Passwordless Sudo: $ENABLE_PASSWORDLESS_SUDO"
    echo "  Configuration Path: $NIXOS_CONFIG_DIR"
    echo
    
    log_info "Next Steps:"
    echo "1. Review the generated configuration in: $NIXOS_CONFIG_DIR"
    echo
    echo "2. Enable flakes in your current NixOS configuration:"
    echo "   echo 'experimental-features = nix-command flakes' | sudo tee -a /etc/nix/nix.conf"
    echo "   sudo systemctl restart nix-daemon"
    echo
    echo "3. Update hardware configuration:"
    echo "   cd $NIXOS_CONFIG_DIR"
    echo "   sudo nixos-generate-config --show-hardware-config > hosts/$HOSTNAME/hardware-configuration.nix"
    echo
    echo "4. Build and test the configuration:"
    echo "   sudo nixos-rebuild build --flake .#$HOSTNAME"
    echo
    echo "5. If the build succeeds, switch to the new configuration:"
    echo "   sudo nixos-rebuild switch --flake .#$HOSTNAME"
    echo
    echo "6. Reboot and log in to $SELECTED_WINDOW_MANAGER"
    echo
    
    log_info "Future updates:"
    echo "  • Update flakes: nix flake update"
    echo "  • Rebuild system: sudo nixos-rebuild switch --flake .#$HOSTNAME"
    echo "  • Rollback if needed: sudo nixos-rebuild switch --rollback"
    echo
    
    log_info "NixOS Flakes Features:"
    echo "  ✅ Modern flakes-based configuration"
    echo "  ✅ Home-manager integration"
    echo "  ✅ Modular, reusable components"
    echo "  ✅ Multi-user and multi-host support"
    echo "  ✅ Atomic updates and rollbacks"
    echo "  ✅ Reproducible system builds"
    echo
    
    log_warning "Important Notes:"
    echo "  • This configuration uses unstable channel for latest packages"
    echo "  • Review all generated files before switching"
    echo "  • Keep your flake.lock in version control"
    echo "  • Test configurations with 'build' before 'switch'"
    if [[ "$ENABLE_PASSWORDLESS_SUDO" == "true" ]]; then
        echo "  ⚠️  SECURITY: Passwordless sudo enabled - review security implications"
    fi
    echo
    
    log_info "Documentation created: $NIXOS_CONFIG_DIR/README.md"
}

# Main execution
main() {
    display_banner
    echo
    
    check_system
    get_system_info
    
    # Interactive setup
    select_display_server
    select_window_manager
    
    log_header "STARTING FLAKE GENERATION"
    echo "Distribution: NixOS (Flakes)"
    echo "Display Server: $SELECTED_DISPLAY_SERVER"
    echo "Window Manager: $SELECTED_WINDOW_MANAGER"
    echo "Hostname: $HOSTNAME"
    echo "User: $USERNAME"
    echo "Configuration Path: $NIXOS_CONFIG_DIR"
    echo
    
    read -p "Continue with flake generation? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_info "Configuration generation cancelled"
        exit 0
    fi
    
    create_nixos_flake_structure
    generate_main_flake
    generate_host_configuration
    generate_modules
    generate_user_home_config
    create_readme
    
    # Deploy dotfiles
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
            echo "  - System information collection"
            echo "  - Display server selection (Wayland/X11)"
            echo "  - Window manager selection"
            echo "  - Flake configuration generation"
            echo "  - Home-manager setup"
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
