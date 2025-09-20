# 🌸 Hyprland Dotfiles with Catppuccin Macchiato

A complete, automated Arch Linux desktop setup featuring Hyprland, Waybar, and beautiful Catppuccin Macchiato theming. Get a fully configured, modern Linux desktop in minutes!

## 🎨 Theme Preview

- **Theme**: Catppuccin Macchiato (Dark)
- **Compositor**: Hyprland (Wayland)
- **Status Bar**: Waybar with custom modules
- **Terminal**: Alacritty
- **Shells**: Fish (default) + Nushell with Starship prompt
- **Application Launcher**: Rofi
- **File Manager**: Thunar
- **Font**: JetBrains Mono Nerd Font

## ✨ Features

### 🖥️ Desktop Environment
- **Hyprland**: Modern Wayland compositor with smooth animations
- **Waybar**: Highly customizable status bar with system monitoring
- **Fish Shell**: Modern shell with syntax highlighting and smart completions (default)
- **Nushell**: Structured data shell with powerful data manipulation
- **Starship**: Beautiful, fast prompt with Git integration
- **Rofi**: Beautiful application launcher and window switcher
- **Catppuccin Macchiato**: Consistent theming across all applications

### 🎨 Theming
- **GTK 3/4**: Full Catppuccin theming for all GTK applications
- **Qt5/Qt6**: Kvantum-based theming for Qt applications
- **Cursors**: Catppuccin-themed cursor set
- **Icons**: Papirus Dark icon theme
- **Fonts**: JetBrains Mono Nerd Font for consistent typography

### 🔧 System Tools
- **Audio**: PipeWire with PulseAudio compatibility
- **Bluetooth**: Bluez with Blueman for GUI management
- **Network**: NetworkManager with GUI tools
- **Screenshots**: Grim and Slurp for Wayland screenshots
- **System Monitor**: btop for beautiful system monitoring
- **Media Control**: playerctl integration in waybar

### 💻 Development Environment
- **Git**: Modern git configuration with 50+ aliases and GitHub integration
- **SSH**: Automated SSH key generation and GitHub setup
- **Mise**: Programming language version manager (replaces asdf)
- **GitHub CLI**: Seamless GitHub integration and authentication

## 🚀 Quick Start

### Prerequisites
- Fresh Arch Linux installation
- Internet connection
- User with sudo privileges

### One-Command Installation

```bash
# Clone the dotfiles repository
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Run the automated setup
chmod +x bootstrap.sh
./bootstrap.sh
```

The script will guide you through an interactive installation process.

## 📦 Installation Options

### Interactive Installation (Recommended)
```bash
./bootstrap.sh
```
Choose from:
1. **Full installation** - Complete setup for new systems
2. **Install packages only** - Just install required software
3. **Deploy dotfiles only** - Apply configurations using Stow
4. **Setup themes only** - Apply theming configurations
5. **Configure system only** - Set up services and permissions

### Command Line Installation
```bash
# Full automated installation
./bootstrap.sh --full

# Install packages only
./bootstrap.sh --packages

# Deploy dotfiles only
./bootstrap.sh --dotfiles

# Setup themes only
./bootstrap.sh --themes

# Configure system only
./bootstrap.sh --system

# Setup git only
./bootstrap.sh --git

# Show help
./bootstrap.sh --help
```

## 🏗️ What Gets Installed

### Core Packages
- Hyprland, Waybar, Alacritty, Rofi, Thunar
- Fish shell (default) and Nushell with Starship prompt
- Modern CLI tools (exa, bat, fd, ripgrep, fzf)
- PipeWire audio stack
- NetworkManager and Bluetooth
- Essential development tools
- JetBrains Mono Nerd Font

### AUR Packages
- Catppuccin GTK themes and cursors
- Kvantum Qt theming
- Additional system tools

### Configurations
- Hyprland with optimized settings and animations
- Waybar with custom modules (CPU, memory, network, etc.)
- Qt and GTK theming configurations
- System service configurations

## 🛠️ Manual Configuration Management

### Using GNU Stow
The dotfiles are organized using GNU Stow for easy management:

```bash
# Deploy a specific configuration
stow -t ~ hyprland

# Remove a configuration
stow -D -t ~ hyprland

# Restow (update) a configuration
stow -R -t ~ hyprland
```

