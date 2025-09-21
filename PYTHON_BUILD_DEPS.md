# Python Build Dependencies for Multi-Distribution Dotfiles

This document explains the comprehensive Python build dependencies solution implemented across both Arch Linux and NixOS configurations to prevent AUR-like package build failures.

## Problem Statement

When building Python packages (especially GUI applications like `waypaper`), systems often encounter build failures like:
- `Cannot import 'poetry.core.masonry.api'`
- `ModuleNotFoundError: No module named 'installer'`
- `No module named 'gi'` (PyGObject3)

This occurs when Python build dependencies are missing or when there are version mismatches between system Python and mise/pyenv Python installations.

## Solution Overview

### Multi-Distribution Strategy
1. **System-Level Dependencies**: Install core Python build packages via system package manager
2. **User-Level Dependencies**: Install build tools in user Python environments (mise/pyenv)
3. **Environment Isolation**: Proper configuration for different Python environments
4. **Verification**: Automated testing of build environment

## Arch Linux Implementation

### Files Modified/Created
- `setup/packages/01-core-packages.sh` - System Python build packages
- `setup/system/setup-mise.sh` - Mise Python environment setup  
- `setup/system/setup-python-build-deps.sh` - Dedicated Python deps script
- `setup/packages/02-aur-packages.sh` - Integration with AUR builds
- `bootstrap.sh` - Integration into main installation flow

### System Packages Added
```bash
# Added to PYTHON_BUILD_PACKAGES in 01-core-packages.sh
python-poetry         # Modern Python packaging and dependency management
python-installer      # Python package installer
python-build          # Python build frontend
python-setuptools     # Python packaging utilities
python-wheel          # Python wheel support
```

### Mise Python Environment
```bash
# Added to setup-mise.sh PIP_BUILD_DEPS
installer             # Python package installer (for AUR builds)
poetry                # Modern Python packaging (for AUR builds)  
build                 # Python build frontend
setuptools            # Python packaging utilities
wheel                 # Python wheel support
```

### Usage
```bash
# Automatic (included in full installation)
./bootstrap.sh --full

# Manual Python deps setup
./bootstrap.sh --python-deps

# Test environment
python -c "import installer, poetry.core.masonry.api; print('Build deps OK')"
```

## NixOS Implementation

### Files Created/Modified
- `modules/programs/python.nix` - System-wide Python development module
- `modules/programs/development.nix` - Updated with Python build deps
- `users/derrick/python.nix` - Home Manager Python configuration
- `modules/desktop/packages.nix` - NixOS equivalents of AUR packages
- Host configurations updated to enable Python development

### System Configuration
```nix
# In modules/programs/python.nix
environment.systemPackages = with pkgs; [
  # Core Python
  python3
  python3Packages.pip
  python3Packages.virtualenv
  python3Packages.pipx
  
  # Build dependencies (equivalent to Arch Linux python-* packages)
  python3Packages.setuptools
  python3Packages.wheel  
  python3Packages.build
  python3Packages.installer
  python3Packages.poetry-core
  python3Packages.poetry
  
  # GUI development dependencies
  python3Packages.pygobject3
  python3Packages.pycairo
  python3Packages.pillow
  python3Packages.imageio
  python3Packages.imageio-ffmpeg
  python3Packages.platformdirs
];
```

### Home Manager Configuration
```nix
# In users/derrick/python.nix
home.packages = with pkgs; [
  # Python development tools
  python3Packages.black
  python3Packages.isort
  python3Packages.flake8
  python3Packages.mypy
  python3Packages.pytest
  python3Packages.ruff
];
```

### Host Configuration
```nix
# Enable in hosts/*/default.nix
programs = {
  development.enable = true;
  python-development.enable = true;  # Enable Python build dependencies
};
```

### Usage
```bash
# System rebuild with Python support
nixos-rebuild switch --flake ~/dotfiles/nixos

# Check Python environment
python -c "import setuptools, wheel, build, installer, poetry; print('Build deps OK')"
python -c "import gi, cairo, PIL; print('GUI deps OK')"
```

## Cross-Platform Compatibility

### Environment Detection
Both configurations detect and adapt to:
- System Python vs mise/pyenv Python
- Available package managers (pip, poetry, etc.)
- GUI toolkit requirements (GTK, Qt)

### Shared Features
1. **Complete Build Toolchain**: poetry, setuptools, wheel, build, installer
2. **GUI Development**: PyGObject3, cairo, pillow for desktop applications
3. **Development Tools**: black, isort, flake8, mypy, pytest
4. **Environment Isolation**: direnv support on both platforms

### Testing Commands
```bash
# Test basic build environment
python -c "import installer, poetry, setuptools, wheel; print('Basic build deps OK')"

# Test GUI capabilities  
python -c "import gi, cairo, PIL; print('GUI deps OK')"

# Test mise integration (Arch Linux)
mise doctor
python --version && which python

# Test nix integration (NixOS)
nix search nixpkgs python3Packages
```

## Troubleshooting

### Arch Linux
```bash
# Fix build dependencies
./bootstrap.sh --python-deps

# Clean AUR cache if needed
paru -Sc --noconfirm

# Test specific package
paru -S waypaper --noconfirm
```

### NixOS
```bash
# Enable Python development if not enabled
# Add to host config: programs.python-development.enable = true;

# Install specific Python package
nix profile install nixpkgs#python3Packages.package-name

# Check flake
nix flake check ~/dotfiles/nixos
```

### Common Issues

1. **Python Version Mismatch**
   - Arch: Use `which python` to verify mise vs system Python
   - NixOS: Python version is managed declaratively

2. **Missing GUI Dependencies**
   - Both systems now include PyGObject3, cairo, pillow
   - Test with: `python -c "import gi; print('GUI OK')"`

3. **Build Tool Missing** 
   - Both systems include comprehensive build toolchain
   - Test with: `python -c "import poetry.core.masonry.api"`

## Benefits

1. **Prevented Issues**: No more AUR/package build failures due to missing Python dependencies
2. **Consistent Environment**: Same Python capabilities across Arch Linux and NixOS
3. **Developer Experience**: Complete Python development environment out-of-the-box
4. **Future-Proof**: Comprehensive dependency coverage prevents future build issues
5. **Documentation**: Clear troubleshooting and verification procedures

## Package Coverage

### Arch Linux AUR Packages Fixed
- ✅ `python-imageio-ffmpeg`
- ✅ `python-screeninfo`  
- ✅ `waypaper`
- ✅ Any Python package requiring build dependencies

### NixOS Equivalents Provided
- ✅ `python3Packages.imageio-ffmpeg`
- ✅ `python3Packages.pygobject3`
- ✅ `waypaper` (custom package or available in nixpkgs)
- ✅ All standard Python development tools

This comprehensive solution ensures that Python build dependency issues are prevented on both distributions while maintaining the flexibility and modularity of the dotfiles system.
