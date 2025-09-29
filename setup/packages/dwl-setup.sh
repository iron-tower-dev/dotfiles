#!/usr/bin/env bash
# dwl-setup.sh - Modern dwl (Wayland) setup script for Arch Linux
# Based on dotfiles architecture with automatic installation

set -e

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

# Check if running on Arch Linux
check_arch_linux() {
    if [ ! -f /etc/arch-release ]; then
        log_error "This script is designed for Arch Linux"
        exit 1
    fi
}

# Install dependencies
install_dependencies() {
    log_info "Installing dwl dependencies..."
    
    local packages=(
        # Build essentials
        base-devel
        git
        wayland
        wayland-protocols
        libinput
        libxkbcommon
        pixman
        pkgconf
        
        # Additional build dependencies
        libxcb
        xcb-util-wm
        libdrm
        mesa
        
        # X11 support (for Xwayland)
        xorg-xwayland
        
        # Essential Wayland utilities
        wl-clipboard
        
        # Lightweight terminal emulator (suckless-style)
        foot
        
        # Application launcher (suckless-style)
        bemenu
        
        # Notification daemon (lightweight)
        dunst
        
        # Screen locker
        swaylock
        
        # Screenshot tool
        grim
        slurp
        
        # Background setter
        swaybg
        
        # Additional utilities
        jq
    )
    
    log_info "Checking which packages need to be installed..."
    local to_install=()
    for pkg in "${packages[@]}"; do
        if ! pacman -Qi "$pkg" &>/dev/null; then
            to_install+=("$pkg")
        fi
    done
    
    if [ ${#to_install[@]} -gt 0 ]; then
        log_info "Installing: ${to_install[*]}"
        sudo pacman -S --needed --noconfirm "${to_install[@]}"
        log_success "Dependencies installed"
    else
        log_success "All dependencies already installed"
    fi
}

# Build dwl from source
build_dwl() {
    log_info "Building dwl from source..."
    
    # Check for wlroots
    log_info "Checking for wlroots..."
    if ! pkg-config --exists wlroots 2>/dev/null; then
        log_error "wlroots not found!"
        echo ""
        log_info "dwl requires wlroots to be installed."
        log_info "You have a few options:"
        echo ""
        echo "  Option 1 - Install wlroots from AUR:"
        echo "    yay -S wlroots"
        echo ""
        echo "  Option 2 - Install dwl-git (includes dependencies):"
        echo "    yay -S dwl-git"
        echo ""
        echo "  Option 3 - Build wlroots manually:"
        echo "    https://gitlab.freedesktop.org/wlroots/wlroots"
        echo ""
        log_warning "After installing wlroots, run this script again."
        exit 1
    else
        log_success "wlroots is available"
    fi
    
    local dwl_src="/tmp/dwl-build-$$"
    local dwl_config_src="$HOME/dotfiles/dwl/.config/dwl"
    
    # Clean any existing build directory
    rm -rf "$dwl_src"
    
    # Clone dwl repository
    log_info "Cloning dwl repository..."
    if ! git clone https://codeberg.org/dwl/dwl.git "$dwl_src"; then
        log_error "Failed to clone dwl repository"
        exit 1
    fi
    
    cd "$dwl_src" || exit 1
    
    # Check if custom config.def.h exists in dotfiles
    if [ -f "$dwl_config_src/config.def.h" ]; then
        log_info "Using custom config.def.h from dotfiles..."
        cp "$dwl_config_src/config.def.h" config.def.h
    else
        log_info "Using default configuration (you can customize later)"
    fi
    
    # Build dwl
    log_info "Compiling dwl..."
    if ! make clean; then
        log_error "make clean failed"
        cd - > /dev/null
        rm -rf "$dwl_src"
        exit 1
    fi
    
    if ! make; then
        log_error "Compilation failed"
        log_error "Check if wlroots headers are available: pkg-config --modversion wlroots"
        cd - > /dev/null
        rm -rf "$dwl_src"
        exit 1
    fi
    
    # Install dwl
    log_info "Installing dwl to /usr/local/bin..."
    if ! sudo make install; then
        log_error "Installation failed"
        cd - > /dev/null
        rm -rf "$dwl_src"
        exit 1
    fi
    
    # Copy default config to dotfiles if it doesn't exist
    if [ ! -f "$dwl_config_src/config.def.h" ]; then
        mkdir -p "$dwl_config_src"
        cp config.def.h "$dwl_config_src/config.def.h"
        log_success "Default config.def.h copied to dotfiles"
    fi
    
    log_success "dwl installed successfully to /usr/local/bin/dwl"
    
    # Cleanup
    cd - > /dev/null
    rm -rf "$dwl_src"
}

# Create autostart script
create_autostart() {
    log_info "Creating autostart script..."
    
    local autostart_script="$HOME/dotfiles/dwl/.config/dwl/autostart.sh"
    
    cat > "$autostart_script" << 'EOF'
#!/usr/bin/env bash
# dwl autostart script

# Set environment variables
export XDG_CURRENT_DESKTOP=dwl
export XDG_SESSION_TYPE=wayland
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM=wayland
export SDL_VIDEODRIVER=wayland
export _JAVA_AWT_WM_NONREPARENTING=1

# dwl has a built-in status bar, no external bar needed
# You can pipe status info to dwl if desired

# Start notification daemon
dunst &

# Set wallpaper
if command -v swaybg &> /dev/null; then
    swaybg -i ~/.config/wallpaper.jpg -m fill &
fi

# Start clipboard manager
wl-paste --watch cliphist store &

# Start idle management
# swayidle -w \
#     timeout 300 'swaylock -f' \
#     timeout 600 'wlopm --off \*' \
#     resume 'wlopm --on \*' \
#     before-sleep 'swaylock -f' &

EOF
    
    chmod +x "$autostart_script"
    log_success "Autostart script created"
}

# Create session files
create_session_files() {
    log_info "Creating dwl session files..."
    
    # Create dwl desktop entry
    sudo tee /usr/share/wayland-sessions/dwl.desktop > /dev/null << EOF
[Desktop Entry]
Name=dwl
Comment=dwl - Dynamic Wayland Compositor
Exec=dwl
Type=Application
DesktopNames=dwl
EOF
    
    # Create dwl wrapper script with autostart support
    sudo tee /usr/local/bin/dwl-start > /dev/null << 'EOF'
#!/usr/bin/env bash
# dwl startup wrapper

# Source autostart if it exists
if [ -f "$HOME/.config/dwl/autostart.sh" ]; then
    source "$HOME/.config/dwl/autostart.sh"
fi

# Start dwl
exec dwl
EOF
    
    sudo chmod +x /usr/local/bin/dwl-start
    
    log_success "Session files created"
}

# Create helper scripts
create_helper_scripts() {
    log_info "Creating helper scripts..."
    
    local bin_dir="$HOME/dotfiles/dwl/.local/bin"
    mkdir -p "$bin_dir"
    
    # Application launcher script
    cat > "$bin_dir/dwl-launcher" << 'EOF'
#!/usr/bin/env bash
# Simple application launcher for dwl

bemenu-run -p "Run:" --fn "JetBrainsMono Nerd Font 10" \
    --tb "#1e1e2e" --fb "#1e1e2e" --nb "#1e1e2e" \
    --hb "#89b4fa" --fhb "#1e1e2e" --nhb "#1e1e2e" \
    --tf "#cdd6f4" --ff "#cdd6f4" --nf "#cdd6f4" \
    --hf "#1e1e2e"
EOF
    
    # Screenshot script
    cat > "$bin_dir/dwl-screenshot" << 'EOF'
#!/usr/bin/env bash
# Screenshot utility for dwl

SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

case "$1" in
    area)
        grim -g "$(slurp)" "$SCREENSHOT_DIR/screenshot-$(date +%Y%m%d-%H%M%S).png"
        ;;
    screen)
        grim "$SCREENSHOT_DIR/screenshot-$(date +%Y%m%d-%H%M%S).png"
        ;;
    *)
        echo "Usage: dwl-screenshot {area|screen}"
        exit 1
        ;;
