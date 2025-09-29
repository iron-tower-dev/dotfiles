#!/bin/bash

# DWL Installation Script
# DWL is the Wayland equivalent of DWM - suckless dynamic window manager for Wayland

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

# Build directory
BUILD_DIR="$HOME/.local/src"
DWL_DIR="$BUILD_DIR/dwl"

# Install build dependencies
install_build_deps() {
    log_info "Installing build dependencies for DWL..."
    
    sudo pacman -S --needed --noconfirm \
        base-devel \
        git \
        wayland \
        wayland-protocols \
        wlroots \
        libxkbcommon \
        pixman \
        libdrm \
        libxkbcommon \
        xorg-xwayland \
        pkgconf \
        scdoc
    
    log_success "Build dependencies installed"
}

# Install Wayland tools
install_wayland_tools() {
    log_info "Installing Wayland tools and utilities..."
    
    sudo pacman -S --needed --noconfirm \
        alacritty \
        foot \
        wofi \
        grim \
        slurp \
        wl-clipboard \
        swaylock \
        swayidle \
        mako \
        waybar \
        wdisplays \
        kanshi \
        wtype
    
    log_success "Wayland tools installed"
}

# Clone and build DWL
build_dwl() {
    log_info "Building DWL from source..."
    
    mkdir -p "$BUILD_DIR"
    
    if [[ -d "$DWL_DIR" ]]; then
        log_info "DWL source already exists, updating..."
        cd "$DWL_DIR"
        git pull
    else
        log_info "Cloning DWL source..."
        cd "$BUILD_DIR"
        git clone https://github.com/djpohly/dwl.git
        cd "$DWL_DIR"
    fi
    
    # Apply configuration
    create_dwl_config
    
    # Build and install
    make clean
    make
    sudo make install
    
    log_success "DWL built and installed"
}

# Create DWL configuration
create_dwl_config() {
    log_info "Creating DWL configuration..."
    
    # Backup original config if it exists
    [[ -f config.h ]] && cp config.h config.h.backup
    
    # Create our customized config.h
    cat > config.h << 'EOF'
/* Taken from https://github.com/djpohly/dwl/blob/main/config.def.h */
#define COLOR(hex)    { ((hex >> 24) & 0xFF) / 255.0f, \
                        ((hex >> 16) & 0xFF) / 255.0f, \
                        ((hex >> 8) & 0xFF) / 255.0f, \
                        (hex & 0xFF) / 255.0f }

/* appearance */
static const int sloppyfocus               = 1;  /* focus follows mouse */
static const int bypass_surface_visibility = 0;  /* 1 means idle inhibitors will disable idle tracking even if it's surface isn't visible  */
static const unsigned int borderpx         = 2;  /* border pixel of windows */
static const float rootcolor[]             = COLOR(0x24273aff); /* Catppuccin Macchiato base */
static const float bordercolor[]           = COLOR(0x6e738dff); /* Catppuccin Macchiato overlay0 */
static const float focuscolor[]            = COLOR(0x8aadf4ff); /* Catppuccin Macchiato blue */
static const float urgentcolor[]           = COLOR(0xed8796ff); /* Catppuccin Macchiato red */
/* To conform the xdg-protocol, set the alpha to zero to restore the old behavior */
static const float fullscreen_bg[]        = COLOR(0x24273aff); /* Catppuccin Macchiato base */

/* logging */
static int log_level = WLR_ERROR;

/* Autostart */
static const char *const autostart[] = {
        "waybar", NULL,
        "mako", NULL,
        "wbg", "~/.config/wallpapers/current.jpg", NULL,
        NULL /* terminate */
};

/* tagging - TAGCOUNT must be no greater than 31 */
#define TAGCOUNT (9)

/* keyboard */
static const struct xkb_rule_names xkb_rules = {
	/* can specify fields: rules, model, layout, variant, options */
	/* example:
	.rules = "evdev",
	.model = "pc104",
	.layout = "us,se",
	.variant = ",dvorak",
	.options = "grp:menu_toggle",
	*/
	.layout = "us",
	.options = NULL,
};

static const int repeat_rate = 25;
static const int repeat_delay = 600;

