{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.python-development;
in
{
  options.programs.python-development = {
    enable = mkEnableOption "Python development environment with build dependencies";
    
    includeSystemPackages = mkOption {
      type = types.bool;
      default = true;
      description = "Include Python build dependencies in system packages";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = mkIf cfg.includeSystemPackages (with pkgs; [
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
      python3Packages.flit-core
      python3Packages.pdm
      
      # Development tools
      python3Packages.black
      python3Packages.isort
      python3Packages.flake8
      python3Packages.mypy
      python3Packages.pytest
      python3Packages.tox
      
      # Package building utilities
      python3Packages.twine
      python3Packages.packaging
      python3Packages.pkginfo
      python3Packages.distlib
      
      # Essential libraries for GUI applications (like waypaper)
      python3Packages.pygobject3
      python3Packages.pycairo
      python3Packages.pillow
      python3Packages.imageio
      python3Packages.imageio-ffmpeg
      python3Packages.platformdirs
      
      # Screen information library (for waypaper-like tools)
      # Note: python3Packages.screeninfo may not be available in nixpkgs
      # but we can include equivalent functionality
      
      # Additional GUI toolkit support
      gobject-introspection
      gtk3
      gdk-pixbuf
    ]);

    # Enable Python development environment variables
    environment.variables = {
      PYTHONPATH = "$PYTHONPATH:${pkgs.python3Packages.pygobject3}/${pkgs.python3.sitePackages}";
      PYTHONDONTWRITEBYTECODE = "1";  # Don't create .pyc files
      PYTHONUNBUFFERED = "1";         # Force stdout/stderr to be unbuffered
    };

    # Configure pip to use user site packages by default
    environment.etc."pip.conf".text = ''
      [global]
      break-system-packages = true
      user = true
      
      [install]
      user = true
    '';
  };
}
