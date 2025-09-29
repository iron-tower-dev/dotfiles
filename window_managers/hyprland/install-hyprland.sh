#!/bin/bash

# Hyprland Installation Script
# Feature-rich Wayland compositor with animations and effects

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Detect package manager and distribution
detect_system() {
    if command -v pacman &> /dev/null; then
        DISTRO="arch"
        PKG_MANAGER="pacman"
        AUR_HELPER=""
        # Detect AUR helper
        if command -v yay &> /dev/null; then
            AUR_HELPER="yay"
        elif command -v paru &> /dev/null; then
            AUR_HELPER="paru"
        fi
    elif command -v dnf &> /dev/null; then
        DISTRO="fedora"
        PKG_MANAGER="dnf"
    elif command -v apt &> /dev/null; then
        DISTRO="debian"
        PKG_MANAGER="apt"
    elif command -v nix-env &> /dev/null; then
        DISTRO="nixos"
        PKG_MANAGER="nix"
    else
        log_error "Unsupported distribution or package manager not found"
        exit 1
    fi
    
    log_success "Detected: $DISTRO with $PKG_MANAGER"
}

# Install Hyprland and core Wayland packages
install_hyprland_arch() {
    log_info "Installing Hyprland and Wayland packages on Arch Linux..."
    
    # Core Hyprland and Wayland packages
    sudo pacman -S --needed --noconfirm \
        hyprland \
        waybar \
        rofi-wayland \
        alacritty \
        dunst \
        grim \
        slurp \
        wl-clipboard \
        xdg-desktop-portal-hyprland \
        xorg-xwayland \
        polkit-kde-agent \
        network-manager-applet \
        blueman \
        pavucontrol \
        thunar \
        thunar-archive-plugin \
        file-roller
    
    # Install additional packages if AUR helper is available
    if [[ -n "$AUR_HELPER" ]]; then
        log_info "Installing AUR packages with $AUR_HELPER..."
        $AUR_HELPER -S --needed --noconfirm \
            swww \
            hyprpicker \
            hypridle \
            hyprlock || log_warning "Some AUR packages may not be available"
    else
        log_warning "No AUR helper found. Consider installing yay or paru for additional packages."
    fi
    
    log_success "Hyprland packages installed"
}

install_hyprland_fedora() {
    log_info "Installing Hyprland and Wayland packages on Fedora..."
    
    # Enable RPM Fusion repositories
    sudo dnf install -y \
        "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
        "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm" || true
    
    # Core Hyprland and Wayland packages
    sudo dnf install -y \
        hyprland \
        waybar \
        rofi-wayland \
        alacritty \
        dunst \
        grim \
        slurp \
        wl-clipboard \
        xorg-x11-server-Xwayland \
        polkit-kde \
        NetworkManager-applet \
        blueman \
        pavucontrol \
        thunar \
        thunar-archive-plugin \
        file-roller
    
    # Try to install additional packages
    sudo dnf install -y \
        swww \
        hyprpicker || log_warning "Some packages may not be available in Fedora repos"
    
    log_success "Hyprland packages installed"
}

install_hyprland_debian() {
    log_info "Installing Hyprland and Wayland packages on Debian/Ubuntu..."
    
    # Update package lists
    sudo apt update
    
    # Core Wayland packages (Hyprland may need to be compiled or installed from backports)
    sudo apt install -y \
        waybar \
        rofi \
        alacritty \
        dunst \
        grim \
        slurp \
        wl-clipboard \
        xwayland \
        policykit-1-gnome \
        network-manager-gnome \
        blueman \
        pavucontrol \
        thunar \
        thunar-archive-plugin \
        file-roller
    
    # Try to install Hyprland (may not be available in all versions)
    sudo apt install -y hyprland || {
        log_warning "Hyprland not available in repositories. You may need to:"
        log_warning "1. Add backports repository"
        log_warning "2. Compile from source"
        log_warning "3. Use a PPA or third-party repository"
    }
    
    log_success "Available Wayland packages installed"
}

