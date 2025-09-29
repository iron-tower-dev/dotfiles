# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Repository Overview

This is a complete Arch Linux desktop environment setup featuring Hyprland (Wayland compositor) with Catppuccin Macchiato theming. The repository uses GNU Stow for dotfile management and provides automated installation scripts for a modern Linux desktop environment.

## Core Architecture

### Configuration Management
- **GNU Stow**: Primary tool for managing dotfile symlinks
- **Modular Structure**: Each application/tool has its own directory that mirrors the home directory structure
- **Backup System**: Automatic backup of existing configurations before deployment

### Package Management Philosophy
- **Mise**: Modern tool version manager (replaces asdf) for programming languages
- **Pacman + AUR**: System package management via scripts
- **UV**: Fast Python package installer and resolver (ALWAYS use instead of pip/pipx)
- **Layered Installation**: Core packages → AUR packages → Themes → System configuration → Dotfiles

### Key Components
- **Desktop**: Hyprland (Wayland compositor) + Waybar (status bar) + Rofi (launcher)
- **Display Manager**: SDDM with Catppuccin Macchiato theme and HiDPI support
- **Terminal**: Alacritty with Fish shell (default) + Nushell + Starship prompt
- **Editor**: Neovim with lazy.nvim, LSP, fuzzy finding, and Catppuccin theming
- **Development**: Git with 50+ aliases, SSH key management, GitHub CLI integration
- **Theming**: Catppuccin Macchiato across all applications (GTK, Qt, terminal, SDDM)

## Common Development Commands

### Initial Setup
```bash
# Full automated installation
./bootstrap.sh --full

# Install only specific components
./bootstrap.sh --packages    # Install packages only
./bootstrap.sh --dotfiles    # Deploy dotfiles only
./bootstrap.sh --themes      # Setup themes only
./bootstrap.sh --system      # Configure system services
./bootstrap.sh --git         # Setup Git configuration only
```

### Dotfiles Management
```bash
# Deploy specific configuration
stow -t ~ hyprland           # Deploy Hyprland config
stow -t ~ waybar             # Deploy Waybar config
stow -t ~ git                # Deploy Git config

# Remove configuration
stow -D -t ~ hyprland        # Remove Hyprland config

# Update configuration (remove and re-deploy)
stow -R -t ~ hyprland        # Restow Hyprland config

# Deploy all configurations
cd ~/dotfiles && for pkg in hyprland waybar alacritty rofi fish nushell starship mise zsh git neovim themes dunst; do [[ -d "$pkg" ]] && stow -t ~ "$pkg"; done
```

### Neovim Configuration Management
```bash
# Deploy Neovim configuration
stow -t ~ neovim             # Deploy Neovim config

# Edit configuration files
nvim ~/.config/nvim/init.lua # Edit main config
nvim ~/.config/nvim/lua/config/options.lua  # Edit options
nvim ~/.config/nvim/lua/config/keymaps.lua  # Edit keymaps

# Plugin management (within Neovim)
:Lazy                        # Open plugin manager
:Lazy update                 # Update all plugins
:Lazy clean                  # Remove unused plugins
:Lazy profile                # Profile plugin loading times

# LSP and diagnostics
:LspInfo                     # Check LSP server status
:LspRestart                  # Restart LSP servers
:checkhealth                 # Check Neovim health

# Key bindings for common tasks
# <leader>ff - Find files in project (fzf-lua)
# <leader>fg - Live grep in project
# <leader>fc - Find files in Neovim config
# <leader>e  - Toggle file explorer (oil.nvim)
# <leader>rc - Edit init.lua
```

### Development Tools Management (Mise)
```bash
# List available/installed tools
mise list                    # List installed versions
mise list-all node           # List all available Node.js versions
mise current                  # Show current tool versions

# Install and manage tool versions
mise install node@lts        # Install Node.js LTS
mise install python@3.12     # Install Python 3.12
mise install go@latest       # Install latest Go

# Project-specific versions
mise local node@18.19.0      # Use Node 18 in current project
mise local python@3.11       # Use Python 3.11 in current project

# Global version management
mise global node@lts         # Set global Node.js version
mise global python@3.12      # Set global Python version

# Maintenance
mise upgrade                 # Update all tools
mise prune                   # Clean unused versions
mise doctor                  # Check configuration
```

