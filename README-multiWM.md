# Multi-Distribution Desktop Environment Installer

This is a comprehensive dotfiles system that supports multiple Linux distributions and window managers, providing a unified installation experience across different desktop environments.

## 🏗️ Architecture

### Distribution Support
- **Arch Linux** (including Manjaro) - ✅ Full support
- **Debian/Ubuntu** - 🚧 Planned
- **Fedora/RHEL** - 🚧 Planned  
- **NixOS** - 🚧 Planned

### Window Manager Support

#### Wayland
- **Hyprland** - Feature-rich compositor with animations and effects
- **DWL** - Minimalist suckless window manager for Wayland

#### X11
- **Qtile** - Python-based highly configurable tiling window manager
- **DWM** - Lightweight suckless dynamic window manager

## 🚀 Quick Start

### Modern Installation (Recommended)
```bash
# Clone the repository
git clone <repository-url> ~/dotfiles
cd ~/dotfiles

# Run the installer (auto-detects distribution)
./bootstrap.sh

# Or run distribution-specific installer directly
./distros/arch/arch-install.sh  # For Arch Linux
```

### Legacy Installation (Hyprland only on Arch)
```bash
./bootstrap.sh --legacy
```

## 📁 Directory Structure

```
dotfiles/
├── bootstrap.sh              # Main dispatcher script
├── distros/                  # Distribution-specific installers
│   └── arch/
│       └── arch-install.sh   # Arch Linux installer with WM selection
├── window_managers/          # Window manager installation scripts
│   ├── qtile/
│   │   └── install-qtile.sh  # Qtile installation and configuration
│   ├── dwm/
│   │   └── install-dwm.sh    # DWM installation and configuration
│   └── dwl/
│       └── install-dwl.sh    # DWL installation and configuration
├── setup/                    # Shared installation scripts
│   ├── packages/             # Package lists and installers
│   ├── system/               # System configuration scripts
│   └── themes/               # Theme setup scripts
└── [wm-configs]/             # Stow-managed configuration directories
    ├── hyprland/             # Hyprland configuration
    ├── qtile/                # Qtile configuration (when deployed)
    ├── dwm/                  # DWM configuration (when deployed)
    ├── dwl/                  # DWL configuration (when deployed)
    ├── alacritty/            # Terminal configuration
    ├── waybar/               # Status bar (Wayland)
    ├── rofi/                 # Application launcher
    ├── fish/                 # Fish shell configuration
    ├── neovim/               # Neovim configuration
    └── ...                   # Other application configs
```

## 🎯 Window Manager Features

### Hyprland (Wayland) ✨
- **Display Server**: Wayland
- **Features**: Animations, effects, modern Wayland features
- **Status Bar**: Waybar
- **Launcher**: Rofi
- **Terminal**: Alacritty
- **Theme**: Catppuccin Macchiato throughout

### Qtile (X11) 🐍
- **Display Server**: X11
- **Language**: Python-based configuration
- **Features**: Highly customizable, extensible with Python
- **Status Bar**: Built-in Qtile bar
- **Launcher**: Rofi
- **Terminal**: Alacritty
- **Theme**: Catppuccin Macchiato colors

### DWM (X11) ⚡
- **Display Server**: X11
- **Philosophy**: Suckless, minimal, fast
- **Configuration**: Compiled C configuration
- **Launcher**: dmenu (also compiled) + Rofi fallback
- **Terminal**: Alacritty + optional st (simple terminal)
- **Theme**: Catppuccin Macchiato colors

### DWL (Wayland) 🌊
- **Display Server**: Wayland
- **Philosophy**: Wayland equivalent of DWM
- **Configuration**: Compiled C configuration
- **Status Bar**: Waybar
- **Launcher**: wofi
- **Terminal**: Alacritty + foot
- **Theme**: Catppuccin Macchiato colors

## ⌨️ Default Keybindings

### Hyprland
- `Super + Enter` - Terminal
- `Super + Space` - Application launcher
- `Super + Q` - Close window
- `Super + 1-9` - Switch workspaces

### Qtile
- `Super + Return` - Terminal
- `Super + r` - Application launcher  
- `Super + w` - Close window
- `Super + 1-9` - Switch workspaces

### DWM
- `Alt + Shift + Return` - Terminal
- `Alt + p` - dmenu launcher
- `Alt + r` - rofi launcher
- `Alt + Shift + c` - Close window
- `Alt + 1-9` - Switch tags

