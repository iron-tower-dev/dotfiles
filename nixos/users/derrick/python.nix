# Python development configuration for Home Manager
{ config, lib, pkgs, ... }:

{
  # Python development packages for user environment
  home.packages = with pkgs; [
    # Core Python tools
    python3
    python3Packages.pip
    python3Packages.virtualenv
    python3Packages.pipx
    
    # Build tools (essential for package building)
    python3Packages.setuptools
    python3Packages.wheel
    python3Packages.build
    python3Packages.installer
    python3Packages.poetry-core
    python3Packages.poetry
    python3Packages.flit-core
    
    # Development and testing tools
    python3Packages.black
    python3Packages.isort
    python3Packages.flake8
    python3Packages.mypy
    python3Packages.pytest
    python3Packages.ruff
    
    # Package management tools
    python3Packages.pdm
    python3Packages.twine
    python3Packages.packaging
    
    # GUI development dependencies (for waypaper-like applications)
    python3Packages.pygobject3
    python3Packages.pycairo
    python3Packages.pillow
    python3Packages.imageio
    python3Packages.platformdirs
    
    # Additional system integration
    gobject-introspection
    gtk3
    gdk-pixbuf
    
    # Wayland/desktop tools (NixOS equivalents of AUR packages)
    waypaper                      # GUI wallpaper setter (if available in nixpkgs)
    # swww is typically available in nixpkgs
    # hyprpicker is typically available in nixpkgs
  ];

  # Configure Python environment
  home.sessionVariables = {
    # Python development environment
    PYTHONDONTWRITEBYTECODE = "1";
    PYTHONUNBUFFERED = "1";
    
    # Ensure user site packages are in PATH
    PATH = "$PATH:${config.home.homeDirectory}/.local/bin";
  };

  # Configure pip for user installations
  home.file.".pip/pip.conf".text = ''
    [global]
    break-system-packages = true
    user = true
    
    [install]
    user = true
    break-system-packages = true
  '';

  # Configure Python user directory
  xdg.configFile."python/pythonrc".text = ''
    # Python startup file
    import sys
    import os
    
    # Add user site packages to path
    import site
    site.USER_SITE = os.path.expanduser('~/.local/lib/python${pkgs.python3.pythonVersion}/site-packages')
    site.USER_BASE = os.path.expanduser('~/.local')
    
    if site.USER_SITE not in sys.path:
        sys.path.insert(0, site.USER_SITE)
  '';

  # Poetry configuration
  home.file.".config/pypoetry/config.toml".text = ''
    [virtualenvs]
    create = true
    in-project = true
    path = ".venv"
    
    [repositories]
    
    [installer]
    parallel = true
  '';

  # Create directories for Python development
  home.activation = {
    createPythonDirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD mkdir -p $VERBOSE_ARG ${config.home.homeDirectory}/.local/bin
      $DRY_RUN_CMD mkdir -p $VERBOSE_ARG ${config.home.homeDirectory}/.local/lib/python${pkgs.python3.pythonVersion}/site-packages
      $DRY_RUN_CMD mkdir -p $VERBOSE_ARG ${config.home.homeDirectory}/.cache/pip
    '';
  };

  # Enable direnv for Python project management
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Configure git to handle Python projects
  programs.git.extraConfig = {
    # Python-specific git configuration
    "filter.nbstrip_full" = {
      clean = "${pkgs.python3Packages.nbstripout}/bin/nbstripout";
      smudge = "cat";
    };
  };
}