### UV Python Package Management (UV)
```bash
# Install Python packages globally (UV now uses system Python by default)
uv tool install waypaper     # Install GUI apps (gi/GTK access works with system Python)
uv tool install black       # Install dev tools globally
uv tool list                 # List globally installed tools

# Project-specific Python environment management
uv venv                                              # Create virtual environment
uv pip install package-name                         # Install packages in current venv
uv pip install -r requirements.txt                  # Install from requirements file
uv pip freeze                                        # List installed packages

# Fast package resolution and installation
uv add package-name                                  # Add package to project
uv remove package-name                               # Remove package from project
uv sync                                              # Sync environment with project dependencies

# Environment management
uv venv --python 3.12                               # Create venv with specific Python version
source .venv/bin/activate                            # Activate virtual environment (bash/zsh)
source .venv/bin/activate.fish                       # Activate virtual environment (fish)

# NEVER use pip or pipx - ALWAYS use uv for Python package management
```

### Git Workflow (Enhanced Configuration)
```bash
# Status and branch operations
git st                       # Enhanced status
git bra                      # List all branches
git cob feature-name         # Create and checkout branch
git bdm                      # Delete merged branches

# Commit operations
git cam "message"            # Add all and commit
git commend                  # Amend without editing message
git undo                     # Undo last commit (keep changes)

# Enhanced logging
git lg                       # Graph log all branches
git ll                       # Detailed log with stats
git last                     # Show last commit

# Safe push operations
git push-new                 # Push new branch with tracking
git pf                       # Push force with lease (safer)

# Stash management
git ss "description"         # Save stash with message
git sl                       # List stashes
git sp                       # Pop stash
```

### SDDM Display Manager Configuration
```bash
# Setup SDDM with Catppuccin Macchiato theme (automated)
./setup/system/setup-sddm.sh              # Install and configure SDDM

# Theme variant selection
./setup/system/sddm-theme-selector.sh     # Interactive theme selector
./setup/system/sddm-theme-selector.sh --list           # List available variants
./setup/system/sddm-theme-selector.sh --set blue       # Set specific variant
./setup/system/sddm-theme-selector.sh --current        # Show current theme

# Manual deployment
stow -t ~ sddm                    # Deploy SDDM config
sudo cp sddm/sddm.conf /etc/sddm.conf     # Apply system config

# Service management
sudo systemctl enable sddm.service        # Enable SDDM service
sudo systemctl status sddm.service         # Check SDDM status
sudo systemctl restart display-manager     # Restart display manager

# Theme verification
ls /usr/share/sddm/themes/        # List installed themes
sudo journalctl -u sddm.service   # Check SDDM logs
```

### Dunst Notification Configuration
```bash
# Deploy dunst configuration
stow -t ~ dunst                 # Deploy dunst config
pkill dunst && dunst &          # Restart dunst with new config

# Test notifications with different urgency levels
notify-send "Test Notification" "Normal notification with blue accent"
notify-send -u low "Low Priority" "Subtle notification with gray frame"
notify-send -u critical "Critical Alert" "Red notification that stays visible"

# Dunst control commands (for window manager keybindings)
dunstctl close                  # Close current notification
dunstctl close-all              # Close all notifications
dunstctl history-pop            # Show notification history
dunstctl context                # Show context menu

# Check dunst status
pgrep -fl dunst                 # Check if dunst is running
dunst -conf ~/.config/dunst/dunstrc -print  # Test configuration
```

### SSH and GitHub CLI Configuration
```bash
# Setup Git and GitHub CLI with SSH (automated)
./setup/system/setup-git.sh        # Configure Git + SSH keys + GitHub CLI

# Manual SSH setup
ssh-keygen -t ed25519 -C "email@example.com"  # Generate SSH key
eval $(ssh-agent -c) && ssh-add ~/.ssh/id_ed25519  # Add to agent
ssh -T git@github.com               # Test GitHub connection

# GitHub CLI configuration
gh auth login --git-protocol ssh --web  # Authenticate with SSH protocol
gh config set git_protocol ssh     # Configure CLI to use SSH
gh config get git_protocol          # Verify SSH protocol setting

# Git configuration for SSH
git config --global hub.protocol ssh      # Configure hub to use SSH
git remote set-url origin git@github.com:user/repo.git  # Switch remote to SSH

# Repository management
gh repo create my-repo --public --clone  # Create and clone with SSH
gh repo clone user/repo                   # Clone existing repo with SSH
```

