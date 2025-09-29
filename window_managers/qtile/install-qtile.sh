#!/bin/bash

# Qtile Installation Script
# Python-based tiling window manager for X11
#
# Package Availability Strategy:
# - Core packages (qtile, python-psutil, python-dbus-next) are available in most official repos
# - Optional packages (python-iwlib, python-pulsectl-asyncio) may be AUR-only on Arch
# - Fallback to UV (following dotfiles UV-first policy) when system packages unavailable
# - Optional packages won't cause installation failure - they enable additional features

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Global variables
DISTRO=""
PKG_MANAGER=""

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Detect package manager and distribution
detect_system() {
    if command -v pacman &> /dev/null; then
        DISTRO="arch"
        PKG_MANAGER="pacman"
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

# Check if AUR helper is available
check_aur_helper() {
    if command -v yay &> /dev/null; then
        echo "yay"
    elif command -v paru &> /dev/null; then
        echo "paru"
    else
        echo ""
    fi
}

# Install Python package via UV as fallback
# Args: $1 = system package name, $2 = pip package name, $3 = optional (true/false)
install_python_package_fallback() {
    local package="$1"
    local pip_name="$2"
    local optional="${3:-false}"
    
    if [[ "$optional" == "true" ]]; then
        log_info "Optional package $package not available, trying UV fallback..."
    else
        log_warning "Required package $package not available, trying UV fallback..."
    fi
    
    if command -v uv &> /dev/null; then
        log_info "Installing $pip_name via UV..."
        # Try user installation first (safer)
        if uv pip install "$pip_name" --user 2>/dev/null; then
            log_success "Successfully installed $pip_name via UV (user install)"
            return 0
        elif uv tool install "$pip_name" 2>/dev/null; then
            log_success "Successfully installed $pip_name via UV (tool install)"
            return 0
        else
            if [[ "$optional" == "true" ]]; then
                log_warning "Failed to install optional package $pip_name via UV. Qtile may have reduced functionality."
                return 0  # Don't fail for optional packages
            else
                log_error "Failed to install required package $pip_name via UV"
                return 1
            fi
        fi
    else
        if [[ "$optional" == "true" ]]; then
            log_warning "UV not available and $package is optional. Install manually if needed: pip install $pip_name"
            return 0
        else
            log_error "UV not available and $package is required. Please install UV or manually: pip install $pip_name"
            return 1
        fi
    fi
}

# Install Qtile and dependencies on Arch Linux
install_qtile_arch() {
    log_info "Installing Qtile and its dependencies on Arch Linux..."
    
    local aur_helper
    aur_helper=$(check_aur_helper)
    
    # Install core packages from official repositories
    sudo pacman -S --needed --noconfirm \
        qtile \
        python-psutil \
        python-iwlib \
        python-dbus-next
    
    # Handle python-pulsectl-asyncio with fallbacks (optional package for audio controls)
    if [[ -n "$aur_helper" ]]; then
        log_info "Installing optional AUR packages with $aur_helper..."
        if ! $aur_helper -S --needed --noconfirm python-pulsectl-asyncio 2>/dev/null; then
            log_info "python-pulsectl-asyncio not available, trying python-pulsectl..."
            if ! $aur_helper -S --needed --noconfirm python-pulsectl 2>/dev/null; then
                install_python_package_fallback "python-pulsectl-asyncio" "pulsectl-asyncio" "true"
            fi
        fi
    else
        log_info "No AUR helper found (yay/paru). Attempting UV fallback for optional python-pulsectl-asyncio..."
        install_python_package_fallback "python-pulsectl-asyncio" "pulsectl-asyncio" "true"
    fi
    
    log_success "Qtile core packages installed successfully"
}

# Install Qtile and dependencies on Fedora
install_qtile_fedora() {
    log_info "Installing Qtile and its dependencies on Fedora..."
    
    # Install core packages from official repositories
    sudo dnf install -y \
        qtile \
        python3-psutil \
        python3-dbus-next
    
    # Try optional packages with fallbacks (these enable additional features)
    if ! sudo dnf install -y python3-iwlib 2>/dev/null; then
        log_info "python3-iwlib not available in Fedora repos (enables network widgets)"
        install_python_package_fallback "python3-iwlib" "iwlib" "true"
    fi
    
    if ! sudo dnf install -y python3-pulsectl 2>/dev/null; then
        log_info "python3-pulsectl not available in Fedora repos (enables audio controls)"
        install_python_package_fallback "python3-pulsectl" "pulsectl" "true"
    fi
    
    log_success "Qtile core packages installed successfully"
}

# Install Qtile and dependencies on Debian/Ubuntu
install_qtile_debian() {
    log_info "Installing Qtile and its dependencies on Debian/Ubuntu..."
    
    # Update package lists
    sudo apt update
    
    # Install core packages from official repositories
    # First, install qtile and python3-psutil which should be available everywhere
    sudo apt install -y \
        qtile \
        python3-psutil
    
    # Try python3-dbus-next first (preferred), fallback to python3-dbus-dev
    if ! sudo apt install -y python3-dbus-next 2>/dev/null; then
        log_info "python3-dbus-next not available, trying python3-dbus-dev..."
        if ! sudo apt install -y python3-dbus-dev 2>/dev/null; then
            log_error "Both python3-dbus-next and python3-dbus-dev failed to install"
            install_python_package_fallback "python3-dbus-next" "dbus-next" "false"
        else
            log_success "Installed python3-dbus-dev as fallback"
        fi
    else
        log_success "Installed python3-dbus-next successfully"
    fi
    
    # Try optional packages with fallbacks (these enable additional features)
    if ! sudo apt install -y python3-iwlib 2>/dev/null; then
        log_info "python3-iwlib not available in Debian/Ubuntu repos (enables network widgets)"
        install_python_package_fallback "python3-iwlib" "iwlib" "true"
    fi
    
    if ! sudo apt install -y python3-pulsectl 2>/dev/null; then
        log_info "python3-pulsectl not available in Debian/Ubuntu repos (enables audio controls)"
        install_python_package_fallback "python3-pulsectl" "pulsectl" "true"
    fi
    
    log_success "Qtile core packages installed successfully"
}

# Generate NixOS configuration with Home Manager integration
generate_nixos_config_with_home_manager() {
    log_info "Generating NixOS configuration with Home Manager integration..."
    
    local config_file="$HOME/nixos-qtile-config.nix"
    
    cat > "$config_file" << 'EOF'
# NixOS Configuration for Qtile with Home Manager
# Generated by qtile installer
# Copy relevant sections to your /etc/nixos/configuration.nix

let
  # Import Home Manager NixOS module
  home-manager = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/master.tar.gz";
  };
in
{
  imports = [
    (import "${home-manager}/nixos")
    # Your hardware configuration
    # ./hardware-configuration.nix
  ];

  # Enable X11 and Qtile window manager
  services.xserver = {
    enable = true;
    windowManager.qtile.enable = true;
    displayManager.defaultSession = "none+qtile";
  };

  # System packages for Qtile
  environment.systemPackages = with pkgs; [
    python3Packages.qtile
    python3Packages.psutil
    python3Packages.iwlib
    python3Packages.dbus-python
    python3Packages.pulsectl
    alacritty
    rofi
    feh
    picom
    scrot
    networkmanagerapplet
    blueman
    pavucontrol
    dunst
    # Fonts for Qtile
    jetbrains-mono
    fira-code
    noto-fonts
    noto-fonts-emoji
  ];

  # Home Manager configuration
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  
  # IMPORTANT: Uncomment and customize the following for your user(s)
  # Replace "username" with your actual username
  # home-manager.users.username = { pkgs, ... }: {
  #   home.stateVersion = "24.05"; # Match your NixOS version
  #   
  #   # Qtile configuration via Home Manager
  #   xdg.configFile."qtile/config.py".source = ./qtile/config.py;
  #   xdg.configFile."qtile/autostart.sh" = {
  #     source = ./qtile/autostart.sh;
  #     executable = true;
  #   };
  #   
  #   # User packages specific to Qtile
  #   home.packages = with pkgs; [
  #     # Add any user-specific packages here
  #   ];
  # };
}
EOF
    
    log_success "NixOS configuration generated at: $config_file"
    log_info "Instructions:"
    log_info "1. Copy the relevant sections from $config_file to your /etc/nixos/configuration.nix"
    log_info "2. Uncomment and customize the home-manager.users.<username> section"
    log_info "3. Replace 'username' with your actual username"
    log_info "4. Adjust the home.stateVersion to match your NixOS version"
    log_info "5. Run: sudo nixos-rebuild switch"
}

