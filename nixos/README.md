# NixOS Configuration with Hyprland and Catppuccin

This directory contains a complete NixOS configuration using flakes and Home Manager, designed to complement the existing Arch Linux dotfiles while maintaining separation and modularity.

## 🏗️ Architecture

### Flake Structure
```
nixos/
├── flake.nix              # Main flake configuration
├── modules/               # Custom NixOS modules
│   ├── desktop/          # Desktop environment modules
│   ├── programs/         # Program configurations
│   ├── services/         # System services
│   └── themes/           # Theme configurations
├── hosts/                # Host-specific configurations
│   ├── desktop/          # Desktop host config
│   └── laptop/           # Laptop host config
├── users/                # User configurations (Home Manager)
│   └── derrick/          # User-specific config
├── overlays/             # Custom package overlays
└── scripts/              # Deployment and utility scripts
```

### Design Principles
- **Modular**: Each component is a separate module that can be enabled/disabled
- **Declarative**: Everything is defined in configuration, no manual setup needed
- **Reproducible**: Same configuration produces identical systems
- **Isolated**: NixOS config doesn't interfere with existing Arch Linux dotfiles
- **Reusable**: Configuration files from existing dotfiles are linked/sourced

## 🚀 Quick Start

### Prerequisites
1. **NixOS installed** with flakes enabled
2. **Git access** to this dotfiles repository
3. **Home Manager** (will be installed automatically)

### Initial Setup

1. **Clone the dotfiles** (if not already done):
   ```bash
   git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
   cd ~/dotfiles/nixos
   ```

2. **Run the deployment script**:
   ```bash
   # Interactive deployment
   ./scripts/deploy.sh
   
   # Or automated full deployment
   ./scripts/deploy.sh --full
   ```

3. **Reboot** to ensure all services start correctly.

### First-Time Configuration

Before deployment, you may want to customize:

1. **Update user information** in `users/derrick/programs.nix`:
   ```nix
   programs.git = {
     userName = "Your Name";
     userEmail = "your.email@example.com";
   };
   ```

2. **Set your hostname** in `hosts/desktop/default.nix`:
   ```nix
   networking.hostName = "your-hostname";
   ```

3. **Configure timezone** in the host configuration:
   ```nix
   time.timeZone = "Your/Timezone";
   ```

## 🎯 Features

### Desktop Environment
- **Hyprland**: Modern Wayland compositor with smooth animations
- **Waybar**: Status bar with system information and wallpaper switcher
- **SDDM**: Display manager with Catppuccin Macchiato theme
- **Rofi**: Application launcher with Wayland support
- **Dunst**: Notification daemon with Catppuccin theming

### Development Environment
- **Neovim**: Links to existing Neovim configuration from dotfiles
- **Fish Shell**: Modern shell with syntax highlighting and completions
- **Oh My Posh**: Cross-shell prompt with Git integration and transient prompts
- **Git**: Enhanced configuration with 50+ aliases and delta integration
- **Development Tools**: Modern CLI replacements (bat, eza, ripgrep, etc.)

### Theming
- **Catppuccin Macchiato**: Consistent theming across all applications
- **Multiple Variants**: Easy switching between different accent colors
- **Font Management**: JetBrains Mono Nerd Font and Inter for UI
- **Cursor Themes**: Catppuccin cursors with proper scaling

### System Management
- **Flake-based**: Reproducible system configurations
- **Home Manager**: User-space configuration management
- **Automatic Services**: Wallpaper initialization, cleanup tasks
- **Easy Updates**: Simple commands for system updates

## 📖 Usage

### Daily Commands

```bash
# System management
rebuild                    # Rebuild NixOS system configuration
home-rebuild              # Rebuild Home Manager configuration
nix flake update           # Update all flake inputs

# Development
nix develop               # Enter development shell
nix-shell -p package      # Temporarily install package

# Package management
nix search nixpkgs term   # Search for packages
nix profile install pkg   # Install package to user profile
nix profile remove pkg    # Remove package from user profile

# System information
nixos-version             # Show NixOS version
nix-env --list-generations # Show system generations
```

### Configuration Management

#### Adding New Packages

**System-wide packages** (add to `hosts/*/default.nix`):
```nix
environment.systemPackages = with pkgs; [
  your-package-here
];
```

**User packages** (add to `users/derrick/programs.nix`):
```nix
home.packages = with pkgs; [
  your-package-here
];
```

#### Enabling Modules

In your host configuration (`hosts/desktop/default.nix`):
```nix
desktop = {
  hyprland.enable = true;
  sddm.enable = true;
  waybar.enable = true;
};

programs = {
  development.enable = true;
  shells.enable = true;
};

themes.catppuccin = {
  enable = true;
  flavor = "macchiato";
  accent = "blue";
};
```

#### Customizing Themes

Change the Catppuccin flavor and accent:
```nix
themes.catppuccin = {
  enable = true;
  flavor = "mocha";        # latte, frappe, macchiato, mocha
  accent = "mauve";        # any Catppuccin accent color
};
```

### Working with Existing Dotfiles

The NixOS configuration is designed to work alongside your existing dotfiles:

1. **Configuration Reuse**: Existing configurations are linked via Home Manager
2. **No Conflicts**: NixOS config lives in its own namespace
3. **Shared Resources**: Wallpapers and scripts are shared between systems
4. **Environment Detection**: Scripts can detect and adapt to the current system

#### Linked Configurations