### System Management
```bash
# Service management
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth
sudo systemctl status hyprland  # If using systemd user service

# Package management
sudo pacman -S package-name      # Install package
sudo pacman -Syu                 # Update system
sudo pacman -Rs package-name     # Remove package and deps

# AUR package management (if using AUR helper)
yay -S aur-package              # Install AUR package
yay -Syu                        # Update all packages including AUR
```

## Build and Testing

### Dotfiles Validation
```bash
# Test stow deployment (dry-run)
stow -n -v -t ~ package-name    # Show what would be linked

# Verify symlinks
ls -la ~/.config/hypr/          # Check Hyprland links
ls -la ~/.config/waybar/        # Check Waybar links

# Check for conflicts
stow -t ~ package-name 2>&1 | grep -i conflict
```

### Configuration Testing
```bash
# Test Hyprland configuration
hyprctl reload                  # Reload Hyprland config
waybar &                       # Test Waybar manually

# Test shell configurations
zsh -n ~/.zshrc                # Check Zsh syntax
fish -n ~/.config/fish/config.fish  # Check Fish syntax

# Test mise configuration
mise doctor                    # Validate mise setup
mise env                       # Show environment variables
```

### Theme Validation
```bash
# Test GTK themes
gtk-theme-switch catppuccin-macchiato-blue

# Test Qt themes (if using qt5ct/qt6ct)
qt5ct                          # Open Qt5 configuration tool
qt6ct                          # Open Qt6 configuration tool

# Verify font installation
fc-list | grep -i jetbrains    # Check JetBrains Mono font
```

## Development Environment Architecture

### Shell Environment Hierarchy
1. **Zsh** (`.zshrc`): Base shell with mise integration, modern aliases, completions
2. **Fish** (default): Modern shell with syntax highlighting, smart completions
3. **Nushell**: Alternative structured data shell for advanced data manipulation
4. **Starship**: Cross-shell prompt with Git integration and tool version display

### Tool Version Management Flow
1. **Global defaults**: Set via `mise global tool@version`
2. **Project-specific**: Override via `.mise.toml` in project root
3. **Environment variables**: Set via `[env]` section in `.mise.toml`
4. **Tasks**: Define common commands via `[tasks]` section

### Git Configuration Layers
1. **Global config**: `~/.gitconfig` (managed by dotfiles)
2. **Local overrides**: `~/.gitconfig.local` (machine-specific, created by setup)
3. **Repository-specific**: `.git/config` (per-project settings)

### SSH Key Management
- **Automated generation**: Ed25519 (recommended), RSA 4096, or ECDSA keys
- **GitHub integration**: Automatic upload via GitHub CLI
- **SSH agent**: Auto-configured for session persistence
- **Multi-key support**: Via `~/.ssh/config` host-specific configurations

## Project Structure

```
dotfiles/
├── bootstrap.sh              # Main installation script
├── setup/                    # Installation scripts
│   ├── packages/            # Package installation scripts
│   ├── system/              # System configuration scripts
│   └── themes/              # Theme setup scripts
├── hyprland/                # Hyprland compositor config
├── waybar/                  # Status bar configuration
├── alacritty/               # Terminal emulator config
├── rofi/                    # Application launcher config
├── fish/                    # Fish shell configuration
├── nushell/                 # Nushell configuration
├── starship/                # Starship prompt config
├── zsh/                     # Zsh shell configuration
├── git/                     # Git configuration with 50+ aliases
├── mise/                    # Programming language version manager
├── neovim/                  # Neovim configuration
│   └── .config/nvim/        # Complete Neovim setup with lazy.nvim
├── dunst/                   # Dunst notification daemon configuration
├── sddm/                    # SDDM display manager configuration
└── themes/                  # GTK/Qt theme configurations
```

## Rules Integration

### Mise Package Manager Priority
Based on user rules, this repository prioritizes the Mise package manager for programming language and tool version management. Always use Mise commands when working with Node.js, Python, Go, Rust, and other development tools rather than system package managers.