# Install Qtile and dependencies on NixOS
install_qtile_nixos() {
    log_info "Installing Qtile and its dependencies on NixOS..."
    
    # Generate NixOS configuration with Home Manager
    generate_nixos_config_with_home_manager
    
    log_warning "NixOS installation requires system configuration changes."
    log_info "A complete NixOS configuration has been generated for you."
}

# Install Qtile based on detected distribution
install_qtile() {
    case "$DISTRO" in
        arch)
            install_qtile_arch
            ;;
        fedora)
            install_qtile_fedora
            ;;
        debian)
            install_qtile_debian
            ;;
        nixos)
            install_qtile_nixos
            return
            ;;
        *)
            log_error "Unsupported distribution: $DISTRO"
            exit 1
            ;;
    esac
}

# Install additional X11 tools for Qtile on Arch Linux
install_x11_tools_arch() {
    log_info "Installing additional X11 tools for Qtile on Arch Linux..."
    
    sudo pacman -S --needed --noconfirm \
        alacritty \
        rofi \
        feh \
        picom \
        scrot \
        network-manager-applet \
        blueman \
        pavucontrol \
        dunst
    
    log_success "X11 tools installed"
}

# Install additional X11 tools for Qtile on Fedora
install_x11_tools_fedora() {
    log_info "Installing additional X11 tools for Qtile on Fedora..."
    
    sudo dnf install -y \
        alacritty \
        rofi \
        feh \
        picom \
        scrot \
        NetworkManager-applet \
        blueman \
        pavucontrol \
        dunst
    
    log_success "X11 tools installed"
}

