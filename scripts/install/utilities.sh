#!/bin/bash

# Get the directory of the current script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source helper file
source $SCRIPT_DIR/helper.sh

log_message "Installation started for utilities section"
print_info "\nStarting utilities setup..."

run_command "pacman -S --noconfirm waybar" "Install Waybar - Status Bar" "yes"

run_command "paru -S --sudoloop --noconfirm tofi" "Install Tofi - Application Launcher" "yes" "no"

run_command "pacman -S --noconfirm cliphist" "Install Cliphist - Clipboard Manager" "yes"

run_command "paru -S --sudoloop --noconfirm swww" "Install SWWW for wallpaper management" "yes" "no"
run_command "mkdir -p /home/$SUDO_USER/.config/assets/backgrounds && cp -r /home/$SUDO_USER/dotfiles/assets/backgrounds /home/$SUDO_USER/.config/assets/" "Copy sample wallpapers to assets directory (Recommended)" "yes" "no"

run_command "paru -S --sudoloop --noconfirm hyprpicker" "Install Hyprpicker - Color Picker" "yes" "no"

run_command "paru -S --sudoloop --noconfirm hyprlock" "Install Hyprlock - Screen Locker (Must)" "yes" "no"

run_command "paru -S --sudoloop --noconfirm wlogout" "Install Wlogout - Session Manager" "yes" "no"
run_command "cp -r /home/$SUDO_USER/dotfiles/configs/wlogout /home/$SUDO_USER/.config/ && cp -r /home/$SUDO_USER/dotfiles/assets/wlogout /home/$SUDO_USER/.config/assets/" "Copy Wlogout config and assets" "yes" "no"

run_command "paru -S --sudoloop --noconfirm grimblast" "Install Grimblast - Screenshot tool" "yes" "no"

run_command "paru -S --sudoloop --noconfirm hypridle" "Install Hypridle for idle management (Must)" "yes" "no"

echo "------------------------------------------------------------------------"