### UV Python Package Management
**CRITICAL**: NEVER use pip, pipx, or any other Python package managers. ALWAYS use uv for all Python package management tasks:
- Use `uv tool install` for global CLI tools (with system Python when GUI dependencies are needed)
- Use `uv pip install` for packages within virtual environments
- Use `uv venv` for creating virtual environments
- Use `uv add`/`uv remove` for project dependency management

### Angular Development Standards  
When working on Angular projects within this environment, follow modern Angular practices:
- Use input/output signals instead of legacy TypeScript decorators
- Follow Angular file naming conventions from the official style guide
- Leverage the pre-configured Angular CLI environment variables in mise configuration

## Gaming Setup and Management

This repository includes comprehensive gaming support with Steam, GE-Proton, and performance optimization tools that automatically detect and configure appropriate drivers for different graphics cards.

### Gaming Installation
```bash
# Full gaming setup (recommended)
./bootstrap.sh --gaming              # Install all gaming components

# Individual gaming components
./setup/packages/03-gaming-packages.sh       # Install Steam + drivers + tools
./setup/system/setup-ge-proton.sh install    # Install latest GE-Proton
stow -t ~ gaming                              # Deploy gaming configs
```

### GE-Proton Management
```bash
# Install/update to latest GE-Proton
./setup/system/setup-ge-proton.sh install
./setup/system/setup-ge-proton.sh update

# List installed versions
./setup/system/setup-ge-proton.sh list

# Remove specific version
./setup/system/setup-ge-proton.sh remove GE-Proton8-26

# Clean up old versions (keep latest 3)
./setup/system/setup-ge-proton.sh cleanup

# Show Steam configuration instructions
./setup/system/setup-ge-proton.sh instructions
```

### Steam Optimization
```bash
# Launch Steam with gaming optimizations
steam-gaming                    # Uses GameMode + MangoHud + performance tuning

# Manual Steam launch with optimizations
gamemoderun mangohud steam      # Enable GameMode and MangoHud overlay

# Steam with specific game
steam-gaming steam://rungameid/12345

# Check gaming tool availability
which gamemoderun               # GameMode for performance optimization
which mangohud                  # Performance overlay
nvtop                          # GPU monitoring (NVIDIA)
radeontop                      # GPU monitoring (AMD)
```


### Gaming Performance Configuration

#### MangoHud Overlay
```bash
# Deploy MangoHud configuration
stow -t ~ gaming                # Deploy gaming configs including MangoHud

# MangoHud controls (in-game)
# Shift+Right+F12 - Toggle overlay
# Shift+Left+F2   - Toggle logging
# Shift+Left+F4   - Reload config

# Test MangoHud
mangohud glxgears               # Test with simple OpenGL application
mangohud vkcube                 # Test with Vulkan application

# Custom MangoHud configuration
nvim ~/.config/MangoHud/MangoHud.conf
```

#### GameMode Performance
```bash
# Check GameMode status
gamemoded --status              # Check GameMode daemon status
gamemode --status               # Check if GameMode is active

# GameMode configuration
nvim ~/.config/gamemode.ini     # Edit GameMode settings

# Test GameMode
gamemoderun glxgears            # Test GameMode with simple application
```

### Graphics Driver Management

The gaming setup automatically detects your graphics hardware and installs appropriate drivers:

#### NVIDIA GPUs
```bash
# Check NVIDIA driver status
nvidia-smi                      # Show GPU status and driver version
nvtop                          # Real-time GPU monitoring
nvidia-settings                 # NVIDIA control panel

# NVIDIA optimizations (automatically applied)
# - Shader disk cache enabled
# - Threaded optimizations enabled
# - Persistent daemon enabled
```

#### AMD GPUs
```bash
# Check AMD driver status
lspci | grep VGA                # Show graphics hardware
radeontop                      # Real-time GPU monitoring

# AMD optimizations (automatically applied via environment variables)
# - RADV performance optimizations enabled
# - Vulkan drivers configured
# - Mesa optimizations applied
```

#### Intel GPUs
```bash
# Check Intel GPU status
intel_gpu_top                  # Real-time GPU monitoring
lspci | grep VGA               # Show graphics hardware

# Intel optimizations (automatically applied)
# - Vulkan drivers configured
# - Mesa optimizations applied
```

### Steam Configuration

