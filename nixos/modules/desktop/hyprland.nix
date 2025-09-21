{ config, lib, pkgs, inputs, ... }:

with lib;

let
  cfg = config.desktop.hyprland;
in
{
  options.desktop.hyprland = {
    enable = mkEnableOption "Hyprland window manager";
    
    nvidia = mkEnableOption "NVIDIA support for Hyprland";
    
    wallpaperDir = mkOption {
      type = types.str;
      default = "${config.users.users.derrick.home}/dotfiles/wallpapers";
      description = "Directory containing wallpapers";
    };
  };

  config = mkIf cfg.enable {
    # Enable Hyprland
    programs.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      xwayland.enable = true;
    };

    # Enable XDG desktop portal for Hyprland
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
    };

    # Required packages for Hyprland ecosystem
    environment.systemPackages = with pkgs; [
      # Core Wayland/Hyprland packages
      waybar
      rofi-wayland
      swww
      grim
      slurp
      wl-clipboard
      cliphist
      
      # Notification daemon
      dunst
      libnotify
      
      # Screen locking
      swaylock-effects
      
      # Audio
      pavucontrol
      
      # Brightness control
      brightnessctl
      
      # Application launcher
      rofi-wayland
      
      # File manager
      thunar
      thunar-volman
      thunar-archive-plugin
      
      # Terminal
      alacritty
      
      # Network
      networkmanagerapplet
      
      # Bluetooth
      blueman
      
      # System monitoring
      btop
      
      # Media control
      playerctl
    ];

    # Enable required services
    services = {
      # SDDM display manager - additional configuration in sddm.nix
      sddm.enable = true;
      
      # Audio
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };
      
      # Bluetooth
      blueman.enable = true;
      
      # Network
      networkmanager.enable = true;
      
      # Location services
      geoclue2.enable = true;
    };

    # Enable Bluetooth hardware support
    hardware.bluetooth.enable = true;

    # Enable NVIDIA support if requested
    hardware.nvidia = mkIf cfg.nvidia {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
    };

    # Configure environment variables for Hyprland
    environment.sessionVariables = {
      # Wayland
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "Hyprland";
      
      # NVIDIA specific (if enabled)
      GBM_BACKEND = mkIf cfg.nvidia "nvidia-drm";
      LIBVA_DRIVER_NAME = mkIf cfg.nvidia "nvidia";
      __GLX_VENDOR_LIBRARY_NAME = mkIf cfg.nvidia "nvidia";
      
      # Qt/GTK theming
      QT_QPA_PLATFORMTHEME = "qt5ct";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      
      # Firefox Wayland
      MOZ_ENABLE_WAYLAND = "1";
    };

    # Security settings
    security = {
      # Required for swaylock
      pam.services.swaylock = {};
      
      # Polkit for authentication
      polkit.enable = true;
    };
    
    # Add polkit authentication agent
    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
}
