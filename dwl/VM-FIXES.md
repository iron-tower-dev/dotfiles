# dwl VM Fixes

## Issues Found
1. ❌ bemenu has incompatible options (older version)
2. ❌ No status bar visible at top
3. ✅ Most keybindings work (Alt+Shift+Return, Alt+j/k, Alt+1/2)

## Fix 1: Update dwl-launcher script

**In the VM**, edit the launcher:

```bash
nvim ~/.local/bin/dwl-launcher
```

Replace the content with this simpler version:

```bash
#!/usr/bin/env bash
# Simple application launcher for dwl - compatible version

bemenu-run -i -l 10 -p "Run:"
```

Make it executable:
```bash
chmod +x ~/.local/bin/dwl-launcher
```

Test it:
```bash
~/.local/bin/dwl-launcher
```

## Fix 2: Test bemenu directly

Try the simplest bemenu command:
```bash
ls /usr/bin | bemenu
```

If this shows a menu, bemenu is working.

## Fix 3: Status Bar Issue

The status bar not showing is more serious. This means dwl was compiled without proper bar support or using default config.

### Quick test - check if dwl has somebar support:

In the VM, check what dwl binary is actually running:
```bash
which dwl
file $(which dwl)
```

### The bar might be disabled in the default config

dwl's default config might have the bar disabled. To check:

1. Look for the dwl source that was built:
```bash
# If it was built from source, config would be in:
ls -la /tmp/dwl-build*/config.h 2>/dev/null

# Or check if using AUR package default config
pacman -Ql dwl-git | grep config
```

2. The bar is controlled by `slstatus` or similar in dwl config.

## Fix 4: Rebuild dwl with proper config

Since there's no visible bar, dwl is using completely default config. You need to:

### Option A: Use dwl-rebuild script

First check if it exists:
```bash
ls -la ~/.local/bin/dwl-rebuild
```

If it exists, run it to get default config:
```bash
~/.local/bin/dwl-rebuild
```

### Option B: Manual rebuild (if dwl-rebuild doesn't exist)

```bash
# Clone dwl
cd /tmp
git clone https://codeberg.org/dwl/dwl.git
cd dwl

# Build with default config
make clean
make
sudo make install

# Check if bar appears after rebuild
```

## Fix 5: Verify foot is set as terminal

The reason Alt+Shift+Return works is probably because foot is the default. Verify:

```bash
which foot
```

## Quick Working Setup

For now, to use dwl productively:

**Open terminal:**
```
Alt + Shift + Return
```

**Switch windows:**
```
Alt + j (next)
Alt + k (previous)
```

**Switch workspaces:**
```
Alt + 1, 2, 3, etc.
```

**Launch apps manually:**
```bash
# In foot terminal:
firefox &
thunar &
etc.
```

**Run bemenu launcher:**
```bash
ls /usr/bin | bemenu | xargs -I {} {} &
```

## Summary

The core issue is that dwl is using a completely vanilla default config without:
- Status bar enabled
- Proper bemenu configuration
- Custom keybindings

You have two options:
1. Rebuild dwl with proper config (dwl-rebuild or manual)
2. Live with vanilla dwl and use terminals to launch apps

The setup script built dwl from source but didn't apply any custom configuration, so you got the upstream defaults.