# Install additional X11 tools for Qtile on Debian/Ubuntu
install_x11_tools_debian() {
    log_info "Installing additional X11 tools for Qtile on Debian/Ubuntu..."
    
    sudo apt install -y \
        alacritty \
        rofi \
        feh \
        picom \
        scrot \
        network-manager-gnome \
        blueman \
        pavucontrol \
        dunst
    
    log_success "X11 tools installed"
}

# Install X11 tools based on detected distribution
install_x11_tools() {
    case "$DISTRO" in
        arch)
            install_x11_tools_arch
            ;;
        fedora)
            install_x11_tools_fedora
            ;;
        debian)
            install_x11_tools_debian
            ;;
        nixos)
            log_info "X11 tools are included in NixOS configuration above"
            ;;
        *)
            log_error "Unsupported distribution: $DISTRO"
            exit 1
            ;;
    esac
}

# Install fonts needed for Qtile on Arch Linux
install_fonts_arch() {
    log_info "Installing fonts for Qtile on Arch Linux..."
    
    sudo pacman -S --needed --noconfirm \
        ttf-jetbrains-mono-nerd \
        ttf-fira-code \
        noto-fonts \
        noto-fonts-emoji
    
    log_success "Fonts installed"
}

# Install fonts needed for Qtile on Fedora
install_fonts_fedora() {
    log_info "Installing fonts for Qtile on Fedora..."
    
    sudo dnf install -y \
        jetbrains-mono-fonts \
        fira-code-fonts \
        google-noto-fonts-common \
        google-noto-emoji-fonts
    
    log_success "Fonts installed"
}

# Install fonts needed for Qtile on Debian/Ubuntu
install_fonts_debian() {
    log_info "Installing fonts for Qtile on Debian/Ubuntu..."
    
    sudo apt install -y \
        fonts-jetbrains-mono \
        fonts-firacode \
        fonts-noto \
        fonts-noto-color-emoji
    
    log_success "Fonts installed"
}

# Install fonts based on detected distribution
install_fonts() {
    case "$DISTRO" in
        arch)
            install_fonts_arch
            ;;
        fedora)
            install_fonts_fedora
            ;;
        debian)
            install_fonts_debian
            ;;
        nixos)
            log_info "Fonts are included in NixOS configuration above"
            ;;
        *)
            log_error "Unsupported distribution: $DISTRO"
            exit 1
            ;;
    esac
}