### DWL
- `Alt + Return` - Terminal
- `Alt + p` - Application launcher
- `Alt + Shift + c` - Close window
- `Alt + 1-9` - Switch tags

## 🛠️ Customization

### Window Manager Customization

#### Compiled Window Managers (DWM/DWL)
For DWM and DWL, configuration is done by editing `config.h` files and recompiling:

```bash
# DWM customization
cd ~/.local/src/dwm
nvim config.h
make clean && make && sudo make install

# DWL customization  
cd ~/.local/src/dwl
nvim config.h
make clean && make && sudo make install
```

#### Script-Based Window Managers (Qtile)
Qtile configuration is managed via Python files:

```bash
# Edit Qtile configuration
nvim ~/.config/qtile/config.py
# Restart Qtile to apply changes (Super + Ctrl + r)
```

#### Hyprland
Hyprland uses text-based configuration:

```bash
# Edit Hyprland configuration
nvim ~/.config/hypr/hyprland.conf
# Reload configuration (Super + Ctrl + r)
```

### Adding New Window Managers

To add a new window manager:

1. Create directory: `window_managers/newwm/`
2. Create installer: `window_managers/newwm/install-newwm.sh`
3. Add WM to the Arch installer in `distros/arch/arch-install.sh`
4. Create stow directory: `newwm/` with configurations
5. Update package lists as needed

## 🔧 Development

### Testing New Features
```bash
# Test syntax of scripts
bash -n bootstrap.sh
bash -n distros/arch/arch-install.sh
bash -n window_managers/qtile/install-qtile.sh

# Test dry-run installations
bash bootstrap.sh --help
bash distros/arch/arch-install.sh --help
```

### Adding Distribution Support

1. Create directory: `distros/newdistro/`
2. Create installer: `distros/newdistro/newdistro-install.sh`
3. Update distribution detection in `bootstrap.sh`
4. Adapt package lists for the new distribution's package manager
5. Test thoroughly

## 📋 Installation Process

1. **Detection**: Automatically detect Linux distribution
2. **Selection**: Choose display server (Wayland/X11) and window manager
3. **Packages**: Install base packages and distribution-specific dependencies
4. **Display Server**: Install Wayland or X11 packages
5. **Window Manager**: Install and configure selected window manager
6. **Themes**: Apply Catppuccin Macchiato theme consistently
7. **System**: Configure shells, tools, and system services
8. **Dotfiles**: Deploy configurations using GNU Stow
9. **Startup**: Create appropriate startup files and session entries

## 🎨 Theme System

All window managers use a consistent **Catppuccin Macchiato** color scheme:

- **Background**: `#24273a`
- **Foreground**: `#cad3f5`  
- **Accent**: `#8aadf4` (Blue)
- **Surface**: `#363a4f`
- **Overlay**: `#6e738d`

This ensures a unified visual experience across different window managers and applications.

## 🔄 Migration Guide

### From Legacy to Modern
If you're using the old Hyprland-only installer:

```bash
# Backup existing configurations
cp -r ~/.config ~/.config-backup-$(date +%Y%m%d)

# Use modern installer
./bootstrap.sh --modern
```

### Switching Window Managers
To try a different window manager:

```bash
# Install additional window manager
./window_managers/qtile/install-qtile.sh

# Deploy its configurations
stow -t ~ qtile

# Select it from your display manager login screen
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Test your changes thoroughly
4. Submit a pull request with detailed description

### Guidelines
- Follow existing code style and structure
- Test on actual systems before submitting
- Document any new features or changes
- Maintain backward compatibility when possible

## 📖 Legacy Documentation

For the original Hyprland-only setup, see the main `README.md` and `WARP.md` files.

## 🐛 Troubleshooting

### Common Issues

**Script permissions**: 
```bash
chmod +x bootstrap.sh
chmod +x distros/*/**.sh  
chmod +x window_managers/*/**.sh
```

**Missing dependencies**:
```bash
# Install base development tools
sudo pacman -S base-devel git stow  # Arch
```

**Stow conflicts**:
```bash
# Remove conflicting files manually or backup
stow -D -t ~ package-name  # Remove existing stow package
```

**Distribution not detected**:
```bash
# Check /etc/os-release
cat /etc/os-release
# Manually run distribution-specific installer
./distros/arch/arch-install.sh
```
