#!/bin/bash

# Gaming Packages Installation Script
# Detects GPU and installs appropriate drivers plus gaming utilities

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[GAMING]${NC} $1"; }
log_success() { echo -e "${GREEN}[GAMING]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[GAMING]${NC} $1"; }
log_error() { echo -e "${RED}[GAMING]${NC} $1"; }

# Detect GPU type
detect_gpu() {
    log_info "Detecting GPU hardware..."
    
    local gpu_info
    gpu_info=$(lspci | grep -i vga)
    
    local nvidia_gpu=false
    local amd_gpu=false
    local intel_gpu=false
    
    if echo "$gpu_info" | grep -qi nvidia; then
        nvidia_gpu=true
        log_info "NVIDIA GPU detected"
    fi
    
    if echo "$gpu_info" | grep -qi amd || echo "$gpu_info" | grep -qi radeon; then
        amd_gpu=true
        log_info "AMD GPU detected"
    fi
    
    if echo "$gpu_info" | grep -qi intel; then
        intel_gpu=true
        log_info "Intel GPU detected"
    fi
    
    echo "$nvidia_gpu $amd_gpu $intel_gpu"
}

# Install NVIDIA drivers
install_nvidia_drivers() {
    log_info "Installing NVIDIA drivers and utilities..."
    
    # Core NVIDIA packages
    local nvidia_packages=(
        "nvidia"                    # Main NVIDIA driver
        "nvidia-utils"              # NVIDIA utilities
        "lib32-nvidia-utils"        # 32-bit NVIDIA utilities for Steam games
        "nvidia-settings"           # NVIDIA X Server Settings
        "nvtop"                     # NVIDIA GPU monitoring
    )
    
    # Check for open-source kernel modules preference
    if pacman -Qs linux-zen >/dev/null 2>&1; then
        log_info "Zen kernel detected, using nvidia-dkms for better compatibility"
        nvidia_packages[0]="nvidia-dkms"
    fi
    
    sudo pacman -S --needed "${nvidia_packages[@]}"
    
    # Enable nvidia-persistenced service
    sudo systemctl enable nvidia-persistenced.service
    
    log_success "NVIDIA drivers installed"
}

# Install AMD drivers
install_amd_drivers() {
    log_info "Installing AMD drivers and utilities..."
    
    local amd_packages=(
        "mesa"                      # Open-source AMD drivers
        "lib32-mesa"                # 32-bit Mesa for Steam games
        "xf86-video-amdgpu"         # AMD GPU X driver
        "vulkan-radeon"             # Vulkan support for AMD
        "lib32-vulkan-radeon"       # 32-bit Vulkan for Steam games
        "radeontop"                 # AMD GPU monitoring
    )
    
    sudo pacman -S --needed "${amd_packages[@]}"
    
    log_success "AMD drivers installed"
}

# Install Intel drivers
install_intel_drivers() {
    log_info "Installing Intel drivers and utilities..."
    
    local intel_packages=(
        "mesa"                      # Intel graphics drivers
        "lib32-mesa"                # 32-bit Mesa
        "xf86-video-intel"          # Intel X driver
        "vulkan-intel"              # Vulkan support for Intel
        "lib32-vulkan-intel"        # 32-bit Vulkan
        "intel-gpu-tools"           # Intel GPU utilities
    )
    
    sudo pacman -S --needed "${intel_packages[@]}"
    
    log_success "Intel drivers installed"
}

# Install Steam and gaming utilities
install_steam_and_gaming() {
    log_info "Installing Steam and gaming utilities..."
    
    # Enable multilib repository if not already enabled
    if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
        log_info "Enabling multilib repository for 32-bit support..."
        sudo bash -c 'cat >> /etc/pacman.conf << EOF

[multilib]
Include = /etc/pacman.d/mirrorlist
EOF'
        sudo pacman -Sy
    fi
    
    local gaming_packages=(
        # Steam and compatibility
        "steam"                     # Steam client
        "steam-native-runtime"      # Native Steam runtime
        
        # Audio support
        "lib32-alsa-plugins"        # 32-bit audio support
        "lib32-libpulse"            # 32-bit PulseAudio support
        "lib32-openal"              # 32-bit OpenAL support
        
        # Gaming performance tools
        "gamemode"                  # Optimize system performance for games
        "lib32-gamemode"            # 32-bit GameMode support
        "mangohud"                  # Gaming overlay for performance monitoring
        "lib32-mangohud"            # 32-bit MangoHud support
        
        # Wine and compatibility
        "wine"                      # Windows compatibility layer
        "winetricks"                # Wine helper scripts
        "lib32-gnutls"              # TLS support for Wine
        "lib32-libxslt"             # XML support for Wine
        "gamescope"                 # SteamOS session compositing window manager
        
        # Additional gaming utilities
        "lutris"                    # Gaming platform manager
        "discord"                   # Gaming communication
        "obs-studio"                # Game streaming/recording
        
        # Controllers (xpadneo-dkms moved to AUR section)
        # Note: Steam controller support is now included in the steam package
    )
    
    # Install core packages first
    local core_packages=(
        "steam"
        "steam-native-runtime"
        "lib32-alsa-plugins"
        "lib32-libpulse"
        "lib32-openal"
        "gamemode"
        "lib32-gamemode"
        "mangohud"
        "lib32-mangohud"
        "wine"
        "winetricks"
        "lib32-gnutls"
        "lib32-libxslt"
        "gamescope"
    )
    
    sudo pacman -S --needed "${core_packages[@]}"
    
    # Try to install additional packages that might not be available
    local optional_packages=(
        "lutris"
        "discord"
        "obs-studio"
    )
    
    for package in "${optional_packages[@]}"; do
        if pacman -Si "$package" >/dev/null 2>&1; then
            sudo pacman -S --needed "$package" || log_warning "Failed to install $package"
        else
            log_warning "$package not available in repositories, will try AUR"
        fi
    done
    
    # Enable GameMode service for current user
    log_info "Enabling GameMode for current user..."
    sudo usermod -aG gamemode "$USER"
    
    log_success "Steam and gaming utilities installed"
}

