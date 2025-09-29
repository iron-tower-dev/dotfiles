# dwl Quick Installation Guide

## One-Command Install

```bash
cd ~/dotfiles && ./setup/packages/install-dwl.sh && stow dwl
```

That's it! Then log out and select "dwl" from SDDM.

## What This Installs

1. **Dependencies**: wlroots0.19, foot, wmenu, grim, slurp, swaybg, firefox
2. **dwl**: Built from https://codeberg.org/dwl/dwl.git
3. **slstatus**: Built from https://git.suckless.org/slstatus
4. **Configs**: Custom Catppuccin Macchiato theme + Hyprland keybinds

## Key Features

- ✅ **Super key** as mod (like Hyprland)
- ✅ **Catppuccin Macchiato** colors
- ✅ **slstatus** status bar with CPU, RAM, Disk, WiFi, Time
- ✅ **foot** terminal (lightweight)
- ✅ **wmenu** launcher (dmenu for Wayland)

## Essential Keybindings

```
Super + Return       → Terminal
Super + Space        → Launcher
Super + Q            → Close window
Super + M            → Quit dwl
Super + 1-9          → Switch workspace
Super + Shift + 1-9  → Move to workspace
```

## Post-Install

1. **Log out**: Exit current session
2. **Select dwl**: Choose from SDDM session menu
3. **Press Super+Return**: Open terminal
4. **Press Super+Space**: Open launcher

## Troubleshooting

**No status bar?**
```bash
# Check if slstatus is running
pgrep slstatus

# Manually start if needed
slstatus | dwl
```

**Keybinds don't work?**
```bash
# Verify Super key is set
grep MODKEY ~/.config/dwl/config.h
# Should show: WLR_MODIFIER_LOGO
```

**wmenu doesn't show?**
```bash
# Test directly
ls /usr/bin | wmenu

# Reinstall if needed
sudo pacman -S wmenu
```

## Full Documentation

See [README.md](README.md) for complete documentation.

## Comparison

| Feature | dwl | Hyprland |
|---------|-----|----------|
| RAM Usage | ~15MB | ~100MB+ |
| Config | C source | Config file |
| Philosophy | Suckless | Feature-rich |
| Animations | None | Extensive |
| Setup | Compile | Install |

dwl is perfect if you want:
- Minimal resource usage
- Suckless philosophy
- Simple, keyboard-driven workflow
- Fast and lightweight

Keep using Hyprland if you want:
- Beautiful animations
- Easy configuration
- More features out of the box
- Wayland protocol extras