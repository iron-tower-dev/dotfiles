# Zellij Setup Guide

## ✅ Installation Complete

Zellij has been successfully installed and configured with:
- **Catppuccin Macchiato theme** 
- **Fish shell integration**
- **Tmux-style keybindings** (Ctrl+a prefix)
- **Custom layouts** for different workflows
- **Auto-start functionality** (optional)

## 🎯 Key Features for Output Management

Zellij provides the output management features you were looking for:
- **Scrollback buffer** with history navigation
- **Pane management** to organize commands and outputs
- **Tab system** for different contexts
- **Layout templates** for consistent workflows

## 🚀 Quick Start

### Starting Zellij
```bash
# Start default session
zellij

# Start with specific layout
zellij --layout dev

# Start with session name
zellij --session mysession

# Quick aliases (available in Fish)
zj                    # Start default
zjd                   # Start with dev layout  
zja                   # Attach to session
zjl                   # List sessions
zjk                   # Kill session
```

### Essential Keybindings
All commands start with **Ctrl+a** (like tmux):

**Basic Navigation:**
- `Ctrl+a c` - New tab
- `Ctrl+a %` - Split pane right  
- `Ctrl+a "` - Split pane down
- `Ctrl+a x` - Close current pane
- `Ctrl+a d` - Detach session

**Pane Navigation:**
- `Ctrl+a h/j/k/l` - Move between panes (vim-style)
- `Ctrl+a [` - Enter scroll mode
- `Ctrl+a z` - Toggle pane frames

**Tab Navigation:**
- `Ctrl+a 1-9` - Switch to tab number
- `Ctrl+a ,` - Rename tab

## 📁 Available Layouts

### Default Layout
Simple single-pane layout with tab bar
```bash
zellij --layout default
```

### Development Layout  
Multi-pane setup with editor, terminal, and logs
```bash
zellij --layout dev
# or use alias: zjd
```

## 🔧 Configuration Files

- **Main Config**: `~/.config/zellij/config.kdl`
- **Theme**: `~/.config/zellij/themes/catppuccin-macchiato.kdl`
- **Layouts**: `~/.config/zellij/layouts/*.kdl`

## 🎨 Catppuccin Macchiato Theme

The theme uses these Catppuccin Macchiato colors:
- **Background**: #24273a (base)
- **Foreground**: #cad3f5 (text)  
- **Accent**: #8aadf4 (blue)
- **Success**: #a6da95 (green)
- **Warning**: #eed49f (yellow)
- **Error**: #ed8796 (red)

## 🐠 Fish Integration

### Auto-Start (Optional)
Zellij will auto-start when you open Fish unless:
- Already in a Zellij session (ZELLIJ env var set)
- SKIP_ZELLIJ environment variable is set
- Running in VS Code or other IDEs

### Disable Auto-Start
```bash
# Temporarily
SKIP_ZELLIJ=1 fish

# Permanently (add to Fish config)
set -Ux SKIP_ZELLIJ 1
```

## 📝 Usage Tips

### Command Output Management
1. **Use panes** to separate different commands
2. **Use scroll mode** (Ctrl+a [) to navigate command history  
3. **Use tabs** for different contexts/projects
4. **Use layouts** for consistent workspace setups

### Working with Alacritty
- Zellij works perfectly with Alacritty
- All mouse interactions supported
- Copy/paste works with Wayland clipboard
- Colors and fonts inherit from terminal

### Session Management
```bash
# Create named session
zellij --session work

# List all sessions
zj list-sessions

# Attach to specific session  
zj attach work

# Kill specific session
zj kill-session work
```

## 🛠 Troubleshooting

### If Zellij doesn't start:
1. Check configuration: `zellij setup --check`
2. Disable auto-start: `SKIP_ZELLIJ=1 fish`
3. Start manually: `zellij`

### If theme doesn't apply:
1. Check theme file exists: `ls ~/.config/zellij/themes/`
2. Verify config references theme correctly
3. Restart Zellij session

### If keybindings don't work:
1. Make sure you're using Ctrl+a prefix
2. Check if other apps capture the same keys
3. Try in different terminal/context

## 🎯 Next Steps

1. **Try the different layouts** to see what works for your workflow
2. **Customize keybindings** in `config.kdl` if needed  
3. **Create custom layouts** for specific projects
4. **Explore plugins** (file browser, session manager, etc.)

Enjoy your enhanced terminal experience with Zellij! 🚀
