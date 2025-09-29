#!/usr/bin/env bash
# dwl autostart script
# Launches slstatus for the status bar and sets up the environment

# Set environment variables for Wayland
export XDG_CURRENT_DESKTOP=dwl
export XDG_SESSION_TYPE=wayland
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM=wayland
export SDL_VIDEODRIVER=wayland
export _JAVA_AWT_WM_NONREPARENTING=1

# Use software rendering if in VM or if GPU access fails
# This fixes EGL/GBM errors in VMs
export WLR_RENDERER=pixman

# Kill any existing instances
killall -q slstatus
killall -q swaybg

# Wait for processes to shut down
while pgrep -x slstatus >/dev/null; do sleep 0.1; done
while pgrep -x swaybg >/dev/null; do sleep 0.1; done

# Start slstatus in background - dwl will read from it
# Note: This script should NOT be called directly
# The session file will handle piping slstatus to dwl
slstatus &

# Set wallpaper if available (suppress EGL warnings)
if [ -f "$HOME/.config/wallpaper.jpg" ]; then
    swaybg -i "$HOME/.config/wallpaper.jpg" -m fill 2>/dev/null &
elif [ -f "$HOME/.config/hypr/wallpaper.jpg" ]; then
    swaybg -i "$HOME/.config/hypr/wallpaper.jpg" -m fill 2>/dev/null &
else
    # Fallback to solid color (Catppuccin Macchiato base)
    swaybg -c "#24273a" 2>/dev/null &
fi

# Optional: Start notification daemon (if dunst is installed)
# Suppress protocol warning - dwl doesn't support all wayland protocols
if command -v dunst &> /dev/null; then
    killall -q dunst
    while pgrep -x dunst >/dev/null; do sleep 0.1; done
    dunst 2>/dev/null &
fi

# Optional: Start clipboard manager
if command -v wl-paste &> /dev/null && command -v cliphist &> /dev/null; then
    wl-paste --watch cliphist store &
fi