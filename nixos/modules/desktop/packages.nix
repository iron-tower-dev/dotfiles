{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.desktop.packages;
  
  # Create custom Python packages for those not available in nixpkgs
  python3Packages = pkgs.python3Packages;
  
  # waypaper equivalent - GUI wallpaper setter for Wayland
  waypaper = python3Packages.buildPythonApplication rec {
    pname = "waypaper";
    version = "2.6";

    src = pkgs.fetchFromGitHub {
      owner = "anufrievroman";
      repo = "waypaper";
      rev = "v${version}";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Update with actual hash
    };

    propagatedBuildInputs = with python3Packages; [
      pygobject3
      pillow
      imageio
      imageio-ffmpeg
      platformdirs
      # screeninfo - if not available, we'll handle screen detection differently
    ];

    buildInputs = with pkgs; [
      gtk3
      gdk-pixbuf
      gobject-introspection
    ];

    meta = with lib; {
      description = "GUI wallpaper setter for Wayland and Xorg window managers";
      homepage = "https://github.com/anufrievroman/waypaper";
      license = licenses.gpl3Only;
      maintainers = with maintainers; [ ];
      platforms = platforms.linux;
    };
  };

  # python-imageio-ffmpeg equivalent
  python-imageio-ffmpeg = python3Packages.imageio-ffmpeg or (python3Packages.buildPythonPackage rec {
    pname = "imageio-ffmpeg";
    version = "0.6.0";
    
    src = pkgs.fetchPypi {
      inherit pname version;
      sha256 = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB="; # Update with actual hash
    };
    
    propagatedBuildInputs = with pkgs; [ ffmpeg ];
    
    meta = with lib; {
      description = "FFMPEG wrapper for Python";
      homepage = "https://github.com/imageio/imageio-ffmpeg";
      license = licenses.bsd2;
    };
  });

  # python-screeninfo equivalent - screen information library
  python-screeninfo = python3Packages.buildPythonPackage rec {
    pname = "screeninfo";
    version = "0.8.1";
    
    src = pkgs.fetchPypi {
      inherit pname version;
      sha256 = "sha256-CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC="; # Update with actual hash
    };
    
    buildInputs = with pkgs; [
      xorg.libX11
      xorg.libXinerama
      xorg.libXrandr
      libdrm
    ];
    
    meta = with lib; {
      description = "Python library to fetch location and size of physical screens";
      homepage = "https://github.com/rr-/screeninfo";
      license = licenses.mit;
    };
  };

in
{
  options.desktop.packages = {
    enable = mkEnableOption "desktop application packages";
    
    includeAurEquivalents = mkOption {
      type = types.bool;
      default = true;
      description = "Include NixOS equivalents of AUR packages";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Wayland/Hyprland ecosystem
      hyprland
      waybar
      rofi-wayland
      
      # Hyprland tools
      hyprpicker
      swww
      
      # Screenshot and screen tools
      grim
      slurp
      wl-clipboard
      
      # File management
      thunar
      thunar-volman
      gvfs
      tumbler
      
      # Terminal and shell
      alacritty
      fish
      
      # Development
      neovim
      git
      
      # System tools
      btop
      playerctl
      brightnessctl
      
      # Notification system
      dunst
      libnotify
      
      # Authentication
      polkit-gnome
      
    ] ++ optionals cfg.includeAurEquivalents [
      # AUR package equivalents
      # Note: Some of these may need custom packaging or may already exist in nixpkgs
      # waypaper  # Uncomment when package is properly defined with correct hash
      
      # These should be available in nixpkgs python packages
      python3Packages.imageio-ffmpeg
      # python-screeninfo may need custom packaging
      
      # Theme packages (Catppuccin equivalents)
      # Note: These are handled by the catppuccin NixOS module instead of AUR packages
    ];

    # Enable services that AUR packages might have provided
    services = {
      # Ensure graphics and desktop services are enabled
      xserver.displayManager.sddm.enable = mkDefault true;
      pipewire.enable = mkDefault true;
    };
  };
}