#### Proton Settings in Steam
1. **Global Settings**:
   - Steam → Settings → Steam Play
   - Enable "Steam Play for supported titles"
   - Enable "Steam Play for all other titles"
   - Select GE-Proton version from dropdown

2. **Per-Game Settings**:
   - Right-click game → Properties → Compatibility
   - Check "Force the use of a specific Steam Play compatibility tool"
   - Select GE-Proton version

#### Common Launch Options
```bash
# Performance launch options (add to game properties)
gamemoderun mangohud %command%           # GameMode + MangoHud
PROTON_USE_WINED3D=1 %command%           # Use WineD3D instead of DXVK
PROTON_NO_ESYNC=1 %command%              # Disable esync
PROTON_NO_FSYNC=1 %command%              # Disable fsync
PROTON_FORCE_LARGE_ADDRESS_AWARE=1 %command%  # 4GB+ memory for 32-bit games

# Vulkan specific
VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/radeon_icd.x86_64.json %command%
```

### Gaming Directory Structure

```
gaming/
├── .config/
│   ├── environment.d/
│   │   └── gaming.conf          # Gaming environment variables
│   ├── MangoHud/
│   │   └── MangoHud.conf        # Performance overlay configuration
│   └── gamemode.ini             # GameMode performance settings
└── .local/bin/
    └── steam-gaming             # Optimized Steam launcher script
```

### Troubleshooting Gaming Issues

#### Steam Issues
```bash
# Steam won't start
rm -rf ~/.steam/steam/logs       # Clear Steam logs
steam --reset                    # Reset Steam client

# Missing 32-bit libraries
sudo pacman -S lib32-mesa lib32-vulkan-radeon lib32-nvidia-utils

# Audio issues in games
pulseaudio --kill && pulseaudio --start  # Restart PulseAudio

# Proton game crashes
# Check ProtonDB: https://www.protondb.com
# Try different Proton versions in game properties
```

#### Performance Issues
```bash
# Check GPU driver status
lspci -k | grep -A 2 -i vga     # Show graphics driver in use

# Monitor performance
mangohud glxgears               # Test OpenGL performance
vulkaninfo                      # Check Vulkan installation

# GameMode not working
sudo usermod -aG gamemode $USER  # Add user to gamemode group
# Logout and login again

# Check GameMode logs
journalctl --user -u gamemoded
```

#### GE-Proton Issues
```bash
# GE-Proton not showing in Steam
# 1. Restart Steam completely
# 2. Check installation path
ls ~/.steam/root/compatibilitytools.d/

# 3. Verify GE-Proton integrity
./setup/system/setup-ge-proton.sh list

# 4. Reinstall if needed
./setup/system/setup-ge-proton.sh install
```

#### Lutris Issues
```bash
# Lutris "No module named 'lutris'" error (common with mise Python)
# This happens when mise-managed Python conflicts with system Python
sudo cp /usr/bin/lutris /usr/bin/lutris.backup
sudo sed -i '1s|#!/usr/bin/env python3|#!/usr/bin/python3|' /usr/bin/lutris
sudo pacman -S --needed vulkan-tools python-protobuf

# Test Lutris
lutris --version
lutris --list-games

# Battle.net not showing in Lutris Sources
# Install protobuf support
sudo pacman -S python-protobuf
# Restart Lutris
```

#### Controller Issues
```bash
# Xbox controller setup
sudo modprobe xpadneo            # Load Xbox controller driver

# Steam controller configuration
# Steam → Settings → Controller → General Controller Settings
# Enable configuration for your controller type

# Test controller
jstest /dev/input/js0           # Test controller input
evtest /dev/input/event*        # Monitor all input events
```

## Virtualization Management (QEMU/KVM/libvirt)

This repository includes comprehensive virtualization support using QEMU/KVM with libvirt for managing virtual machines directly on your Arch Linux system.

### Virtualization Installation

```bash
# Full virtualization setup (recommended)
./bootstrap.sh --virt                    # Install all virtualization packages
stow -t ~ virt                            # Deploy virtualization configs

# Manual installation
./setup/packages/04-virt-packages.sh      # Install QEMU/KVM/libvirt packages

# Important: Log out and back in after installation for group permissions to take effect
```

### VM Management Commands

The `vm` command provides a unified CLI interface for managing virtual machines:

