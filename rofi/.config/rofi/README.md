# Modern Rofi Configuration with Catppuccin Macchiato

A comprehensive, modern rofi configuration featuring the beautiful Catppuccin Macchiato color scheme with tabbed interface for multiple modes.

## Features

- **Beautiful Catppuccin Macchiato Theme**: Consistent with your system's color scheme
- **Tabbed Interface**: Easy switching between different modes with visual tabs
- **Custom SVG Border**: Your catppuccin-border.svg displayed as background under mode selections
- **Multiple Modes**: Apps, Run, Windows, SSH, File Browser, and Combined mode
- **Modern Styling**: Rounded corners, proper spacing, and clean typography
- **Icon Support**: Beautiful icons for applications and modes
- **Fuzzy Matching**: Fast and intuitive search with fuzzy matching
- **Custom Launcher Script**: Convenient script for different use cases

## Available Modes

| Mode | Description | Shortcut |
|------|-------------|----------|
| **Apps** | Application launcher (default) | `Super + 1` |
| **Run** | Command runner | `Super + 2` |
| **Windows** | Window switcher | `Super + 3` |
| **SSH** | SSH connection menu | `Super + 4` |
| **Files** | File browser | `Super + 5` |
| **All** | Combined mode (apps + run + windows) | `Super + 6` |

## Usage

### Basic Usage
```bash
# Launch with default mode (apps)
rofi -show drun

# Launch specific modes
rofi -show run
rofi -show window
rofi -show ssh
rofi -show filebrowser
rofi -show combi
```

### Using the Launcher Script
```bash
# Default (apps)
~/.config/rofi/launcher.sh

# Specific modes
~/.config/rofi/launcher.sh apps
~/.config/rofi/launcher.sh run
~/.config/rofi/launcher.sh window
~/.config/rofi/launcher.sh ssh
~/.config/rofi/launcher.sh files
~/.config/rofi/launcher.sh all

# Special modes
~/.config/rofi/launcher.sh power      # Power menu
~/.config/rofi/launcher.sh clipboard  # Clipboard history (requires clipmenu)
~/.config/rofi/launcher.sh calc       # Calculator (requires rofi-calc)
~/.config/rofi/launcher.sh emoji      # Emoji picker (requires rofi-emoji)
```

## Key Bindings

### Mode Navigation
- `Ctrl + Tab` / `Alt + Tab`: Next mode tab
- `Ctrl + Shift + Tab` / `Alt + Shift + Tab`: Previous mode tab
- `Super + 1-6`: Direct mode selection

### General Navigation
- `↑/↓` or `Ctrl + p/n`: Navigate up/down
- `Enter`: Select item
- `Shift + Enter`: Alternative action
- `Ctrl + Enter`: Custom command
- `Delete`: Remove from history
- `Escape` or `Ctrl + g`: Cancel
- `Tab`: Auto-complete

### Search
- `Ctrl + u`: Clear input
- `Ctrl + l`: Clear line
- `Ctrl + a`: Move to beginning
- `Ctrl + e`: Move to end

## Window Manager Integration

### i3/i3-gaps
Add to your i3 config:
```
bindsym $mod+d exec --no-startup-id ~/.config/rofi/launcher.sh
bindsym $mod+Shift+d exec --no-startup-id ~/.config/rofi/launcher.sh run
bindsym $mod+Tab exec --no-startup-id ~/.config/rofi/launcher.sh window
bindsym $mod+Shift+e exec --no-startup-id ~/.config/rofi/launcher.sh power
```

### Hyprland
Add to your hyprland.conf:
```
bind = SUPER, D, exec, ~/.config/rofi/launcher.sh
bind = SUPER SHIFT, D, exec, ~/.config/rofi/launcher.sh run
bind = SUPER, TAB, exec, ~/.config/rofi/launcher.sh window
bind = SUPER SHIFT, E, exec, ~/.config/rofi/launcher.sh power
```

### Sway
Add to your sway config:
```
bindsym $mod+d exec ~/.config/rofi/launcher.sh
bindsym $mod+Shift+d exec ~/.config/rofi/launcher.sh run
bindsym $mod+Tab exec ~/.config/rofi/launcher.sh window
bindsym $mod+Shift+e exec ~/.config/rofi/launcher.sh power
```

## Customization

### Colors
The theme uses Catppuccin Macchiato colors defined in `catppuccin-macchiato.rasi`. You can modify colors by editing this file.

### Fonts
Default font is "JetBrains Mono Nerd Font 12". Change in `config.rasi`:
```rasi
font: "Your Font Name 12";
```

### Layout
Adjust window size and positioning in `config.rasi`:
```rasi
width: 800px;        // Window width
lines: 10;           // Number of visible lines
```

### Icons
Icons are provided by Papirus-Dark theme. Change in `config.rasi`:
```rasi
icon-theme: "Your-Icon-Theme";
```

## Dependencies

### Required
- `rofi` (obviously)
- Nerd Font (for icons in tabs and prompt)
- Icon theme (Papirus-Dark recommended)

### Optional
- `clipmenu`: For clipboard history
- `rofi-calc`: For calculator mode
- `rofi-emoji`: For emoji picker

## Installation Commands

```bash
# Install rofi and dependencies (Arch Linux)
sudo pacman -S rofi papirus-icon-theme
yay -S ttf-jetbrains-mono-nerd

# Optional additions
sudo pacman -S clipmenu
yay -S rofi-calc rofi-emoji
```

## Troubleshooting

### Icons not showing
- Install a Nerd Font and set it in the config
- Make sure icon theme is installed
- Check that `show-icons: true;` is set

### SSH mode empty
- Make sure you have SSH hosts in `~/.ssh/config` or `~/.ssh/known_hosts`
- Check that `parse-hosts: true;` is set

### File browser not working
- Ensure you're using rofi version 1.7.0 or newer
- File browser is a built-in mode in recent rofi versions

### Performance issues
- Disable sorting for better performance: `sort: false;`
- Reduce number of visible lines
- Disable icons if not needed

Enjoy your modern, beautiful rofi setup! 🎨
