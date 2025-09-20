#!/usr/bin/env bash

# Rofi Launcher Script with Catppuccin Macchiato Theme
# Usage: ./launcher.sh [mode]

# Default mode
MODE="${1:-drun}"

# Color scheme from Catppuccin Macchiato
BG="#24273a"
FG="#cad3f5"
SELECT="#5b6078"
BLUE="#8aadf4"

case $MODE in
    "apps"|"drun")
        rofi -show drun -theme ~/.config/rofi/config.rasi
        ;;
    "run"|"cmd")
        rofi -show run -theme ~/.config/rofi/config.rasi
        ;;
    "window"|"win")
        rofi -show window -theme ~/.config/rofi/config.rasi
        ;;
    "ssh")
        rofi -show ssh -theme ~/.config/rofi/config.rasi
        ;;
    "files"|"filebrowser")
        rofi -show filebrowser -theme ~/.config/rofi/config.rasi
        ;;
    "combi"|"all")
        rofi -show combi -theme ~/.config/rofi/config.rasi
        ;;
    "power"|"powermenu")
        # Power menu with custom options
        options="⏻ Shutdown\\n⏾ Suspend\\n⏯ Hibernate\\n↻ Reboot\\n⇠ Logout"
        chosen=$(echo -e "$options" | rofi -dmenu -p "Power Menu" -theme ~/.config/rofi/config.rasi)
        
        case $chosen in
            "⏻ Shutdown")
                systemctl poweroff
                ;;
            "⏾ Suspend")
                systemctl suspend
                ;;
            "⏯ Hibernate")
                systemctl hibernate
                ;;
            "↻ Reboot")
                systemctl reboot
                ;;
            "⇠ Logout")
                # Adjust this based on your window manager
                if command -v i3-msg &> /dev/null; then
                    i3-msg exit
                elif command -v hyprctl &> /dev/null; then
                    hyprctl dispatch exit
                elif command -v swaymsg &> /dev/null; then
                    swaymsg exit
                else
                    pkill -KILL -u "$USER"
                fi
                ;;
        esac
        ;;
    "clipboard"|"clip")
        # Clipboard manager (requires clipmenu or similar)
        if command -v clipmenu &> /dev/null; then
            clipmenu -p "Clipboard" -theme ~/.config/rofi/config.rasi
        else
            echo "Clipboard manager not found. Install clipmenu or similar."
        fi
        ;;
    "calc"|"calculator")
        rofi -show calc -modi calc -no-show-match -no-sort -theme ~/.config/rofi/config.rasi
        ;;
    "emoji")
        # Emoji picker (requires rofi-emoji or similar)
        if command -v rofi-emoji &> /dev/null; then
            rofi-emoji -theme ~/.config/rofi/config.rasi
        else
            echo "Emoji picker not found. Install rofi-emoji."
        fi
        ;;
    "help"|"-h"|"--help")
        echo "Rofi Launcher Script"
        echo "Usage: $0 [mode]"
        echo ""
        echo "Available modes:"
        echo "  apps, drun      - Application launcher (default)"
        echo "  run, cmd        - Command runner"
        echo "  window, win     - Window switcher"
        echo "  ssh             - SSH connection menu"
        echo "  files           - File browser"
        echo "  combi, all      - Combined mode (apps + run + windows)"
        echo "  power           - Power menu (shutdown, reboot, etc.)"
        echo "  clipboard, clip - Clipboard history"
        echo "  calc            - Calculator"
        echo "  emoji           - Emoji picker"
        echo "  help            - Show this help"
        ;;
    *)
        echo "Unknown mode: $MODE"
        echo "Use '$0 help' to see available modes"
        exit 1
        ;;
esac
