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
  home.file.".config/rofi" = lib.mkIf (builtins.pathExists "${config.home.homeDirectory}/dotfiles/rofi") {
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
  home.file.".config/alacritty" = lib.mkIf (builtins.pathExists "${config.home.homeDirectory}/dotfiles/alacritty") {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/alacritty/.config/alacritty";
    recursive = true;
  };

  # Link Dunst configuration from dotfiles if it exists (when not using services.dunst)
  # This allows for manual dunst configuration management alongside NixOS
  home.file.".config/dunst-dotfiles" = lib.mkIf (builtins.pathExists "${config.home.homeDirectory}/dotfiles/dunst") {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/dunst/.config/dunst";
    recursive = true;
  };

  # Desktop services
  services = {
    # Wallpaper daemon - swww
    swww = {
      enable = true;
      package = pkgs.swww;
    };
    
    # Notification daemon - Dunst with Catppuccin Macchiato theme
    dunst = {
      enable = true;
      
      settings = {
        global = {
          ### Display ###
          monitor = 0;
          follow = "none";

          ### Geometry ###
          width = 300;
          height = "(0, 300)";
          origin = "top-right";
          offset = "(10, 50)";
          scale = 0;
          notification_limit = 0;

          ### Progress bar ###
          progress_bar = true;
          progress_bar_height = 10;
          progress_bar_frame_width = 1;
          progress_bar_min_width = 150;
          progress_bar_max_width = 300;

          ### Text ###
          font = "JetBrains Mono 11";
          line_height = 0;
          markup = "full";
          format = "<b>%s</b>\\n%b";
          alignment = "left";
          vertical_alignment = "center";
          show_age_threshold = 60;
          ellipsize = "middle";
          ignore_newline = "no";
          stack_duplicates = true;
          hide_duplicate_count = false;
          show_indicators = "yes";

          ### Icons ###
          icon_position = "left";
          min_icon_size = 0;
          max_icon_size = 32;
          icon_path = "/run/current-system/sw/share/icons/Papirus:/run/current-system/sw/share/icons/Papirus-Dark:/run/current-system/sw/share/icons/hicolor/scalable/apps";

          ### History ###
          sticky_history = "yes";
          history_length = 20;

          ### Misc/Advanced ###
          dmenu = "${pkgs.rofi-wayland}/bin/rofi -dmenu -p dunst:";
          browser = "${pkgs.firefox}/bin/firefox";
          always_run_script = true;
          title = "Dunst";
          class = "Dunst";
          corner_radius = 12;
          ignore_dbusclose = false;
          force_xwayland = false;
          force_xinerama = false;
          mouse_left_click = "close_current";
          mouse_middle_click = "do_action, close_current";
          mouse_right_click = "close_all";
        };
        
        # Catppuccin Macchiato Color Scheme
        urgency_low = {
          background = "#24273a";
          foreground = "#cad3f5";
          highlight = "#8aadf4";
          frame_color = "#363a4f";
          timeout = 5;
        };
        
        urgency_normal = {
          background = "#24273a";
          foreground = "#cad3f5";
          highlight = "#8aadf4";
          frame_color = "#8aadf4";
          timeout = 10;
        };
        
        urgency_critical = {
          background = "#24273a";
          foreground = "#cad3f5";
          highlight = "#ed8796";
          frame_color = "#ed8796";
          timeout = 0;
        };
        
        # Application-specific rules
        spotify = {
          appname = "Spotify";
          background = "#24273a";
          foreground = "#a6da95";
          frame_color = "#a6da95";
          timeout = 5;
        };
        
        discord = {
          appname = "discord";
          background = "#24273a";
          foreground = "#b7bdf8";
          frame_color = "#b7bdf8";
          timeout = 5;
        };
        
        volume = {
          appname = "changeVolume";
          background = "#24273a";
          foreground = "#eed49f";
          frame_color = "#eed49f";
          timeout = 2;
        };
        
        brightness = {
          appname = "changeBrightness";
          background = "#24273a";
          foreground = "#f5a97f";
          frame_color = "#f5a97f";
          timeout = 2;
        };
      };
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
