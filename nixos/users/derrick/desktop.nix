# Desktop environment configuration for Home Manager
{ config, lib, pkgs, inputs, ... }:

{
  # Wayland/Hyprland configuration
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    
    # Use existing Hyprland configuration from dotfiles
    # We'll source the existing config file and make NixOS-specific adjustments
    extraConfig = ''
      # Source the base configuration from dotfiles
      source = ~/.config/hypr/hyprland.conf
      
      # NixOS-specific overrides can be added here if needed
    '';
    
    # Enable additional features
    systemd.enable = true;
    xwayland.enable = true;
  };

  # Link Hyprland configuration from dotfiles
  home.file = {
    ".config/hypr" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/hyprland/.config/hypr";
      recursive = true;
    };
  };

  # Waybar configuration - link directly from dotfiles
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
  };

  # Link complete Waybar configuration from dotfiles
  home.file.".config/waybar" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/waybar/.config/waybar";
    recursive = true;
  };

  # Rofi configuration
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    
    # Use Catppuccin theme
    catppuccin.enable = true;
    
    # Basic configuration - can be extended with dotfiles config if needed
    theme = "catppuccin-macchiato";
    
    extraConfig = {
      modi = "drun,run,window";
      show-icons = true;
      display-drun = "";
      display-run = "";
      display-window = "";
      drun-display-format = "{name}";
      window-format = "{w} · {c} · {t}";
    };
  };

  # Link Rofi configuration from dotfiles if it exists
  home.file.".config/rofi" = lib.mkIf (builtins.pathExists ../../../rofi) {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/rofi/.config/rofi";
    recursive = true;
  };

  # Terminal - Alacritty
  programs.alacritty = {
    enable = true;
    catppuccin.enable = true;
    
    # Import settings from existing alacritty config if it exists
    # Otherwise use sensible defaults
  };

  # Link Alacritty configuration from dotfiles if it exists
  home.file.".config/alacritty" = lib.mkIf (builtins.pathExists ../../../alacritty) {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/alacritty/.config/alacritty";
    recursive = true;
  };

  # Desktop services
  services = {
    # Wallpaper daemon - swww
    swww = {
      enable = true;
      package = pkgs.swww;
    };
    
    # Notification daemon
    dunst = {
      enable = true;
      catppuccin.enable = true;
      
      settings = {
        global = {
          monitor = 0;
          follow = "keyboard";
          geometry = "300x5-30+20";
          indicate_hidden = "yes";
          shrink = "no";
          transparency = 10;
          notification_height = 0;
          separator_height = 2;
          padding = 8;
          horizontal_padding = 8;
          frame_width = 2;
          frame_color = "#8AADF4";
          separator_color = "frame";
          sort = "yes";
          idle_threshold = 120;
          font = "JetBrainsMono Nerd Font 10";
          line_height = 0;
          markup = "full";
          format = "<b>%s</b>\\n%b";
          alignment = "left";
          vertical_alignment = "center";
          show_age_threshold = 60;
          word_wrap = "yes";
          ellipsize = "middle";
          ignore_newline = "no";
          stack_duplicates = true;
          hide_duplicate_count = false;
          show_indicators = "yes";
          icon_position = "left";
          max_icon_size = 32;
          sticky_history = "yes";
          history_length = 20;
          browser = "${pkgs.firefox}/bin/firefox";
          always_run_script = true;
          title = "Dunst";
          class = "Dunst";
          startup_notification = false;
          verbosity = "mesg";
          corner_radius = 8;
          ignore_dbusclose = false;
          force_xinerama = false;
          mouse_left_click = "close_current";
          mouse_middle_click = "do_action, close_current";
          mouse_right_click = "close_all";
        };
      };
    };

    # Clipboard manager
    cliphist = {
      enable = true;
      package = pkgs.cliphist;
    };
  };

  # Desktop packages
  home.packages = with pkgs; [
    # Screenshot and screen recording
    grim
    slurp
    
    # Image viewer
    imv
    
    # Video player
    mpv
    
    # File manager
    thunar
    
    # Archive support for thunar
    file-roller
    
    # System monitoring
    htop
    btop
    
    # Network tools
    networkmanagerapplet
    
    # Bluetooth
    blueman
    
    # Audio control
    pavucontrol
    
    # Brightness control
    brightnessctl
    
    # Media control
    playerctl
    
    # Wallpaper tools
    swww
    
    # Screen locker
    swaylock-effects
  ];
}
