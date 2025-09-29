# dwl - Suckless Wayland Compositor

A lightweight, efficient Wayland compositor based on dwm principles, configured with Catppuccin Macchiato theming and Hyprland-style keybindings.

## Features

- **Suckless Philosophy**: Minimal, fast, keyboard-driven
- **Catppuccin Macchiato Theme**: Beautiful, cohesive colors throughout
- **Hyprland-Compatible Keybindings**: Familiar if you use Hyprland
- **slstatus Integration**: Clean, minimal status bar
- **Proper Dependencies**: Uses wlroots 0.19 for stability

## Installation

### Quick Install

```bash
cd ~/dotfiles
./setup/packages/install-dwl.sh
```

This script will:
1. Install all dependencies (wlroots0.19, foot, wmenu, etc.)
2. Build dwl from official source
3. Build slstatus from suckless.org
4. Create SDDM session file
5. Use your custom configs if they exist

### Deploy Configuration

```bash
cd ~/dotfiles
stow dwl
```

### Log Out and Select dwl

Log out and select "dwl" from your display manager (SDDM).

## Dependencies

The installation script installs these packages:

- `wayland` - Wayland core
- `wayland-protocols` - Wayland protocols
- `wlroots0.19` - Compositor library (specific version for compatibility)
- `foot` - Lightweight Wayland terminal
- `base-devel` - Build tools
- `git` - Version control
- `wmenu` - dmenu for Wayland
- `wl-clipboard` - Clipboard utilities
- `grim` - Screenshot tool
- `slurp` - Region selection for screenshots
- `swaybg` - Wallpaper setter
- `firefox` - Web browser
- `ttf-jetbrains-mono-nerd` - Font with icons

## Configuration Files

```
dwl/
├── .config/
│   ├── dwl/
│   │   ├── config.h        # dwl configuration (Catppuccin + keybinds)
│   │   └── autostart.sh    # Startup script (launches slstatus)
│   ├── slstatus/
│   │   └── config.h        # Status bar configuration
│   └── foot/
│       └── foot.ini        # Terminal configuration
└── README.md               # This file
```

## Keybindings

All keybindings use `Super` (Windows key) as the modifier, matching Hyprland:

### Basic Window Management

| Keybind | Action |
|---------|--------|
| `Super + Return` | Open terminal (foot) |
| `Super + Space` | Application launcher (wmenu) |
| `Super + Q` | Close window |
| `Super + M` | Quit dwl |
| `Super + E` | File manager (thunar) |
| `Super + T` | Toggle floating |
| `Super + F` | Fullscreen/monocle |

### Window Navigation

| Keybind | Action |
|---------|--------|
| `Super + ←/→/↑/↓` | Focus windows (arrow keys) |
| `Super + J/K` | Focus next/previous (vim-style) |
| `Super + H/L` | Resize master area |
| `Super + Tab` | Switch to last workspace |

### Workspaces (Tags)

| Keybind | Action |
|---------|--------|
| `Super + 1-9` | Switch to workspace 1-9 |
| `Super + Shift + 1-9` | Move window to workspace 1-9 |
| `Super + 0` | View all workspaces |

### Mouse Actions

| Keybind | Action |
|---------|--------|
| `Super + Left Click` | Move window |
| `Super + Right Click` | Resize window |
| `Super + Middle Click` | Toggle floating |

## Customization

### Modify dwl Config

1. Edit the config:
```bash
nvim ~/.config/dwl/config.h
```

2. Rebuild dwl:
```bash
cd /tmp
git clone https://codeberg.org/dwl/dwl.git
cd dwl
cp ~/.config/dwl/config.h config.h
make clean && make
sudo make install
```

### Modify slstatus

1. Edit the config:
```bash
nvim ~/.config/slstatus/config.h
```

2. Rebuild slstatus:
```bash
cd /tmp
git clone https://git.suckless.org/slstatus
cd slstatus
cp ~/.config/slstatus/config.h config.h
make clean && make
sudo make install
```

3. Restart dwl or kill and restart slstatus

### Adjust Status Bar

The slstatus config shows:
- CPU usage
- RAM usage  
- Disk usage
- WiFi network (adjust interface name in config)
- Date and time

To customize:
- Edit `~/.config/slstatus/config.h`
- Uncomment battery section if on laptop
- Change network interface name to match your system
- Rebuild as shown above

### Change Terminal

By default, dwl uses `foot`. To use a different terminal:

1. Edit `~/.config/dwl/config.h`
2. Change the `termcmd` line:
```c
static const char *termcmd[] = { "alacritty", NULL };
```
3. Rebuild dwl

## Colors

All colors use **Catppuccin Macchiato**:

| Element | Color | Hex |
|---------|-------|-----|
| Background | Base | `#24273a` |
| Border (unfocused) | Overlay1 | `#7e8fab` |
| Border (focused) | Blue | `#8aadf4` |
| Urgent | Red | `#ed8796` |
| Fullscreen BG | Crust | `#181926` |

## Status Bar

slstatus shows a minimal, clean status bar with:
- 󰘚 CPU percentage
- 󰍛 RAM percentage
- 󰋊 Disk usage
- 󰤨 WiFi network name
-  Date and time

The bar updates every second and uses Nerd Font icons.

## Troubleshooting

### No Status Bar Visible

Check if slstatus is running:
```bash
pgrep slstatus
```

If not running, manually start it:
```bash
slstatus | dwl
```

### Wrong wlroots Version

Make sure you have wlroots 0.19:
```bash
pacman -Q wlroots0.19
```

### Keybindings Don't Work

Verify Super key is set as MODKEY in config:
```bash
grep "MODKEY" ~/.config/dwl/config.h
# Should show: #define MODKEY WLR_MODIFIER_LOGO
```

### wmenu Not Showing

Test wmenu directly:
```bash
ls /usr/bin | wmenu
```

If it doesn't work, install wmenu:
```bash
sudo pacman -S wmenu
```

### Rebuild Everything

If things are broken, reinstall:
```bash
cd ~/dotfiles
./setup/packages/install-dwl.sh
```

## Resources

- [dwl Homepage](https://codeberg.org/dwl/dwl)
- [dwl Wiki](https://codeberg.org/dwl/dwl/wiki)
- [slstatus](https://tools.suckless.org/slstatus/)
- [Catppuccin Theme](https://github.com/catppuccin/catppuccin)

## Philosophy

This setup follows the suckless philosophy:
- **Minimal**: Only essential features
- **Fast**: Lightweight and efficient
- **Configurable**: Edit source code and recompile
- **Keyboard-driven**: Minimal mouse usage
- **Beautiful**: Catppuccin theming throughout

dwl + slstatus + foot = ~15MB RAM usage (compared to Hyprland's ~100MB+)

## Architecture

```
┌─────────────────────────────────────┐
│          dwl (compositor)           │
│  - Window management                │
│  - Wayland protocol                 │
│  - Reads status from stdin          │
└─────────────────────────────────────┘
              ↑
              │ (pipe)
              │
┌─────────────────────────────────────┐
│       slstatus (status bar)         │
│  - CPU/RAM/Disk monitoring          │
│  - Network info                     │
│  - Date/Time                        │
│  - Outputs to stdout                │
└─────────────────────────────────────┘
```

The autostart script pipes slstatus output to dwl, providing the status bar.