These existing configurations are automatically linked:
- **Hyprland**: `~/.config/hypr/` → `dotfiles/hyprland/.config/hypr/`
- **Waybar**: Scripts and configurations are linked
- **Fish**: Configuration is sourced from dotfiles
- **Neovim**: Complete configuration is linked
- **Git**: Enhanced configuration is included

## 🔧 Customization

### Adding New Hosts

1. **Create host directory**:
   ```bash
   mkdir nixos/hosts/new-hostname
   ```

2. **Create configuration**:
   ```nix
   # nixos/hosts/new-hostname/default.nix
   { config, lib, pkgs, ... }:
   {
     imports = [
       ./hardware-configuration.nix  # Generated by nixos-generate-config
     ];
     
     networking.hostName = "new-hostname";
     
     # Enable desired modules
     desktop.hyprland.enable = true;
     # ... other configuration
   }
   ```

3. **Add to flake.nix**:
   ```nix
   nixosConfigurations = {
     new-hostname = lib.nixosSystem {
       system = "x86_64-linux";
       modules = commonModules ++ [
         ./hosts/new-hostname
         { home-manager.users.derrick = import ./users/derrick; }
       ];
     };
   };
   ```

### Creating Custom Modules

1. **Create module file** in `modules/` directory:
   ```nix
   { config, lib, pkgs, ... }:
   with lib;
   let
     cfg = config.my.custom-module;
   in {
     options.my.custom-module = {
       enable = mkEnableOption "my custom module";
       # ... other options
     };
     
     config = mkIf cfg.enable {
       # ... configuration
     };
   }
   ```

2. **Import in** `modules/default.nix`:
   ```nix
   {
     imports = [
       # ... existing imports
       ./my/custom-module.nix
     ];
   }
   ```

### Extending User Configuration

Add new files in `users/derrick/`:
- `custom-programs.nix` for additional program configurations
- `work.nix` for work-specific configurations
- `gaming.nix` for gaming-related setup

Import them in `users/derrick/default.nix`:
```nix
{
  imports = [
    # ... existing imports
    ./custom-programs.nix
    ./work.nix
    ./gaming.nix
  ];
}
```

## 🔍 Troubleshooting

### Common Issues

#### Flake Validation Errors
```bash
# Check flake syntax
nix flake check

# Show detailed errors
nix flake show --json | jq
```

#### Home Manager Issues
```bash
# Check Home Manager status
systemctl --user status home-manager-derrick.service

# Manual rebuild
home-manager switch --flake ~/dotfiles/nixos#derrick@hostname
```

#### Module Not Found
```bash
# List available configurations
nix eval ~/dotfiles/nixos#nixosConfigurations --apply builtins.attrNames
nix eval ~/dotfiles/nixos#homeConfigurations --apply builtins.attrNames
```

#### Package Not Available
```bash
# Search for packages
nix search nixpkgs package-name

# Check if package exists in current channel
nix-env -qaP | grep package-name
```

### System Recovery

If the system doesn't boot:

1. **Boot into previous generation**:
   - Select previous generation in bootloader
   - Or use: `sudo nixos-rebuild switch --rollback`

2. **Check system generations**:
   ```bash
   nix-env --list-generations --profile /nix/var/nix/profiles/system
   ```

3. **Emergency fixes**:
   ```bash
   # Boot from NixOS installer
   # Mount your system and enter chroot
   nixos-enter
   
   # Rollback to working configuration
   nixos-rebuild switch --rollback
   ```

## 🔗 Integration with Arch Linux Dotfiles

### File Organization

```
~/dotfiles/
├── (Arch Linux configurations)
├── bootstrap.sh           # Arch Linux installer
├── setup/                 # Arch Linux setup scripts
├── hyprland/             # Shared Hyprland config
├── waybar/               # Shared Waybar config
├── wallpapers/           # Shared wallpapers
├── git/                  # Shared Git config
├── neovim/               # Shared Neovim config
└── nixos/                # NixOS-specific configuration
    ├── flake.nix
    ├── modules/
    ├── hosts/
    └── users/
```

### Shared vs. Separate Configurations

**Shared** (works on both systems):
- Wallpapers
- Neovim configuration
- Git aliases and configuration
- Shell aliases and functions
- Application themes and colors

**Separate** (NixOS-specific):
- Package management
- System services
- Boot configuration
- Hardware configuration
- Service management

### Switching Between Systems

The configurations are designed to:
1. **Detect the current system** and adapt accordingly
2. **Use the same dotfiles repository** on both systems
3. **Maintain consistent theming** and user experience
4. **Allow independent updates** of each system

## 📚 Learning Resources

### NixOS Documentation
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Package Manager Manual](https://nixos.org/manual/nix/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)

### Flakes Resources
- [Nix Flakes Wiki](https://nixos.wiki/wiki/Flakes)
- [Practical Nix Flakes](https://serokell.io/blog/practical-nix-flakes)

### Configuration Examples
- [Nix Darwin](https://github.com/LnL7/nix-darwin) (for macOS inspiration)
- [Community Configurations](https://github.com/topics/nixos-config)

## 🤝 Contributing

When making changes to the NixOS configuration:

1. **Test changes** with `nix flake check`
2. **Update documentation** if adding new features
3. **Consider compatibility** with existing Arch Linux setup
4. **Use conventional commits** for version control

## 📄 License

This configuration inherits the same license as the main dotfiles repository.