# Create basic Qtile configuration
create_qtile_config() {
    log_info "Creating basic Qtile configuration..."
    
    local qtile_dir="$HOME/.config/qtile"
    mkdir -p "$qtile_dir"
    
    # Create basic config.py if it doesn't exist
    if [[ ! -f "$qtile_dir/config.py" ]]; then
        cat > "$qtile_dir/config.py" << 'EOF'
from libqtile import bar, layout, widget, hook
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
import os
import subprocess

# Mod key (Mod4 = Super/Windows key)
mod = "mod4"
terminal = guess_terminal()

# Key bindings
keys = [
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),
    
    # Move windows between left/right columns or move up/down in current stack
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    
    # Grow windows
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    
    # Toggle between split and unsplit sides of stack
    Key([mod, "shift"], "Return", lazy.layout.toggle_split(), desc="Toggle between split and unsplit sides of stack"),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    
    # Toggle between different layouts
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "w", lazy.window.kill(), desc="Kill focused window"),
    
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    
    # Application launcher
    Key([mod], "r", lazy.spawn("rofi -show drun"), desc="Spawn a command using rofi"),
    
    # Volume controls
    Key([], "XF86AudioRaiseVolume", lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%")),
    Key([], "XF86AudioLowerVolume", lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%")),
    Key([], "XF86AudioMute", lazy.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")),
    
    # Screenshot
    Key([mod], "s", lazy.spawn("scrot -s"), desc="Take a screenshot"),
]

# Groups (workspaces)
groups = [Group(i) for i in "123456789"]

for i in groups:
    keys.extend([
        # mod1 + letter of group = switch to group
        Key([mod], i.name, lazy.group[i.name].toscreen(), desc="Switch to group {}".format(i.name)),
        # mod1 + shift + letter of group = switch to & move focused window to group
        Key([mod, "shift"], i.name, lazy.window.togroup(i.name, switch_group=True), desc="Switch to & move focused window to group {}".format(i.name)),
    ])

# Layouts
layouts = [
    layout.Columns(border_focus_stack=["#d75f5f", "#8f3d3d"], border_width=4),
    layout.Max(),
    layout.Stack(num_stacks=2),
    layout.Bsp(),
    layout.Matrix(),
    layout.MonadTall(),
    layout.MonadWide(),
    layout.RatioTile(),
    layout.Tile(),
    layout.TreeTab(),
    layout.VerticalTile(),
    layout.Zoomy(),
]

# Widget defaults
widget_defaults = dict(
    font="JetBrains Mono Nerd Font",
    fontsize=12,
    padding=3,
)
extension_defaults = widget_defaults.copy()

# Catppuccin Macchiato colors
colors = {
    'bg': '#24273a',
    'fg': '#cad3f5',
    'surface0': '#363a4f',
    'surface1': '#494d64',
    'surface2': '#5b6078',
    'overlay0': '#6e738d',
    'overlay1': '#8087a2',
    'overlay2': '#939ab7',
    'subtext0': '#a5adcb',
    'subtext1': '#b8c0e0',
    'text': '#cad3f5',
    'lavender': '#b7bdf8',
    'blue': '#8aadf4',
    'sapphire': '#7dc4e4',
    'sky': '#91d7e3',
    'teal': '#8bd5ca',
    'green': '#a6da95',
    'yellow': '#eed49f',
    'peach': '#f5a97f',
    'maroon': '#ee99a0',
    'red': '#ed8796',
    'mauve': '#c6a0f6',
    'pink': '#f5bde6',
    'flamingo': '#f0c6c6',
    'rosewater': '#f4dbd6',
}

# Bar
screens = [
    Screen(
        top=bar.Bar(
            [
                widget.CurrentLayout(foreground=colors['blue']),
                widget.GroupBox(
                    active=colors['blue'],
                    inactive=colors['overlay0'],
                    highlight_method='line',
                    highlight_color=[colors['bg'], colors['bg']],
                    this_current_screen_border=colors['blue'],
                ),
                widget.Prompt(),
                widget.WindowName(foreground=colors['text']),
                widget.Chord(
                    chords_colors={
                        "launch": (colors['red'], colors['fg']),
                    },
                    name_transform=lambda name: name.upper(),
                ),
                widget.Systray(),
                widget.Clock(
                    format="%Y-%m-%d %a %I:%M %p",
                    foreground=colors['green']
                ),
                widget.QuickExit(
                    default_text="⏻",
                    countdown_format="{}",
                    foreground=colors['red']
                ),
            ],
            24,
            background=colors['bg'],
            border_width=[0, 0, 2, 0],
            border_color=colors['blue'],
        ),
    ),
]

# Drag floating layouts
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),
        Match(wm_class="makebranch"),
        Match(wm_class="maketag"),
        Match(wm_class="ssh-askpass"),
        Match(title="branchdialog"),
        Match(title="pinentry"),
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True
auto_minimize = True
wmname = "LG3D"

# Autostart hook
@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser('~')
    subprocess.Popen([home + '/.config/qtile/autostart.sh'])
EOF
        
        log_success "Created basic Qtile configuration"
    else
        log_info "Qtile configuration already exists, skipping..."
    fi
}

