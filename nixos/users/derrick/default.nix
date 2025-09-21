# Home Manager configuration for user derrick
{ config, lib, pkgs, inputs, outputs, ... }:

{
  imports = [
    # Import Home Manager modules
    ./desktop.nix
    ./programs.nix
    ./python.nix
    ./services.nix
    ./themes.nix
  ];

  # Home Manager configuration
  home = {
    username = "derrick";
    homeDirectory = "/home/derrick";
    stateVersion = "24.05"; # Set to your Home Manager version

    # Environment variables
    sessionVariables = {
      EDITOR = "nvim";
      BROWSER = "firefox";
      TERMINAL = "alacritty";
      
      # XDG directories
      XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
      XDG_DATA_HOME = "${config.home.homeDirectory}/.local/share";
      XDG_CACHE_HOME = "${config.home.homeDirectory}/.cache";
    };
  };

  # Enable Catppuccin theming for Home Manager
  catppuccin = {
    enable = true;
    flavor = "macchiato";
    accent = "blue";
  };

  # XDG configuration
  xdg = {
    enable = true;
    
    # Set default applications
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";
        "application/pdf" = "firefox.desktop";
        "text/plain" = "nvim.desktop";
        "image/png" = "imv.desktop";
        "image/jpeg" = "imv.desktop";
        "video/mp4" = "mpv.desktop";
        "audio/mpeg" = "mpv.desktop";
      };
    };

    # Configure user directories
    userDirs = {
      enable = true;
      desktop = "${config.home.homeDirectory}/Desktop";
      documents = "${config.home.homeDirectory}/Documents";
      download = "${config.home.homeDirectory}/Downloads";
      music = "${config.home.homeDirectory}/Music";
      pictures = "${config.home.homeDirectory}/Pictures";
      videos = "${config.home.homeDirectory}/Videos";
      templates = "${config.home.homeDirectory}/Templates";
      publicShare = "${config.home.homeDirectory}/Public";
    };
  };

  # Symlink dotfiles from the repository
  # This allows using existing configuration files
  home.file = {
    # Link wallpapers directory
    "dotfiles/wallpapers".source = ../../../wallpapers;
    
    # Create a link to the main dotfiles for easy access
    ".dotfiles".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles";
  };

  # Git configuration (basic - will be extended in programs.nix)
  programs.git = {
    enable = true;
    userName = "Derrick";
    userEmail = "derrick@example.com"; # Update with your email
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Allow unfree packages in Home Manager
  nixpkgs.config.allowUnfree = true;
}
