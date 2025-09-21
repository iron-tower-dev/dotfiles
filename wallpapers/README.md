# Wallpapers Directory

This directory contains wallpapers for the Hyprland desktop environment. The wallpapers are managed using `swww` (Wayland wallpaper daemon) and can be set randomly via the Waybar module.

## Features

- **Random Wallpaper Selection**: Click the wallpaper module (🎨) in Waybar to set a random wallpaper
- **Smooth Transitions**: Uses swww for smooth wallpaper transitions with various effects
- **Waypaper Integration**: Right-click the module to open waypaper GUI for manual selection
- **Automatic Initialization**: Wallpaper system initializes automatically on login

## Usage

### Via Waybar Module
- **Left Click**: Set random wallpaper with random transition effect
- **Right Click**: Open waypaper GUI for manual selection
- **Tooltip**: Shows current status and click instructions

### Via Keyboard Shortcut
- **Super + W**: Set random wallpaper (configured in Hyprland)

### Via Command Line
```bash
# Set random wallpaper
~/.config/waybar/scripts/wallpaper.sh set

# Initialize system (start swww daemon and set initial wallpaper)
~/.config/waybar/scripts/wallpaper.sh init

# Show help
~/.config/waybar/scripts/wallpaper.sh help
```

## Supported Formats

The wallpaper script supports the following image formats:
- PNG (.png)
- JPEG (.jpg, .jpeg)
- WebP (.webp)

## Transition Effects

The script randomly selects from these transition effects:
- Simple
- Fade
- Wipe
- Wave
- Grow
- Center

## Adding Wallpapers

Simply add your wallpaper images to this directory. The script will automatically detect and include them in the random selection.

## Configuration

Edit the wallpaper script at `~/.config/waybar/scripts/wallpaper.sh` to customize:
- `WALLPAPER_DIR`: Change wallpaper directory location
- `TRANSITION_TYPES`: Modify available transition effects
- `TRANSITION_DURATION`: Adjust transition timing
- `NOTIFICATION_TIMEOUT`: Change notification duration

## Dependencies

- `swww`: Wayland wallpaper daemon
- `waypaper`: GUI wallpaper manager (optional, for right-click functionality)
- `libnotify`: For desktop notifications
- `dunst`: Notification daemon

All dependencies are automatically installed by the dotfiles setup scripts.