### Directory Structure
```
dotfiles/
├── bootstrap.sh           # Main setup script
├── README.md              # This file
├── hyprland/              # Hyprland configuration
│   └── .config/hypr/
├── waybar/                # Waybar configuration
│   └── .config/waybar/
├── alacritty/             # Terminal configuration
│   └── .config/alacritty/
├── rofi/                  # Application launcher
│   └── .config/rofi/
├── fish/                  # Fish shell configuration (default)
│   └── .config/fish/
├── nushell/               # Nushell configuration  
│   └── .config/nushell/
├── starship/              # Starship prompt configuration
│   └── .config/starship.toml
├── themes/                # GTK/Qt theme configurations
│   ├── .config/gtk-3.0/
│   ├── .config/gtk-4.0/
│   ├── .config/qt5ct/
│   ├── .config/qt6ct/
│   ├── .config/Kvantum/
│   └── .gtkrc-2.0
├── zsh/                   # Shell configuration
│   └── .zshrc
├── git/                   # Git configuration
│   ├── .gitconfig
│   └── README.md
├── mise/                  # Programming language version manager
│   ├── .config/mise/
│   ├── .mise.toml
│   └── README.md
└── setup/                 # Installation scripts
    ├── packages/
    ├── themes/
    └── system/
```

## ⌨️ Key Bindings

### Window Management
- `Super + Enter` - Open terminal
- `Super + Q` - Close window
- `Super + Space` - Application launcher
- `Super + E` - File manager
- `Super + T` - Toggle floating
- `Super + M` - Exit Hyprland

### Workspaces
- `Super + 1-5` - Switch to workspace 1-5
- `Super + Shift + 1-5` - Move window to workspace 1-5

### System
- `Super + L` - Lock screen
- `Print` - Screenshot area
- `Alt + Print` - Screenshot window

## 🎨 Customization

### Changing Colors
The setup uses Catppuccin Macchiato by default. To change variants:

1. **GTK Theme**: Edit `themes/.config/gtk-3.0/settings.ini`
2. **Kvantum Theme**: Edit `themes/.config/Kvantum/kvantum.kvconfig`
3. **Hyprland Colors**: Edit `hyprland/.config/hypr/hyprland.conf`

### Adding New Configurations
1. Create a new directory in the dotfiles folder
2. Structure it like a home directory (use `.config/` subdirectories)
3. Add the package name to `STOW_PACKAGES` in `bootstrap.sh`
4. Run `stow -t ~ package-name` to deploy

### Waybar Customization
- Configuration: `waybar/.config/waybar/config`
- Styling: `waybar/.config/waybar/style.css`
- Scripts: `waybar/.config/waybar/scripts/`

## 🐛 Troubleshooting

### Installation Issues
- Ensure you're running on Arch Linux
- Check internet connection for package downloads
- Run with `bash -x bootstrap.sh` for verbose output

### Theme Not Applied
- Restart applications after installation
- For Qt apps, ensure environment variables are set
- Check `~/.profile` for environment variables

### Backup Recovery
If something goes wrong, your original configurations are backed up:
```bash
ls ~/.config-backup-*
# Restore from backup if needed
cp -r ~/.config-backup-*/config/hypr ~/.config/
```

## 🐍 Using Nushell

Nushell is included as an alternative shell with powerful structured data features:

### Launching Nushell
```bash
# Start Nushell from any shell
nu

# Or launch directly with terminal
alacritty -e nu
```

### Key Nushell Features
- **Structured Data**: Work with JSON, CSV, XML natively
- **Powerful Pipelines**: Filter and transform data with ease
- **Fish Completions**: Uses Fish completions for external commands
- **Beautiful Tables**: Automatic table formatting for data
- **Modern Commands**: Enhanced Git utilities and system monitoring

### Useful Nushell Commands
```nushell
# System monitoring with structured output
ps | where cpu > 50 | sort-by cpu
memtop -n 5
diskinfo

# Git utilities with data manipulation
gst | where staged == true
glg -n 10 | where message =~ "fix"

# File operations with data
ls | where size > 1MB | sort-by size
filetypes | first 5
```

### Configuration
- **Main config**: `~/.config/nushell/config.nu`
- **Environment**: `~/.config/nushell/env.nu`
- **Theme**: `~/.config/nushell/themes/catppuccin_macchiato.nu`
- **Scripts**: `~/.config/nushell/scripts/`

## 🔧 Updates

To update your dotfiles:

1. Pull the latest changes:
   ```bash
   cd ~/dotfiles
   git pull
   ```

2. Redeploy configurations:
   ```bash
   ./bootstrap.sh --dotfiles
   ```

3. Update themes if needed:
   ```bash
   ./bootstrap.sh --themes
   ```

## 🤝 Contributing

Feel free to fork this repository and customize it for your needs! If you have improvements or bug fixes:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- [Catppuccin](https://github.com/catppuccin/catppuccin) - Beautiful pastel theme
- [Hyprland](https://hyprland.org/) - Amazing Wayland compositor
- [Waybar](https://github.com/Alexays/Waybar) - Highly customizable status bar
- [GNU Stow](https://www.gnu.org/software/stow/) - Symlink farm manager

---

**Enjoy your beautiful new desktop! 🌸**