esac

notify-send "Screenshot saved" "Saved to $SCREENSHOT_DIR"
EOF
    
    # Make scripts executable
    chmod +x "$bin_dir"/*
    
    log_success "Helper scripts created"
}

# Create basic configuration documentation
create_readme() {
    log_info "Creating configuration README..."
    
    local readme="$HOME/dotfiles/dwl/README.md"
    
    cat > "$readme" << 'EOF'
# dwl Configuration

dwl is a dynamic window manager for Wayland, inspired by dwm.

## Installation

Run the setup script to install dwl and all dependencies:

```bash
./setup/packages/dwl-setup.sh
```

## Deployment

Deploy the configuration using GNU Stow:

```bash
cd ~/dotfiles
stow dwl
```

## Default Keybindings

- `Mod+Return` - Launch terminal (foot)
- `Mod+p` - Launch application launcher (bemenu)
- `Mod+Shift+c` - Close focused window
- `Mod+j/k` - Focus next/previous window
- `Mod+Shift+j/k` - Move window up/down in stack
- `Mod+h/l` - Resize master area
- `Mod+[1-9]` - Switch to workspace
- `Mod+Shift+[1-9]` - Move window to workspace
- `Mod+Shift+q` - Quit dwl

## Customization

### Configuration File

The main configuration is in `config.def.h`. To customize:

1. Edit `~/.config/dwl/config.def.h`
2. Rebuild dwl:
   ```bash
   cd /tmp
   git clone https://codeberg.org/dwl/dwl.git
   cd dwl
   cp ~/.config/dwl/config.def.h .
   make clean && make
   sudo make install
   ```

### Autostart Applications

Edit `~/.config/dwl/autostart.sh` to add programs that should start with dwl.

## Helper Scripts

- `dwl-rebuild` - Build dwl from source with custom config
- `dwl-launcher` - Application launcher using bemenu
- `dwl-screenshot area` - Take screenshot of selected area
- `dwl-screenshot screen` - Take screenshot of entire screen

## Components

- **Compositor**: dwl (suckless Wayland compositor)
- **Status Bar**: none (dwl's built-in bar)
- **Notifications**: dunst (lightweight)
- **Launcher**: bemenu (dmenu for Wayland)
- **Terminal**: foot (fast, lightweight Wayland terminal)
- **Screenshots**: grim + slurp

## Troubleshooting

### dwl won't start

Check logs:
```bash
journalctl --user -xe
```

### Rebuild dwl

If you make configuration changes:
```bash
./setup/packages/dwl-setup.sh
```

### Check installed version

```bash
dwl -v
```

## Resources

- [dwl Homepage](https://codeberg.org/dwl/dwl)
- [dwl Wiki](https://codeberg.org/dwl/dwl/wiki)
EOF
    
    log_success "README created"
}

# Deploy configuration
deploy_config() {
    log_info "Would you like to deploy the dwl configuration now? (y/n)"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        cd "$HOME/dotfiles"
        stow -t "$HOME" dwl
        log_success "dwl configuration deployed"
    else
        log_info "You can deploy the configuration later with: cd ~/dotfiles && stow dwl"
    fi
}

# Main installation function
main() {
    log_info "Starting dwl setup for Arch Linux..."
    
    check_arch_linux
    install_dependencies
    build_dwl
    create_autostart
    create_session_files
    create_helper_scripts
    create_readme
    
    log_success "dwl setup complete!"
    log_info ""
    log_info "Next steps:"
    log_info "1. Review the README: ~/dotfiles/dwl/README.md"
    log_info "2. Deploy configuration: cd ~/dotfiles && stow dwl"
    log_info "3. Customize config.def.h if desired"
    log_info "4. Log out and select 'dwl' from your display manager"
    log_info ""
    
    deploy_config
}

# Run main function
main "$@"