install_hyprland_nixos() {
    log_info "Installing Hyprland and Wayland packages on NixOS..."
    
    # For NixOS, we need to modify the system configuration
    log_warning "NixOS installation requires system configuration changes."
    log_info "Please add the following to your NixOS configuration:"
    
    cat << 'EOF'
# /etc/nixos/configuration.nix or equivalent
{
  programs.hyprland = {
    enable = true;
    enableNvidiaPatches = true; # if using NVIDIA
  };

  environment.systemPackages = with pkgs; [
    waybar
    rofi-wayland
    alacritty
    dunst
    grim
    slurp
    wl-clipboard
    xwayland
    polkit_gnome
    networkmanagerapplet
    blueman
    pavucontrol
    xfce.thunar
    xfce.thunar-archive-plugin
    file-roller
    swww
    hyprpicker
    hypridle
    hyprlock
  ];

  services.xserver.displayManager.gdm.wayland = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };
}
EOF
    
    log_info "After adding these options, run: sudo nixos-rebuild switch"
}

# Install fonts needed for Hyprland
install_fonts() {
    log_info "Installing fonts for Hyprland..."
    
    case "$DISTRO" in
        "arch")
            sudo pacman -S --needed --noconfirm \
                ttf-jetbrains-mono-nerd \
                ttf-fira-code \
                noto-fonts \
                noto-fonts-emoji \
                ttf-font-awesome
            ;;
        "fedora")
            sudo dnf install -y \
                jetbrains-mono-fonts \
                fira-code-fonts \
                google-noto-fonts \
                google-noto-emoji-fonts \
                fontawesome-fonts
            ;;
        "debian")
            sudo apt install -y \
                fonts-jetbrains-mono \
                fonts-firacode \
                fonts-noto \
                fonts-noto-color-emoji \
                fonts-font-awesome
            ;;
        "nixos")
            log_info "Add fonts to your NixOS configuration:"
            echo "  fonts.packages = with pkgs; [ jetbrains-mono fira-code noto-fonts noto-fonts-emoji font-awesome ];"
            ;;
    esac
    
    log_success "Fonts installed"
}

# Create Hyprland autostart script
create_autostart_script() {
    log_info "Creating Hyprland autostart script..."
    
    local hypr_dir="$HOME/.config/hypr"
    mkdir -p "$hypr_dir"
    
    local autostart_script="$hypr_dir/autostart.sh"
    
    cat > "$autostart_script" << 'EOF'
#!/bin/bash

# Hyprland autostart script

# Set wallpaper (using swww if available, fallback to swaybg or hyprpaper)
if command -v swww &> /dev/null; then
    swww init &
    swww img ~/.config/wallpapers/current.jpg &
elif command -v swaybg &> /dev/null; then
    swaybg -i ~/.config/wallpapers/current.jpg &
elif command -v hyprpaper &> /dev/null; then
    hyprpaper &
fi

# Start status bar
waybar &

# Start notification daemon
dunst &

# Start polkit authentication agent
if command -v /usr/lib/polkit-kde-authentication-agent-1 >/dev/null 2>&1; then
    /usr/lib/polkit-kde-authentication-agent-1 &
elif command -v /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 >/dev/null 2>&1; then
    /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
fi

# Start network manager applet
nm-applet --indicator &

# Start bluetooth manager
blueman-applet &

# Start idle management and screen locking
if command -v hypridle &> /dev/null; then
    hypridle &
elif command -v swayidle &> /dev/null; then
    swayidle -w \
        timeout 300 'hyprlock || swaylock -f -c 24273a' \
        timeout 600 'hyprctl dispatch dpms off' \
        resume 'hyprctl dispatch dpms on' \
        before-sleep 'hyprlock || swaylock -f -c 24273a' &
fi

# Start any other applications you want
EOF
    
    chmod +x "$autostart_script"
    log_success "Created Hyprland autostart script"
}

# Create basic Hyprland configuration if it doesn't exist
create_hyprland_config() {
    log_info "Checking Hyprland configuration..."
    
    local hypr_dir="$HOME/.config/hypr"
    local config_file="$hypr_dir/hyprland.conf"
    
    if [[ ! -f "$config_file" ]]; then
        log_info "Creating basic Hyprland configuration..."
        
        cat > "$config_file" << 'EOF'
# Hyprland configuration
# This is a basic configuration - full config will be managed by stow

# Monitor configuration
monitor=,preferred,auto,auto

# Execute at launch
exec-once = ~/.config/hypr/autostart.sh

# Environment variables
env = XCURSOR_SIZE,24
env = QT_QPA_PLATFORMTHEME,qt6ct

# Input configuration
input {
    kb_layout = us
    follow_mouse = 1
    touchpad {
        natural_scroll = true
        disable_while_typing = true
        tap-to-click = true
    }
    sensitivity = 0
}

# General settings
general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(8aadf4ee) rgba(24273aee) 45deg
    col.inactive_border = rgba(6e738daa)
    layout = dwindle
    allow_tearing = false
}

