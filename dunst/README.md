# Dunst Notification Configuration

This directory contains the Dunst notification daemon configuration with Catppuccin Macchiato theming to match the system-wide color scheme.

## Features

- **Catppuccin Macchiato Theme**: Consistent with system theme
- **Urgency-based Colors**: Different colors for low, normal, and critical notifications
- **Application-specific Styling**: Custom colors for Spotify, Discord, volume, and brightness notifications
- **Modern Configuration**: Uses current dunst syntax and best practices
- **Rounded Corners**: Matches system aesthetic with 12px corner radius
- **JetBrains Mono Font**: Consistent with terminal and editor

## Color Scheme

- **Background**: `#24273a` (Catppuccin Macchiato base)
- **Text**: `#cad3f5` (Catppuccin Macchiato text)
- **Normal**: `#8aadf4` (blue accent)
- **Critical**: `#ed8796` (red accent)
- **Low Priority**: `#363a4f` (subtle frame)

## Usage

### Arch Linux (Stow-based dotfiles)

Deploy the configuration using Stow:
```bash
# Deploy dunst configuration
stow -t ~ dunst

# Restart dunst to apply changes
pkill dunst && dunst &
```

### NixOS (Home Manager)

The dunst configuration is fully integrated into the NixOS configuration at `nixos/users/derrick/desktop.nix`. When using NixOS:

1. The dunst service is managed by Home Manager
2. Configuration is applied automatically during system rebuild
3. No manual stow deployment needed

To rebuild and apply the configuration:
```bash
# Rebuild NixOS configuration
sudo nixos-rebuild switch --flake .

# Or rebuild only Home Manager
home-manager switch --flake .
```

## Testing

Test different notification urgency levels:

```bash
# Normal notification
notify-send "Test Notification" "This is a normal notification"

# Low priority (subtle gray frame)
notify-send -u low "Low Priority" "This is a low priority notification"

# Critical (red frame, stays until dismissed)
notify-send -u critical "Critical Alert" "This is a critical notification"
```

## Configuration Files

- **Arch Linux**: `~/.config/dunst/dunstrc` (via Stow)
- **NixOS**: Managed by Home Manager configuration
- **Backup Reference**: `~/.config/dunst-dotfiles/` (NixOS symlink for reference)

## Customization

To customize the configuration:

1. **Arch Linux**: Edit `.config/dunst/dunstrc` in the dotfiles, then restow
2. **NixOS**: Edit `nixos/users/derrick/desktop.nix` dunst settings, then rebuild

## Troubleshooting

### Check if dunst is running
```bash
pgrep -fl dunst
```

### View dunst logs
```bash
journalctl --user -f -u dunst.service  # NixOS
dunst -verbosity debug                  # Manual start with debug
```

### Test configuration syntax
```bash
dunst -conf ~/.config/dunst/dunstrc -print
```

## Integration with Window Manager

The configuration includes keybinding hints for integration with your window manager:

- **Close current**: `dunstctl close`
- **Close all**: `dunstctl close-all`
- **Show history**: `dunstctl history-pop`
- **Show context menu**: `dunstctl context`

These commands can be bound to keys in Hyprland or other window managers.
