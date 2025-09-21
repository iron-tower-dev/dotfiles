# SDDM Configuration - Catppuccin Macchiato

This directory contains the SDDM (Simple Desktop Display Manager) configuration for a modern Catppuccin Macchiato themed login experience.

## Overview

SDDM is configured with:
- **Catppuccin Macchiato theme** - Modern, beautiful login screen with soothing pastel colors
- **HiDPI support** - Automatically scales for high-resolution displays 
- **Wayland & X11 support** - Works with both display server protocols
- **Session management** - Remembers last user and session preferences
- **Integration with system** - Matches the overall Catppuccin theming

## Files

- `sddm.conf` - Main SDDM configuration file (deployed to `/etc/sddm.conf`)
- `README.md` - This documentation file

## Theme Features

The Catppuccin Macchiato SDDM theme provides:

### Color Palette
- **Base**: `#24273a` - Main background color
- **Surface0**: `#363a4f` - Input field backgrounds  
- **Surface1**: `#494d64` - Hover states
- **Text**: `#cad3f5` - Primary text color
- **Subtext0**: `#a5adcb` - Secondary text/placeholders
- **Mauve**: `#c6a0f6` - Primary accent color
- **Blue**: `#8aadf4` - Interactive elements

### Visual Elements
- Clean, minimal design with subtle shadows
- Rounded corners and smooth transitions
- Avatar support for user profiles
- Session selection dropdown
- Power management buttons (shutdown, reboot)
- Keyboard layout indicator
- Clock display

## Installation

### Automatic Installation (Recommended)
```bash
# From dotfiles root directory
./bootstrap.sh --sddm

# Or as part of full installation
./bootstrap.sh --full
```

### Manual Installation
```bash
# Install SDDM and theme
sudo pacman -S sddm qt5-quickcontrols2 qt5-graphicaleffects
paru -S catppuccin-sddm-theme-macchiato

# Deploy configuration
sudo cp sddm/sddm.conf /etc/sddm.conf

# Enable SDDM service
sudo systemctl enable sddm.service
```

## Configuration Details

### Theme Selection
The configuration sets the current theme to `catppuccin-macchiato`:
```ini
[Theme]
Current=catppuccin-macchiato
```

### Display Settings
- **HiDPI**: Automatic scaling enabled for both X11 and Wayland
- **Cursor**: Catppuccin Macchiato dark cursors
- **Avatars**: User profile pictures enabled

### Session Management
- **RememberLastSession**: `true` - Automatically selects last used session
- **RememberLastUser**: `true` - Pre-fills last logged in username
- **SessionDir**: Supports both Wayland (`/usr/share/wayland-sessions`) and X11 (`/usr/share/xsessions`)

### User Management
- Shows users with UID between 1000-60000
- Hides system users and specified shells
- Supports user avatar images

## Customization

### Changing Theme Variant
To use a different Catppuccin variant, install the desired theme and update the configuration:

```bash
# Install other variants
paru -S catppuccin-sddm-theme-mocha      # Dark variant
paru -S catppuccin-sddm-theme-frappe     # Medium variant  
paru -S catppuccin-sddm-theme-latte      # Light variant

# Update configuration
sudo sed -i 's/Current=catppuccin-macchiato/Current=catppuccin-mocha/' /etc/sddm.conf
```

### Font Configuration
The SDDM user has Qt configuration in `/var/lib/sddm/.config/qt5ct.conf`:
- **System Font**: Inter (clean, modern sans-serif)
- **Monospace Font**: JetBrainsMono Nerd Font (code and terminal text)

### Background Customization
The Catppuccin theme supports custom backgrounds. Place images in the theme directory:
```bash
sudo cp your-background.jpg /usr/share/sddm/themes/catppuccin-macchiato/
```

## Troubleshooting

### Theme Not Loading
1. Verify theme installation:
   ```bash
   ls -la /usr/share/sddm/themes/catppuccin-macchiato/
   ```

2. Check SDDM configuration:
   ```bash
   sudo cat /etc/sddm.conf | grep "Current="
   ```

3. View SDDM logs:
   ```bash
   sudo journalctl -u sddm.service
   ```

### Display Issues
1. For HiDPI problems, ensure `EnableHiDPI=true` in both `[X11]` and `[Wayland]` sections
2. For font rendering issues, verify Qt font configuration in `/var/lib/sddm/.config/`

### Service Issues
1. Check if SDDM is enabled:
   ```bash
   systemctl status sddm.service
   ```

2. Disable conflicting display managers:
   ```bash
   sudo systemctl disable gdm.service lightdm.service
   ```

### Session Problems
1. Verify session files exist:
   ```bash
   ls /usr/share/wayland-sessions/    # For Wayland sessions
   ls /usr/share/xsessions/          # For X11 sessions
   ```

2. Check session permissions:
   ```bash
   ls -la ~/.xsession-errors         # X11 session errors
   ls -la ~/.local/share/sddm/       # SDDM session logs
   ```

## Integration with Dotfiles

The SDDM configuration integrates seamlessly with the dotfiles system:

1. **Managed by Stow**: Configuration is deployed using GNU Stow like other dotfiles
2. **Bootstrap Integration**: Automated installation via `bootstrap.sh`
3. **Theme Consistency**: Matches Catppuccin theming used throughout the desktop environment
4. **Backup Support**: Existing configurations are backed up during deployment

## Updating

To update the SDDM configuration:

1. Edit files in the dotfiles repository:
   ```bash
   nvim ~/dotfiles/sddm/sddm.conf
   ```

2. Re-deploy configuration:
   ```bash
   cd ~/dotfiles
   ./setup/system/setup-sddm.sh
   ```

3. Or manually copy:
   ```bash
   sudo cp ~/dotfiles/sddm/sddm.conf /etc/sddm.conf
   ```

## Security Considerations

- SDDM runs as a system service with elevated privileges
- User avatars are stored in `/usr/share/sddm/faces/`
- Session scripts have access to system resources
- Configuration file is readable by all users but only writable by root

## Related Components

This SDDM configuration works with:
- **Hyprland**: Primary Wayland compositor
- **X11 sessions**: Fallback X11 window managers
- **Catppuccin GTK/Qt themes**: Consistent application theming  
- **Catppuccin cursors**: Matching cursor theme
- **System fonts**: JetBrains Mono and Inter fonts

## References

- [SDDM Documentation](https://github.com/sddm/sddm)
- [Catppuccin SDDM Theme](https://github.com/catppuccin/sddm)
- [Catppuccin Color Palette](https://catppuccin.com/palette)