# Create autostart script
create_autostart_script() {
    log_info "Creating autostart script..."
    
    local qtile_dir="$HOME/.config/qtile"
    local autostart_script="$qtile_dir/autostart.sh"
    
    cat > "$autostart_script" << 'EOF'
#!/bin/bash

# Qtile autostart script

# Set wallpaper
feh --bg-scale ~/.config/wallpapers/current.jpg &

# Start compositor
picom -b &

# Start notification daemon
dunst &

# Start network manager applet
nm-applet &

# Start bluetooth manager
blueman-applet &

# Set keyboard layout (uncomment and modify as needed)
# setxkbmap us &

# Start any other applications you want
EOF
    
    chmod +x "$autostart_script"
    log_success "Created autostart script"
}

# Create .xinitrc for startx qtile
create_xinitrc() {
    log_info "Creating .xinitrc for startx support..."
    
    local xinitrc="$HOME/.xinitrc"
    
    # Backup existing .xinitrc if present
    if [[ -f "$xinitrc" ]]; then
        local backup_xinitrc="$xinitrc.backup.$(date +%Y%m%d-%H%M%S)"
        cp "$xinitrc" "$backup_xinitrc"
        log_info "Backed up existing .xinitrc to $backup_xinitrc"
    fi
    
    # Create minimal .xinitrc for Qtile
    cat > "$xinitrc" << 'EOF'
#!/bin/sh

# .xinitrc - X11 startup script for Qtile

# Source system-wide xinitrc scripts
if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

# Set environment variables
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
export XDG_CURRENT_DESKTOP=qtile
export XDG_SESSION_DESKTOP=qtile

# Start Qtile window manager
exec qtile start
EOF
    
    # Set proper permissions (user read/write only)
    chmod 600 "$xinitrc"
    
    # Ensure ownership is correct
    chown "$USER:$(id -gn)" "$xinitrc" 2>/dev/null || true
    
    if [[ -f "$xinitrc" && -r "$xinitrc" ]]; then
        log_success "Created .xinitrc at $xinitrc"
        return 0
    else
        log_error "Failed to create .xinitrc"
        return 1
    fi
}

main() {
    echo "Installing Qtile (Python-based tiling window manager)..."
    echo
    
    # Initialize variables
    local XINITRC_CREATED=false
    
    detect_system
    install_qtile
    
    # Skip additional tools installation for NixOS as it requires configuration changes
    if [[ "$DISTRO" != "nixos" ]]; then
        install_x11_tools
        install_fonts
        create_qtile_config
        create_autostart_script
        
        # Create .xinitrc for startx support
        if create_xinitrc; then
            XINITRC_CREATED=true
        else
            XINITRC_CREATED=false
        fi
    fi
    
    log_success "Qtile installation completed!"
    echo
    
    # Dependency summary
    log_info "Package Installation Summary:"
    echo "  ✅ Core packages: qtile, python-psutil, python-dbus-next"
    echo "  ℹ️  Optional packages: python-iwlib (network widgets), python-pulsectl (audio controls)"
    echo "  📦 Package sources: Official repos + AUR/UV fallbacks as needed"
    echo
    
    # Show appropriate startup instructions
    if [[ "$DISTRO" != "nixos" ]]; then
        if [[ "$XINITRC_CREATED" == "true" ]]; then
            log_info "You can start Qtile with: startx"
            log_info "(.xinitrc created at $HOME/.xinitrc)"
        else
            log_warning "startx may not work properly - .xinitrc creation failed"
        fi
        log_info "Or from your display manager by selecting Qtile"
    else
        log_info "Configure NixOS as shown above, then start Qtile from your display manager"
    fi
    echo
    log_info "Basic keybindings:"
    echo "  Super + Return     : Open terminal"
    echo "  Super + r          : Application launcher (rofi)"
    echo "  Super + w          : Close window"
    echo "  Super + h/j/k/l    : Navigate windows"
    echo "  Super + 1-9        : Switch workspaces"
    echo "  Super + Shift + 1-9: Move window to workspace"
}

main "$@"
