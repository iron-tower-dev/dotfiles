#!/bin/bash

# Enhanced power menu script for Waybar
# Provides multiple power options with rofi/wofi integration

# Check if rofi or wofi is available
if command -v rofi &> /dev/null; then
    MENU="rofi -dmenu -i -p 'Power Menu'"
elif command -v wofi &> /dev/null; then
    MENU="wofi --dmenu --prompt 'Power Menu'"
else
    # Fallback to wlogout if available
    if command -v wlogout &> /dev/null; then
        wlogout
        exit 0
    else
        notify-send "Power Menu" "No menu application available (rofi/wofi/wlogout)"
        exit 1
    fi
fi

# Power options (with simple Unicode symbols)
options="󰌾 Lock\n󰤄 Sleep\n󰑓 Reboot\n Shutdown\n󰍃 Logout\n󰜗 Hibernate"

# Show menu and get selection
choice=$(echo -e "$options" | $MENU)

case "$choice" in
    "󰌾 Lock")
        swaylock --grace 0 &
        ;;
    "󰤄 Sleep")
        systemctl suspend
        ;;
    "󰑓 Reboot")
        systemctl reboot
        ;;
    "󰐥 Shutdown")
        systemctl poweroff
        ;;
    "󰍃 Logout")
        if pgrep -x "Hyprland" > /dev/null; then
            hyprctl dispatch exit
        elif pgrep -x "sway" > /dev/null; then
            swaymsg exit
        else
            pkill -KILL -u "$USER"
        fi
        ;;
    "󰜗 Hibernate")
        systemctl hibernate
        ;;
    *)
        # No selection made
        exit 0
        ;;
esac
