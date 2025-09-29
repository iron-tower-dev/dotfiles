#!/bin/bash

# Qtile Installation Script
# Python-based tiling window manager for X11

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

# Install Qtile and dependencies
install_qtile() {
    log_info "Installing Qtile and its dependencies..."
    
    # Install from official repositories
    sudo pacman -S --needed --noconfirm \
        qtile \
        python-psutil \
        python-iwlib \
        python-dbus-next \
        python-pulsectl-asyncio
    
    log_success "Qtile installed successfully"
}

# Install additional X11 tools for Qtile
install_x11_tools() {
    log_info "Installing additional X11 tools for Qtile..."
    
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

# Install fonts needed for Qtile
install_fonts() {
    log_info "Installing fonts for Qtile..."
    
    sudo pacman -S --needed --noconfirm \
        ttf-jetbrains-mono-nerd \
        ttf-fira-code \
        noto-fonts \
        noto-fonts-emoji
    
    log_success "Fonts installed"
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

main() {
    echo "Installing Qtile (Python-based tiling window manager)..."
    echo
    
    install_qtile
    install_x11_tools
    install_fonts
    create_qtile_config
    create_autostart_script
    
    log_success "Qtile installation completed!"
    log_info "You can start Qtile with: startx qtile"
    log_info "Or from your display manager by selecting Qtile"
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