/* Trackpad */
static const int tap_to_click = 1;
static const int tap_and_drag = 1;
static const int drag_lock = 1;
static const int natural_scrolling = 0;
static const int disable_while_typing = 1;
static const int left_handed = 0;
static const int middle_button_emulation = 0;
/* You can choose between:
LIBINPUT_CONFIG_SCROLL_NO_SCROLL, LIBINPUT_CONFIG_SCROLL_2FG,
LIBINPUT_CONFIG_SCROLL_EDGE, LIBINPUT_CONFIG_SCROLL_ON_BUTTON_DOWN
*/
static const enum libinput_config_scroll_method scroll_method = LIBINPUT_CONFIG_SCROLL_2FG;

/* You can choose between:
LIBINPUT_CONFIG_CLICK_METHOD_NONE, LIBINPUT_CONFIG_CLICK_METHOD_BUTTON_AREAS,
LIBINPUT_CONFIG_CLICK_METHOD_CLICKFINGER
*/
static const enum libinput_config_click_method click_method = LIBINPUT_CONFIG_CLICK_METHOD_BUTTON_AREAS;

/* You can choose between:
LIBINPUT_CONFIG_SEND_EVENTS_ENABLED, LIBINPUT_CONFIG_SEND_EVENTS_DISABLED,
LIBINPUT_CONFIG_SEND_EVENTS_DISABLED_ON_EXTERNAL_MOUSE
*/
static const uint32_t send_events_mode = LIBINPUT_CONFIG_SEND_EVENTS_ENABLED;

/* You can choose between:
LIBINPUT_CONFIG_ACCEL_PROFILE_FLAT, LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE
*/
static const enum libinput_config_accel_profile accel_profile = LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE;
static const double accel_speed = 0.0;
/* You can choose between:
LIBINPUT_CONFIG_TAP_MAP_LRM -- 1/2/3 finger tap maps to left/right/middle
LIBINPUT_CONFIG_TAP_MAP_LMR -- 1/2/3 finger tap maps to left/middle/right
*/
static const enum libinput_config_tap_button_map button_map = LIBINPUT_CONFIG_TAP_MAP_LRM;

/* If you want to use the windows key for MODKEY, use WLR_MODIFIER_LOGO */
#define MODKEY WLR_MODIFIER_ALT