```bash
# List all VMs
vm list

# Start a VM
vm start ubuntu-vm

# Stop a VM (graceful shutdown)
vm stop ubuntu-vm

# Force stop a VM
vm force-stop ubuntu-vm

# Restart a VM
vm restart ubuntu-vm

# Show VM status
vm status ubuntu-vm

# Show detailed VM information
vm info ubuntu-vm

# Connect to VM console (Ctrl+] to disconnect)
vm console ubuntu-vm

# Delete a VM (with confirmation)
vm delete ubuntu-vm

# Clone a VM
vm clone ubuntu-vm ubuntu-vm-clone

# List virtual networks
vm networks

# List storage pools
vm pools
```

### Creating Virtual Machines

#### Quick VM Creation with Templates

```bash
# Interactive VM creation with predefined templates
vm-quick-create

# Available templates:
# 1. Ubuntu Desktop (4GB RAM, 2 CPUs, 30GB disk)
# 2. Ubuntu Server (2GB RAM, 2 CPUs, 20GB disk)
# 3. Fedora Workstation (4GB RAM, 2 CPUs, 30GB disk)
# 4. Arch Linux (2GB RAM, 2 CPUs, 25GB disk)
# 5. Windows 11 (8GB RAM, 4 CPUs, 60GB disk, UEFI + TPM 2.0)
# 6. Debian (2GB RAM, 2 CPUs, 20GB disk)
# 7. Custom (specify your own parameters)
```

#### Manual VM Creation

```bash
# Interactive VM creation
vm create

# Using virt-install directly
virt-install \
    --name my-vm \
    --memory 2048 \
    --vcpus 2 \
    --disk size=20 \
    --cdrom /path/to/iso \
    --os-variant detect=on \
    --graphics spice \
    --network network=default
```

### GUI VM Management

```bash
# Open virt-manager (graphical VM management tool)
virt-manager

# Open VM viewer for specific VM
virt-viewer ubuntu-vm
```

### Advanced VM Operations

#### VM Snapshots

```bash
# Create a snapshot
virsh snapshot-create-as ubuntu-vm snapshot1 "My snapshot description"

# List snapshots
virsh snapshot-list ubuntu-vm

# Restore a snapshot
virsh snapshot-revert ubuntu-vm snapshot1

# Delete a snapshot
virsh snapshot-delete ubuntu-vm snapshot1
```

#### Virtual Networks

```bash
# List networks
virsh net-list --all

# Start a network
virsh net-start default

# Create a new network
virsh net-define /path/to/network.xml
virsh net-start my-network
virsh net-autostart my-network

# Show network details
virsh net-info default
virsh net-dhcp-leases default     # Show DHCP leases
```

#### Storage Management

```bash
# List storage pools
virsh pool-list --all

# Create a new storage pool
virsh pool-define-as my-pool dir --target /path/to/pool
virsh pool-build my-pool
virsh pool-start my-pool
virsh pool-autostart my-pool

# List volumes in a pool
virsh vol-list default

# Default VM storage location
ls ~/VMs/                          # VM disk images stored here
```

### Virtualization Troubleshooting

#### Check Virtualization Support

```bash
# Check if CPU supports virtualization
grep -E '(vmx|svm)' /proc/cpuinfo

# Check KVM module
lsmod | grep kvm

# For Intel CPUs (should show kvm_intel)
# For AMD CPUs (should show kvm_amd)
```

#### Service and Permission Issues

```bash
# Check libvirtd service status
sudo systemctl status libvirtd
sudo systemctl restart libvirtd

# Check if you're in required groups
groups $USER | grep -E '(libvirt|kvm)'

# Add user to groups (done by setup script)
sudo usermod -aG libvirt,kvm $USER
# Log out and back in for changes to take effect
```

#### Network Issues

```bash
# Check default network
virsh net-info default

# If not active, start it
sudo virsh net-start default
sudo virsh net-autostart default

# Check network interfaces
ip addr show virbr0
```

#### VM Won't Start

```bash
# Check VM status and configuration
virsh dominfo vm-name
virsh dumpxml vm-name              # View VM XML definition

# View libvirtd logs
sudo journalctl -u libvirtd -f

# Check for file permission issues
ls -la ~/VMs/
sudo chown -R $USER:$USER ~/VMs/
```

#### Performance Optimization

