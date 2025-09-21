#!/bin/bash

# Wallpaper Wrapper Script
# Ensures clean JSON output for Waybar by capturing stderr separately

set -euo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
WALLPAPER_SCRIPT="$SCRIPT_DIR/wallpaper.sh"

# Function to output clean JSON for Waybar
output_clean_json() {
    local icon="󰸉"
    local tooltip="Click to set random wallpaper"
    local class="wallpaper"
    
    # Check if swww daemon is running
    if ! pgrep -x swww-daemon > /dev/null 2>&1; then
        class="wallpaper-inactive"
        tooltip="Wallpaper daemon not running - click to start and set wallpaper"
    fi
    
    # Output clean JSON
    cat << EOF
{"text":"$icon","tooltip":"$tooltip","class":"$class"}
EOF
}

# Handle different commands
case "${1:-status}" in
    "status"|"")
        output_clean_json
        ;;
    "set"|"random")
        # Execute wallpaper set command, but don't output to stdout
        "$WALLPAPER_SCRIPT" set >/dev/null 2>&1 &
        ;;
    *)
        # Pass through other commands
        "$WALLPAPER_SCRIPT" "$@"
        ;;
esac
