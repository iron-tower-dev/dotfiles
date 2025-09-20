# Enhanced Waybar Configuration

A clean, modern, and full-featured Waybar setup using Catppuccin Macchiato colors with custom scripts for improved functionality.

## Features

### 🎨 Visual Design
- **Catppuccin Macchiato** color scheme
- Modern rounded corners and smooth animations
- Hover effects with smooth transitions
- Responsive design for different screen sizes
- Gradient backgrounds and custom color coding

### 📱 Modules

#### Left Section
- **Workspaces**: Interactive workspace indicators with hover effects
- **Window Title**: Current window title with truncation

#### Center Section
- **Weather**: Real-time weather information from wttr.in
- **Media Player**: Enhanced media controls with multiple player support

#### Right Section
- **Idle Inhibitor**: Toggle display sleep prevention
- **Network**: Connection status with detailed information
- **System Monitoring**: CPU, Memory, and Disk usage
- **Audio**: Volume control with device information
- **Backlight**: Brightness control (scroll to adjust)
- **Battery**: Status with charging animations
- **Clock**: Time with calendar tooltip
- **System Tray**: Application tray icons
- **Power Menu**: Enhanced power options

## Custom Scripts

All scripts are located in the `scripts/` directory:

### 🎵 Media Control (`media.sh`)
- Multi-player support (detects active player)
- Shows artist, title, album information
- Displays playback position and duration
- Visual indicators for play/pause state
- **Controls**:
  - Click: Play/pause
  - Right-click: Next track
  - Middle-click: Previous track
  - Scroll: Volume control

### 🌡️ Weather (`weather.sh`)
- Fetches weather from wttr.in (Phoenix, AZ by default)
- Caches results for 10 minutes to reduce API calls
- Color-coded temperature indicators
- Detailed weather information in tooltip
- Click to open weather website

### 🌐 Network (`network.sh`)
- Detects WiFi/Ethernet connections
- Shows signal strength for WiFi
- Network speed monitoring (if vnstat is installed)
- Connection status indicators
- Click to open network manager

### ⚡ System Monitoring (`system-info.sh`)
- **CPU**: Usage percentage with load average
- **Memory**: Usage with detailed breakdown
- **Disk**: Space usage for root partition
- Click any module to open system monitor

### 🔌 Power Menu (`power-menu.sh`)
- Enhanced power options with rofi/wofi integration
- Fallback to wlogout if menu apps unavailable
- Options: Lock, Sleep, Reboot, Shutdown, Logout, Hibernate
- Right-click power button for quick lock

## Dependencies

### Required
- `waybar` - Status bar
- `playerctl` - Media control
- `curl` - Weather data
- `brightnessctl` - Brightness control (for laptops)

### Optional (for enhanced functionality)
- `rofi` or `wofi` - Power menu
- `vnstat` - Network speed monitoring
- `iwgetid` - WiFi information
- `gnome-system-monitor` or `htop` - System monitoring
- `nm-connection-editor` - Network management
- `pavucontrol` - Audio control

## Installation

1. Backup your existing configuration:
   ```bash
   cp -r ~/.config/waybar ~/.config/waybar.backup
   ```

2. The configuration is already in place in `~/.config/waybar/`

3. Install dependencies:
   ```bash
   # Arch Linux
   sudo pacman -S waybar playerctl curl brightnessctl rofi
   
   # Optional packages
   sudo pacman -S vnstat wireless_tools networkmanager pavucontrol htop
   ```

4. Restart Waybar:
   ```bash
   killall waybar
   waybar &
   ```

## Customization

### Colors
- Edit `macchiato.css` to change the color scheme
- Modify individual module colors in `style.css`

### Weather Location
- Edit `scripts/weather.sh` and change the `LOCATION` variable
- Format: "City,Country" or just "City"

### Modules
- Add/remove modules by editing the `modules-left`, `modules-center`, and `modules-right` arrays in `config`
- Adjust update intervals for performance optimization

### Styling
- Modify `style.css` for visual adjustments
- All modules use CSS classes for easy theming
- Responsive breakpoints at 1366px and 1024px

## Troubleshooting

### Scripts not working
- Check script permissions: `chmod +x scripts/*.sh`
- Verify dependencies are installed
- Check Waybar logs: `journalctl -f -u waybar`

### Weather not showing
- Test the script manually: `./scripts/weather.sh`
- Check internet connection
- Verify curl is installed

### Media controls not responding
- Ensure a media player is running
- Test playerctl: `playerctl status`
- Check if player supports MPRIS

### High CPU usage
- Increase script intervals in `config`
- Consider disabling resource-intensive modules

## Performance Tips

- Weather updates every 10 minutes (cached)
- System monitoring updates every 3-30 seconds based on importance
- Network status updates every 10 seconds
- Media status updates every 2 seconds

## Contributing

Feel free to modify scripts and styling to match your preferences. The configuration is designed to be modular and easily customizable.

## Color Scheme Reference

Based on Catppuccin Macchiato:
- **Base**: #24273a (background)
- **Surface0**: #363a4f (module backgrounds)
- **Text**: #cad3f5 (primary text)
- **Blue**: #8aadf4 (clock, links)
- **Green**: #a6da95 (battery, positive states)
- **Yellow**: #eed49f (warnings, brightness)
- **Red**: #ed8796 (critical states, power)
- **Mauve**: #c6a0f6 (media)
- **Pink**: #f5bde6 (audio)
