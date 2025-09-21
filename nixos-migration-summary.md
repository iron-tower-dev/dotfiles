# NixOS Configuration Migration: Starship → Oh My Posh

## 📋 Summary

This document summarizes the changes made to the NixOS configuration to reflect the migration from Starship to Oh My Posh across all shell environments.

## 🔄 Files Modified

### 1. `users/derrick/programs.nix`
- **Removed**: Starship program configuration
- **Added**: Documentation comment about Oh My Posh being managed via AUR/pacman
- **Removed**: Starship configuration file linking
- **Added**: Comment referencing Oh My Posh configuration file location

### 2. `modules/programs/shells.nix`
- **Removed**: `starship` from systemPackages
- **Added**: Comment explaining Oh My Posh installation method
- **Removed**: `programs.starship` configuration block
- **Added**: Documentation about Oh My Posh configuration approach

### 3. `scripts/validate.sh`
- **Removed**: `"starship"` from shared resources validation
- **Added**: `"nushell"` and `"zsh"` to shared resources validation
- **Updated**: Validation now checks for the actual shell directories instead of starship

### 4. `README.md`
- **Updated**: Development Environment section to mention Oh My Posh instead of Starship
- **Enhanced**: Added mention of transient prompts capability

## 🔧 Technical Changes

### Package Management Approach
- **Before**: Starship was managed through nixpkgs in both system and user configurations
- **After**: Oh My Posh is documented as being installed via AUR/pacman (not available in nixpkgs)

### Configuration Management
- **Before**: Starship configuration file was linked via Home Manager
- **After**: Oh My Posh configuration is managed through GNU Stow from dotfiles

### Shell Integration
- **Before**: Starship integration was handled by NixOS/Home Manager modules
- **After**: Oh My Posh integration is handled through individual shell configurations in dotfiles

## 🎯 Benefits of This Approach

### 1. **Hybrid Package Management**
- System packages (available in nixpkgs): Managed by NixOS
- Cutting-edge tools (like Oh My Posh): Installed via traditional package managers
- Configuration: Unified through dotfiles for both systems

### 2. **Consistency Across Distributions**
- Same Oh My Posh configuration works on both Arch Linux and NixOS
- No need to maintain separate configurations
- Unified theming experience

### 3. **Flexibility**
- Can use latest Oh My Posh features immediately (not waiting for nixpkgs updates)
- Easy to test and customize without rebuilding entire system
- Falls back gracefully if Oh My Posh is not installed

## 🚀 Deployment Instructions

### On Arch Linux (Existing Process)
```bash
cd ~/dotfiles
stow fish nushell zsh
```

### On NixOS
1. **Install Oh My Posh via package manager** (not managed by Nix):
   ```bash
   # If using AUR helper like paru
   paru -S oh-my-posh-bin
   ```

2. **Deploy NixOS configuration**:
   ```bash
   cd ~/dotfiles/nixos
   ./scripts/deploy.sh
   ```

3. **Deploy shell configurations**:
   ```bash
   cd ~/dotfiles
   stow fish nushell zsh
   ```

## 🧪 Validation

### Structure Validation
```bash
cd ~/dotfiles/nixos
bash scripts/validate.sh
```

### Shell Testing
```bash
cd ~/dotfiles
./test-omp-all-shells.sh
```

## 📝 Configuration Files

### Oh My Posh Configuration
- **File**: `~/.config/catppuccin-macchiato.omp.toml`
- **Managed by**: GNU Stow (unified across distributions)
- **Used by**: Fish, Zsh, and Nushell

### Shell Configurations
- **Fish**: `fish/.config/fish/config.fish`
- **Zsh**: `zsh/.zshrc`  
- **Nushell**: `nushell/.config/nushell/config.nu`

## ✅ Verification Checklist

- [x] NixOS configuration validates successfully
- [x] All Starship references removed from NixOS configs
- [x] Oh My Posh documented as external dependency
- [x] Shared resource validation updated to check actual shell directories
- [x] README updated to reflect current setup
- [x] Shell configurations work independently of NixOS modules

## 🔮 Future Considerations

### If Oh My Posh Becomes Available in Nixpkgs
When/if Oh My Posh is added to nixpkgs, the configuration can be migrated back to native NixOS management:

1. Add `oh-my-posh` to systemPackages
2. Create Home Manager module for Oh My Posh configuration
3. Link configuration file via Home Manager
4. Update shell configurations to use NixOS-managed Oh My Posh

### Maintaining Compatibility
- Keep the current dotfiles-based approach as it works on both systems
- Consider creating a custom NixOS overlay if needed
- Monitor Oh My Posh packaging efforts in nixpkgs

## 📚 Related Documentation

- [Oh My Posh Documentation](https://ohmyposh.dev/)
- [NixOS Home Manager Manual](https://nix-community.github.io/home-manager/)
- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/stow.html)

---

**Migration Date**: 2025-09-21
**Status**: ✅ Complete
**Validated**: ✅ Yes
