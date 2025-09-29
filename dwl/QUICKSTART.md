# dwl Quick Start Guide

## Fresh Installation - Start Here!

All old dwl configurations have been removed. This is a completely new setup from scratch.

### What Was Created

1. **Setup Script**: `setup/packages/dwl-setup.sh`
   - Automated installer for Arch Linux
   - Installs all dependencies
   - Builds dwl from source
   - Creates all configuration files

2. **Configuration Directory**: `dwl/.config/`
   - yambar status bar (Catppuccin Macchiato)
   - mako notifications (Catppuccin Macchiato)
   - dwl config template (created during install)

3. **Helper Scripts**: Created during installation
   - Application launcher
   - Screenshot utilities
   - Autostart script

### Installation Steps

```bash
# 1. Navigate to dotfiles
cd ~/dotfiles

# 2. Run the setup script
./setup/packages/dwl-setup.sh

# 3. The script will:
#    - Install all required packages
#    - Build and install dwl
#    - Create configuration files
#    - Ask if you want to deploy via stow

# 4. If you didn't deploy during setup, do it now:
stow dwl

# 5. Log out and select "dwl" from your display manager
```

### What Gets Installed

**Core Components:**
- dwl (dynamic window manager for Wayland)
- wlroots, wayland, wayland-protocols
- xorg-xwayland (X11 compatibility)

**Essential Tools:**
- yambar (status bar)
- mako (notifications)
- bemenu (application launcher)
- grim + slurp (screenshots)
- swaybg (wallpaper)
- swaylock (screen locker)

**Utilities:**
- wl-clipboard
- brightnessctl
- pamixer
- alacritty (if not installed)

### After Installation

1. **Test dwl**: Log out and select "dwl" from SDDM

2. **Customize Configuration**:
   ```bash
   # Edit dwl config
   nvim ~/.config/dwl/config.def.h
   
   # Rebuild after changes
   cd /tmp
   git clone https://codeberg.org/dwl/dwl.git
   cd dwl
   cp ~/.config/dwl/config.def.h .
   make clean && make
   sudo make install
   ```

3. **Customize Autostart**:
   ```bash
   nvim ~/.config/dwl/autostart.sh
   ```

4. **Adjust Status Bar**:
   ```bash
   nvim ~/.config/yambar/config.yml
   ```

5. **Configure Notifications**:
   ```bash
   nvim ~/.config/mako/config
   ```

### Default Keybindings

| Key Combination | Action |
|----------------|--------|
| `Mod+Return` | Launch terminal |
| `Mod+p` | Launch application launcher |
| `Mod+Shift+c` | Close focused window |
| `Mod+j` / `Mod+k` | Focus next/previous window |
| `Mod+Shift+j` / `Mod+Shift+k` | Move window in stack |
| `Mod+h` / `Mod+l` | Resize master area |
| `Mod+[1-9]` | Switch to workspace |
| `Mod+Shift+[1-9]` | Move window to workspace |
| `Mod+Shift+Space` | Toggle floating |
| `Mod+Shift+q` | Quit dwl |

**Note**: `Mod` is typically the Super/Windows key

### Troubleshooting

**dwl won't start:**
```bash
# Check logs
journalctl --user -xe

# Verify dwl is installed
which dwl
dwl -v
```

**Need to rebuild:**
```bash
./setup/packages/dwl-setup.sh
```

**Remove configuration:**
```bash
cd ~/dotfiles
stow -D dwl
```

### Architecture

This setup follows your dotfiles architecture:
- Uses GNU Stow for deployment
- Catppuccin Macchiato theming throughout
- Integrates with existing tools (alacritty, etc.)
- SDDM display manager integration

### Resources

- [dwl Homepage](https://codeberg.org/dwl/dwl)
- [dwl Wiki](https://codeberg.org/dwl/dwl/wiki)
- Full README will be created at: `~/dotfiles/dwl/README.md` after installation

## Ready to Install?

Run the setup script now:
```bash
./setup/packages/dwl-setup.sh
```