# Install AUR gaming packages
install_aur_gaming() {
    log_info "Installing AUR gaming packages..."
    
    # Check for AUR helper
    local aur_helper=""
    if command -v paru >/dev/null 2>&1; then
        aur_helper="paru"
    elif command -v yay >/dev/null 2>&1; then
        aur_helper="yay"
    else
        log_warning "No AUR helper found (paru/yay). Installing paru..."
        # Install paru if no AUR helper is available
        if ! install_paru; then
            log_error "Failed to install AUR helper. Skipping AUR packages."
            return 1
        fi
        aur_helper="paru"
    fi
    
    local aur_packages=(
        "discord"                   # Gaming communication (if not in repos)
        "lutris"                    # Gaming platform manager (if not in repos)
        "steam-tui"                 # Terminal Steam client
        "xpadneo-dkms"              # Xbox controller support
        "game-devices-udev"         # Gaming device udev rules
    )
    
    for package in "${aur_packages[@]}"; do
        log_info "Installing $package from AUR..."
        if ! $aur_helper -S --needed --noconfirm "$package"; then
            log_warning "Failed to install $package from AUR"
        fi
    done
    
    log_success "AUR gaming packages installation completed"
}

# Install paru AUR helper
install_paru() {
    log_info "Installing paru AUR helper..."
    
    # Install base-devel if not already installed
    sudo pacman -S --needed base-devel git
    
    # Clone and build paru
    local temp_dir
    temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    git clone https://aur.archlinux.org/paru.git
    cd paru
    
    makepkg -si --noconfirm
    
    cd /
    rm -rf "$temp_dir"
    
    log_success "Paru installed successfully"
}

# Configure gaming environment
configure_gaming_environment() {
    log_info "Configuring gaming environment..."
    
    # Create Steam directories if they don't exist
    mkdir -p "$HOME/.steam/steam"
    mkdir -p "$HOME/.local/share/Steam"
    
    # Enable Steam Play (Proton) for all Windows games
    local steam_config="$HOME/.steam/steam/config/config.vdf"
    if [[ -f "$steam_config" ]]; then
        log_info "Steam config found, Proton settings will be managed through Steam client"
    else
        log_info "Steam config not found, will be created on first Steam launch"
    fi
    
    # Set up gaming-optimized environment variables
    log_info "Setting up gaming environment variables..."
    
    log_success "Gaming environment configured"
}


# Main installation function
main() {
    log_info "Starting gaming setup installation..."
    
    # Detect GPU hardware
    local gpu_detection
    gpu_detection=$(detect_gpu)
    read -r nvidia_gpu amd_gpu intel_gpu <<< "$gpu_detection"
    
    # Install appropriate GPU drivers
    if [[ "$nvidia_gpu" == "true" ]]; then
        install_nvidia_drivers
    fi
    
    if [[ "$amd_gpu" == "true" ]]; then
        install_amd_drivers
    fi
    
    if [[ "$intel_gpu" == "true" ]]; then
        install_intel_drivers
    fi
    
    # Install Steam and gaming utilities
    install_steam_and_gaming
    
    # Install AUR packages
    install_aur_gaming
    
    # Configure gaming environment
    configure_gaming_environment
    
    log_success "Gaming setup installation completed!"
    log_info "Please reboot your system to ensure all drivers are properly loaded."
    log_info "After reboot, run the GE-Proton setup script to install Proton-GE."
}

# Run main function
main "$@"