#define TAGKEYS(KEY,SKEY,TAG) \
	{ MODKEY,                    KEY,            view,            {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_CTRL,  KEY,            toggleview,      {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_SHIFT, SKEY,           tag,             {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_CTRL|WLR_MODIFIER_SHIFT,SKEY,toggletag, {.ui = 1 << TAG} }

/* helper for spawning shell commands in the pre dwl-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static const char *termcmd[] = { "alacritty", NULL };
static const char *menucmd[] = { "wofi", "--show", "drun", NULL };

/* volume and brightness commands */
static const char *upvol[]   = { "pactl", "set-sink-volume", "@DEFAULT_SINK@", "+5%",     NULL };
static const char *downvol[] = { "pactl", "set-sink-volume", "@DEFAULT_SINK@", "-5%",     NULL };
static const char *mutevol[] = { "pactl", "set-sink-mute",   "@DEFAULT_SINK@", "toggle",  NULL };
static const char *upbright[] = { "brightnessctl", "set", "5%+", NULL };
static const char *downbright[] = { "brightnessctl", "set", "5%-", NULL };

/* screenshot commands */
static const char *screenshot[] = { "grim", NULL };
static const char *screenshot_select[] = { "sh", "-c", "grim -g \"$(slurp)\"", NULL };

static const Key keys[] = {
	/* Note that Shift changes certain key codes: c -> C, 2 -> at, etc. */
	/* modifier                  key                 function        argument */
	{ MODKEY,                    XKB_KEY_p,          spawn,          {.v = menucmd} },
	{ MODKEY,                    XKB_KEY_Return,     spawn,          {.v = termcmd} },
	{ MODKEY,                    XKB_KEY_j,          focusstack,     {.i = +1} },
	{ MODKEY,                    XKB_KEY_k,          focusstack,     {.i = -1} },
	{ MODKEY,                    XKB_KEY_i,          incnmaster,     {.i = +1} },
	{ MODKEY,                    XKB_KEY_d,          incnmaster,     {.i = -1} },
	{ MODKEY,                    XKB_KEY_h,          setmfact,       {.f = -0.05} },
	{ MODKEY,                    XKB_KEY_l,          setmfact,       {.f = +0.05} },
	{ MODKEY,                    XKB_KEY_Tab,        view,           {0} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_C,          killclient,     {0} },
	{ MODKEY,                    XKB_KEY_t,          setlayout,      {.v = &layouts[0]} },
	{ MODKEY,                    XKB_KEY_f,          setlayout,      {.v = &layouts[1]} },
	{ MODKEY,                    XKB_KEY_m,          setlayout,      {.v = &layouts[2]} },
	{ MODKEY,                    XKB_KEY_space,      setlayout,      {0} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_space,      togglefloating, {0} },
	{ MODKEY,                    XKB_KEY_e,         togglefullscreen, {0} },
	{ MODKEY,                    XKB_KEY_0,          view,           {.ui = ~0} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_parenright, tag,            {.ui = ~0} },
	{ MODKEY,                    XKB_KEY_comma,      focusmon,       {.i = WLR_DIRECTION_LEFT} },
	{ MODKEY,                    XKB_KEY_period,     focusmon,       {.i = WLR_DIRECTION_RIGHT} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_less,       tagmon,         {.i = WLR_DIRECTION_LEFT} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_greater,    tagmon,         {.i = WLR_DIRECTION_RIGHT} },
	
	/* Volume and brightness controls */
	{ 0,                         XKB_KEY_XF86AudioRaiseVolume, spawn, {.v = upvol} },
	{ 0,                         XKB_KEY_XF86AudioLowerVolume, spawn, {.v = downvol} },
	{ 0,                         XKB_KEY_XF86AudioMute,        spawn, {.v = mutevol} },
	{ 0,                         XKB_KEY_XF86MonBrightnessUp,  spawn, {.v = upbright} },
	{ 0,                         XKB_KEY_XF86MonBrightnessDown,spawn, {.v = downbright} },
	
	/* Screenshots */
	{ MODKEY,                    XKB_KEY_s,          spawn,          {.v = screenshot_select} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_S,          spawn,          {.v = screenshot} },

	TAGKEYS(          XKB_KEY_1, XKB_KEY_exclam,                     0),
	TAGKEYS(          XKB_KEY_2, XKB_KEY_at,                        1),
	TAGKEYS(          XKB_KEY_3, XKB_KEY_numbersign,                2),
	TAGKEYS(          XKB_KEY_4, XKB_KEY_dollar,                    3),
	TAGKEYS(          XKB_KEY_5, XKB_KEY_percent,                   4),
	TAGKEYS(          XKB_KEY_6, XKB_KEY_asciicircum,               5),
	TAGKEYS(          XKB_KEY_7, XKB_KEY_ampersand,                 6),
	TAGKEYS(          XKB_KEY_8, XKB_KEY_asterisk,                  7),
	TAGKEYS(          XKB_KEY_9, XKB_KEY_parenleft,                 8),
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Q,          quit,           {0} },

	/* Ctrl-Alt-Backspace and Ctrl-Alt-Fx used to be handled by X server */
	{ WLR_MODIFIER_CTRL|WLR_MODIFIER_ALT,XKB_KEY_Terminate_Server, quit, {0} },
#define CHVT(n) { WLR_MODIFIER_CTRL|WLR_MODIFIER_ALT,XKB_KEY_XF86Switch_VT_##n, chvt, {.ui = (n)} }
	CHVT(1), CHVT(2), CHVT(3), CHVT(4), CHVT(5), CHVT(6),
	CHVT(7), CHVT(8), CHVT(9), CHVT(10), CHVT(11), CHVT(12),
};

static const Button buttons[] = {
	{ MODKEY, BTN_LEFT,   moveresize,     {.ui = CurMove} },
	{ MODKEY, BTN_MIDDLE, togglefloating, {0} },
	{ MODKEY, BTN_RIGHT,  moveresize,     {.ui = CurResize} },
};

static const Listener listeners[] = {
	{ "wl_keyboard", "key", keypress, NULL },
};
EOF

    log_success "DWL configuration created"
}

# Create DWL autostart script
create_autostart_script() {
    log_info "Creating DWL autostart script..."
    
    local dwl_dir="$HOME/.config/dwl"
    mkdir -p "$dwl_dir"
    
    local autostart_script="$dwl_dir/autostart.sh"
    
    cat > "$autostart_script" << 'EOF'
#!/bin/bash

# DWL autostart script

# Set wallpaper background
wbg ~/.config/wallpapers/current.jpg &

# Start notification daemon
mako &

# Start status bar
waybar &

# Start idle management
swayidle -w \
    timeout 300 'swaylock -f -c 24273a' \
    timeout 600 'wlopm --off "*"' \
    resume 'wlopm --on "*"' \
    before-sleep 'swaylock -f -c 24273a' &

# Start any other applications you want
EOF
    
    chmod +x "$autostart_script"
    log_success "Created DWL autostart script"
}

# Create systemd user service for DWL
create_systemd_service() {
    log_info "Creating systemd user service for DWL..."
    
    local service_dir="$HOME/.config/systemd/user"
    mkdir -p "$service_dir"
    
    cat > "$service_dir/dwl.service" << 'EOF'
[Unit]
Description=DWL - Dynamic Window Manager for Wayland
Documentation=https://github.com/djpohly/dwl
BindsTo=graphical-session.target
Wants=graphical-session.target
After=graphical-session.target

[Service]
Type=notify
ExecStart=/usr/local/bin/dwl
Restart=on-failure
RestartSec=1
TimeoutStopSec=10

[Install]
WantedBy=graphical-session.target
EOF
    
    log_success "Created systemd user service for DWL"
}

# Create Wayland session file
create_wayland_session() {
    log_info "Creating Wayland session file..."
    
    sudo mkdir -p /usr/share/wayland-sessions
    
    cat << 'EOF' | sudo tee /usr/share/wayland-sessions/dwl.desktop > /dev/null
[Desktop Entry]
Name=DWL
Comment=Dynamic Window Manager for Wayland
Exec=dwl
Type=Application
EOF
    
    log_success "DWL Wayland session created"
}

# Install additional optional tools
install_optional_tools() {
    log_info "Installing optional Wayland tools..."
    
    # Ask user about optional packages
    echo
    log_info "Optional tools (recommended):"
    echo "- wbg: wallpaper setter"
    echo "- wlopm: output power management"
    echo "- brightnessctl: brightness control"
    
    read -p "Install optional tools? (Y/n): " install_optional
    
    if [[ ! "$install_optional" =~ ^[Nn]$ ]]; then
        # Install from AUR if available, otherwise skip
        if command -v yay &> /dev/null; then
            yay -S --needed --noconfirm \
                wbg \
                wlopm-git \
                brightnessctl || log_warning "Some optional tools may not be available"
        elif command -v paru &> /dev/null; then
            paru -S --needed --noconfirm \
                wbg \
                wlopm-git \
                brightnessctl || log_warning "Some optional tools may not be available"
        else
            # Install what's available from official repos
            sudo pacman -S --needed --noconfirm \
                brightnessctl || log_warning "Some optional tools not available without AUR helper"
            log_warning "wbg and wlopm require an AUR helper (yay/paru) for installation"
        fi
    fi
}

main() {
    echo "Installing DWL (Dynamic Window Manager for Wayland)..."
    echo "DWL is the Wayland equivalent of DWM - a minimalist tiling window manager."
    echo
    
    install_build_deps
    install_wayland_tools
    build_dwl
    create_autostart_script
    create_systemd_service
    create_wayland_session
    install_optional_tools
    
    log_success "DWL installation completed!"
    echo
    log_info "DWL has been built and installed to /usr/local/bin/dwl"
    log_info "You can start DWL from your display manager or run 'dwl' in a TTY"
    echo
    log_info "Basic keybindings (Alt key is the modifier):"
    echo "  Alt + Return         : Open terminal (alacritty)"
    echo "  Alt + p              : Application launcher (wofi)"
    echo "  Alt + Shift + c      : Close window"
    echo "  Alt + j/k            : Navigate windows"
    echo "  Alt + h/l            : Resize master area"
    echo "  Alt + 1-9            : Switch tags (workspaces)"
    echo "  Alt + Shift + 1-9    : Move window to tag"
    echo "  Alt + s              : Screenshot selection"
    echo "  Alt + Shift + s      : Full screenshot"
    echo "  Alt + Shift + q      : Quit DWL"
    echo
    log_info "Configuration files:"
    echo "  Source: $DWL_DIR"
    echo "  Autostart: ~/.config/dwl/autostart.sh"
    echo "  Systemd service: ~/.config/systemd/user/dwl.service"
    echo
    log_info "Wayland tools installed:"
    echo "  Terminal: alacritty, foot"
    echo "  Launcher: wofi"
    echo "  Screenshots: grim + slurp"
    echo "  Screen lock: swaylock"
    echo "  Notifications: mako"
    echo "  Status bar: waybar"
    echo
    log_info "To customize DWL, edit config.h in $DWL_DIR and rebuild."
}

main "$@"