# Decoration
decoration {
    rounding = 8
    blur {
        enabled = true
        size = 3
        passes = 1
    }
    drop_shadow = true
    shadow_range = 4
    shadow_render_power = 3
    col.shadow = rgba(1a1a1aee)
}

# Animations
animations {
    enabled = true
    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = borderangle, 1, 8, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

# Layout
dwindle {
    pseudotile = true
    preserve_split = true
}

# Window rules
windowrulev2 = nomaximizerequest, class:.*

# Keybindings
$mainMod = SUPER

# Basic binds
bind = $mainMod, Return, exec, alacritty
bind = $mainMod, Q, killactive,
bind = $mainMod, M, exit,
bind = $mainMod, E, exec, thunar
bind = $mainMod, V, togglefloating,
bind = $mainMod, Space, exec, rofi -show drun
bind = $mainMod, P, pseudo,
bind = $mainMod, J, togglesplit,

# Move focus
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

# Switch workspaces
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
bind = $mainMod, 0, workspace, 10

# Move active window to workspace
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6
bind = $mainMod SHIFT, 7, movetoworkspace, 7
bind = $mainMod SHIFT, 8, movetoworkspace, 8
bind = $mainMod SHIFT, 9, movetoworkspace, 9
bind = $mainMod SHIFT, 0, movetoworkspace, 10

# Scroll through existing workspaces
bind = $mainMod, mouse_down, workspace, e+1
bind = $mainMod, mouse_up, workspace, e-1

# Move/resize windows
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow

# Screenshots
bind = $mainMod, S, exec, grim -g "$(slurp)" - | wl-copy
bind = $mainMod SHIFT, S, exec, grim - | wl-copy

# Volume controls
binde = , XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5%
binde = , XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5%
bind = , XF86AudioMute, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle

# Brightness controls
binde = , XF86MonBrightnessUp, exec, brightnessctl set +5%
binde = , XF86MonBrightnessDown, exec, brightnessctl set 5%-
EOF
        
        log_success "Created basic Hyprland configuration"
    else
        log_info "Hyprland configuration already exists, skipping..."
    fi
}

# Create Wayland session file
create_wayland_session() {
    log_info "Creating Wayland session file..."
    
    sudo mkdir -p /usr/share/wayland-sessions
    
    cat << 'EOF' | sudo tee /usr/share/wayland-sessions/hyprland.desktop > /dev/null
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=Hyprland
Type=Application
EOF
    
    log_success "Hyprland Wayland session created"
}

# Main installation function
main() {
    echo "Installing Hyprland (Dynamic tiling Wayland compositor)..."
    echo "Features: Animations, effects, modern Wayland compositor"
    echo
    
    detect_system
    
    case "$DISTRO" in
        "arch")
            install_hyprland_arch
            ;;
        "fedora")
            install_hyprland_fedora
            ;;
        "debian")
            install_hyprland_debian
            ;;
        "nixos")
            install_hyprland_nixos
            return 0  # NixOS requires manual config changes
            ;;
        *)
            log_error "Unsupported distribution: $DISTRO"
            exit 1
            ;;
    esac
    
    install_fonts
    create_autostart_script
    create_hyprland_config
    create_wayland_session
    
    log_success "Hyprland installation completed!"
    echo
    log_info "You can start Hyprland from your display manager or run 'Hyprland' in a TTY"
    echo
    log_info "Basic keybindings:"
    echo "  Super + Return       : Open terminal (Alacritty)"
    echo "  Super + Space        : Application launcher (Rofi)"
    echo "  Super + Q            : Close window"
    echo "  Super + E            : File manager (Thunar)"
    echo "  Super + 1-9          : Switch workspaces"
    echo "  Super + Shift + 1-9  : Move window to workspace"
    echo "  Super + S            : Screenshot selection"
    echo "  Super + Shift + S    : Full screenshot"
    echo "  Super + M            : Exit Hyprland"
    echo
    log_info "Configuration files:"
    echo "  Main config: ~/.config/hypr/hyprland.conf"
    echo "  Autostart: ~/.config/hypr/autostart.sh"
    echo
    log_info "The full Hyprland configuration will be deployed when you use GNU Stow:"
    echo "  stow -t ~ hyprland"
    echo
    log_info "Hyprland features modern Wayland support including:"
    echo "  - Hardware-accelerated animations and effects"
    echo "  - Advanced window management and tiling"
    echo "  - Multi-monitor support with per-monitor scaling"
    echo "  - Extensive customization options"
}

main "$@"
