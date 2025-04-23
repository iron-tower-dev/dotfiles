#!/bin/bash

# Get the directory of the current script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source helper file
source $SCRIPT_DIR/helper.sh

log_message "Installation started for common section"
print_info "\nStarting common applications setup..."

run_command "pacman -S --noconfirm stow" "Install Gnu Stow (Must)/needed for symlinking config files" "yes"

run_command "pacman -S --noconfirm emacs" "Install Emacs" "yes"

run_command "pacman -S --noconfirm nushell zsh fzf ripgrep eza zoxide btop unzip fastfetch" "Install additional shells and helpful shell utils (Recommend)" "yes"

run_command "paru -S --sudoloop --noconfirm oh-my-posh" "Install Oh My Posh" "yes" "yes"

echo "------------------------------------------------------------------------"
