{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.themes.catppuccin;
in
{
  options.themes.catppuccin = {
    enable = mkEnableOption "Catppuccin theme system-wide";
    
    flavor = mkOption {
      type = types.enum [ "latte" "frappe" "macchiato" "mocha" ];
      default = "macchiato";
      description = "Catppuccin flavor to use";
    };
    
    accent = mkOption {
      type = types.enum [ 
        "rosewater" "flamingo" "pink" "mauve" "red" "maroon" 
        "peach" "yellow" "green" "teal" "sky" "sapphire" "blue" "lavender" 
      ];
      default = "blue";
      description = "Catppuccin accent color";
    };
  };

  config = mkIf cfg.enable {
    # Enable Catppuccin theming
    catppuccin = {
      enable = true;
      flavor = cfg.flavor;
      accent = cfg.accent;
    };

    # Install theme packages
    environment.systemPackages = with pkgs; [
      # GTK themes
      catppuccin-gtk
      
      # Qt themes  
      catppuccin-kvantum
      qt5ct
      qt6ct
      
      # Cursors
      catppuccin-cursors
      
      # Icon themes
      papirus-icon-theme
      
      # Fonts
      (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" "Hack" ]; })
      inter
      
      # Additional theme tools
      lxappearance # GTK theme configuration
      kvantum # Qt theme engine
    ];

    # Configure fonts system-wide
    fonts = {
      packages = with pkgs; [
        (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" "Hack" ]; })
        inter
        noto-fonts
        noto-fonts-emoji
        font-awesome
      ];
      
      fontconfig = {
        enable = true;
        defaultFonts = {
          serif = [ "Noto Serif" ];
          sansSerif = [ "Inter" ];
          monospace = [ "JetBrainsMono Nerd Font" ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };

    # Configure Qt theming
    qt = {
      enable = true;
      platformTheme = "qt5ct";
      style = "kvantum";
    };

    # Set environment variables for theming
    environment.sessionVariables = {
      # Qt theming
      QT_QPA_PLATFORMTHEME = "qt5ct";
      QT_STYLE_OVERRIDE = "kvantum";
      
      # GTK theming
      GTK_THEME = "catppuccin-${cfg.flavor}-${cfg.accent}-standard+default";
      
      # Cursor theme
      XCURSOR_THEME = "catppuccin-${cfg.flavor}-dark-cursors";
      XCURSOR_SIZE = "24";
    };

    # Configure GTK system-wide
    programs.dconf.enable = true;
    
    # Add theme configuration to /etc
    environment.etc = {
      "gtk-2.0/gtkrc".text = ''
        gtk-theme-name="catppuccin-${cfg.flavor}-${cfg.accent}-standard+default"
        gtk-icon-theme-name="Papirus-Dark"
        gtk-cursor-theme-name="catppuccin-${cfg.flavor}-dark-cursors"
        gtk-cursor-theme-size=24
        gtk-font-name="Inter 10"
      '';
      
      "gtk-3.0/settings.ini".text = ''
        [Settings]
        gtk-theme-name=catppuccin-${cfg.flavor}-${cfg.accent}-standard+default
        gtk-icon-theme-name=Papirus-Dark
        gtk-cursor-theme-name=catppuccin-${cfg.flavor}-dark-cursors
        gtk-cursor-theme-size=24
        gtk-font-name=Inter 10
        gtk-application-prefer-dark-theme=1
      '';
    };
  };
}