```bash
# Enable nested virtualization (Intel)
echo "options kvm_intel nested=1" | sudo tee /etc/modprobe.d/kvm.conf

# Enable nested virtualization (AMD)
echo "options kvm_amd nested=1" | sudo tee /etc/modprobe.d/kvm.conf

# Reload KVM module (or reboot)
sudo modprobe -r kvm_intel  # or kvm_amd
sudo modprobe kvm_intel     # or kvm_amd

# Check if enabled
cat /sys/module/kvm_intel/parameters/nested  # Should show Y or 1
```

### Virtualization Directory Structure

```
virt/
├── .config/
│   └── libvirt/
│       ├── libvirt.conf         # Libvirt client configuration
│       └── templates/           # VM template storage
├── .local/bin/
│   ├── vm                       # Main VM management script
│   └── vm-quick-create          # Quick VM creation with templates
└── README.md                    # Detailed virtualization documentation
```

### Common VM Use Cases

```bash
# Development environment testing
vm-quick-create                    # Create test VMs for different OSes
vm snapshot create dev-vm clean    # Create clean state snapshots

# Windows testing
vm-quick-create                    # Select Windows 11 template
# Includes UEFI + TPM 2.0 for Windows 11 requirements

# Quick Linux testing
vm clone base-ubuntu test-ubuntu   # Clone existing VM
vm start test-ubuntu               # Test in isolated environment
vm delete test-ubuntu              # Clean up when done
```

## Troubleshooting

### Common Stow Issues
```bash
# Fix stow conflicts
stow -D -t ~ package-name     # Remove existing links
rm ~/.config/conflicting-file # Remove conflicting files manually
stow -t ~ package-name        # Re-deploy

# Fix permissions
chmod +x setup/system/*.sh    # Make scripts executable
chmod 600 ~/.ssh/id_*         # Fix SSH key permissions
```

### Mise Issues
```bash
# Reload mise environment
source ~/.zshrc               # Reload shell config
mise doctor                  # Check configuration

# Fix path issues
export PATH="$HOME/.local/share/mise/shims:$PATH"
mise reshim                  # Regenerate shims
```

### Python/Mise Conflicts (SRE Module Mismatch)
```bash
# If experiencing Python version conflicts between mise and system Python:
# 1. Remove Python from mise completely
mise uninstall python@3.12.1
sudo rm -rf ~/.local/share/mise/installs/python

# 2. Update mise configuration to comment out Python
# Edit ~/.mise.toml and change:
# python = "3.12.1" -> # python = "3.12.1"  # Use system Python

# 3. Use system Python (3.13+) and UV for package management
python3 --version                    # Should show system Python 3.13+
uv tool install black               # Use UV for global Python tools
uv pip install requests             # Use UV for project dependencies

# 4. GUI applications requiring GTK (like waypaper) work better with system Python
uv tool install waypaper            # Now uses system Python with GTK access
```

### Python Build Dependencies (AUR Packages)
```bash
# Fix AUR build failures with Python dependencies
./bootstrap.sh --python-deps

# Test Python build environment
python -c "import installer, poetry.core.masonry.api; print('Build deps OK')"

# Check system vs mise Python
which python                 # Should show mise Python if available
/usr/bin/python3 -c "import gi; print('System Python OK')"  # Test system packages

# Manually install build deps to mise Python
uv pip install installer poetry poetry-core build setuptools wheel

# Clean AUR build cache if issues persist
paru -Sc --noconfirm
```

### Hyprland/Waybar Issues
```bash
# Check Hyprland logs
journalctl --user -u hyprland

# Restart Waybar
pkill waybar && waybar &

# Check Wayland environment
echo $XDG_SESSION_TYPE       # Should show "wayland"
echo $WAYLAND_DISPLAY        # Should show wayland display
```

### Backup Recovery
```bash
# List available backups
ls ~/.config-backup-*

# Restore from backup
cp -r ~/.config-backup-*/hypr ~/.config/
```

## Environment-Specific Notes

- **Arch Linux**: Primary target distribution using pacman and AUR
- **Wayland**: Desktop environment requires Wayland-compatible applications
- **SSH Integration**: Automatic SSH key generation and GitHub CLI setup
- **Theming**: Catppuccin Macchiato applied consistently across all applications
- **Font Dependencies**: JetBrains Mono Nerd Font required for proper icon display
