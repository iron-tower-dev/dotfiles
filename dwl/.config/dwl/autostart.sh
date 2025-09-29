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

# Kill any existing instances
killall -q slstatus
killall -q swaybg

# Wait for processes to shut down
while pgrep -x slstatus >/dev/null; do sleep 0.1; done
while pgrep -x swaybg >/dev/null; do sleep 0.1; done

# Start slstatus (status bar)
# dwl reads from stdin for the status bar
slstatus 2>&1 | dwl &

# Set wallpaper if available
if [ -f "$HOME/.config/wallpaper.jpg" ]; then
    swaybg -i "$HOME/.config/wallpaper.jpg" -m fill &
elif [ -f "$HOME/.config/hypr/wallpaper.jpg" ]; then
    swaybg -i "$HOME/.config/hypr/wallpaper.jpg" -m fill &
else
    # Fallback to solid color (Catppuccin Macchiato base)
    swaybg -c "#24273a" &
fi

# Optional: Start notification daemon (if dunst is installed)
if command -v dunst &> /dev/null; then
    killall -q dunst
    while pgrep -x dunst >/dev/null; do sleep 0.1; done
    dunst &
fi

# Optional: Start clipboard manager
if command -v wl-paste &> /dev/null && command -v cliphist &> /dev/null; then
    wl-paste --watch cliphist store &
fi