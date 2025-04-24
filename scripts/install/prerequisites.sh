#!/bin/bash

# Get the current directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source helper file
source $SCRIPT_DIR/helper.sh

log_message "Installation started for prerequisites"
print_info "\nInstalling prerequisites..."

run_command "pacman -Syyu --noconfirm" "Update package database and upgrade packages (Recommended)" "yes" #no

if run_command "pacman -S --noconfirm --needed git base-devel" "Install Paru (Must)/Breaks the script" "yes"; then # 
    run_command "git clone https://aur.archlinux.org/paru.git && cd paru" "Clone Paru (Must)/Breaks the script" "no" "no" 
    run_command "makepkg --noconfirm -si && cd .. # builds with makepkg" "Build Paru (Must)/Breaks the script" "no" "no" 
fi

git config --global user.name "Derrick Southworth"
git config --global user.email derricksouthworth@gmail.com
git config --global init.defaultBranch main

run_command "pacman -S --noconfirm pipewire wireplumber pamixer brightnessctl" "Configuring audio and brightness (Recommended)" "yes" 

run_command "pacman -S --noconfirm ttf-cascadia-code-nerd ttf-cascadia-mono-nerd ttf-fira-code ttf-fira-mono ttf-fira-sans ttf-firacode-nerd ttf-iosevka-nerd ttf-iosevkaterm-nerd ttf-jetbrains-mono-nerd ttf-jetbrains-mono ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono" "Installing Nerd Fonts and Symbols (Recommended)" "yes" 

run_command "pacman -S --noconfirm sddm && systemctl enable sddm.service" "Install and enable SDDM (Recommended)" "yes"

run_command "pacman -S --noconfirm vivaldi" "Install Vivaldi Browser" "yes"

run_command "paru -S sudoloop --noconfirm thorium-browser-bin" "Install Thorium Browser" "yes" "no"

run_command "pacman -S --noconfirm ghostty" "Install Ghostty (Recommended)" "yes"

run_command "pacman -S --noconfirm neovim" "Install NeoVim" "yes"

run_command "pacman -S --noconfirm tar" "Install tar for extracting files (Must)/needed for copying themes" "yes"

echo "------------------------------------------------------------------------"
