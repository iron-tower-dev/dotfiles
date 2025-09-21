# Theme configuration for Home Manager
{ config, lib, pkgs, ... }:

{
  # GTK theming
  gtk = {
    enable = true;
    
    catppuccin = {
      enable = true;
      flavor = "macchiato";
      accent = "blue";
      size = "standard";
      tweaks = [ "normal" ];
    };
    
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    
    cursorTheme = {
      name = "catppuccin-macchiato-dark-cursors";
      package = pkgs.catppuccin-cursors.macchiatoDark;
      size = 24;
    };
    
    font = {
      name = "Inter";
      size = 10;
    };
    
    gtk2 = {
      configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
      extraConfig = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
    
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  # Qt theming
  qt = {
    enable = true;
    platformTheme.name = "qtct";
    
    style = {
      name = "kvantum";
      catppuccin = {
        enable = true;
        flavor = "macchiato";
        accent = "blue";
      };
    };
  };

  # Home Manager Catppuccin configuration for various programs
  catppuccin = {
    # This was already enabled in the main user configuration
    # Here we can configure specific programs if needed
    
    # Specific program overrides
    bat.flavor = "macchiato";
    bottom.flavor = "macchiato";
    btop.flavor = "macchiato";
    fzf.flavor = "macchiato";
    gitui.flavor = "macchiato";
    lazygit.flavor = "macchiato";
    tmux.flavor = "macchiato";
    zsh-syntax-highlighting.flavor = "macchiato";
  };

  # Cursor theme system-wide
  home.pointerCursor = {
    name = "catppuccin-macchiato-dark-cursors";
    package = pkgs.catppuccin-cursors.macchiatoDark;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  # Font configuration
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [ "Noto Serif" ];
      sansSerif = [ "Inter" ];
      monospace = [ "JetBrainsMono Nerd Font" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  # XResources for legacy X11 applications
  xresources.properties = {
    # Catppuccin Macchiato colors
    "*foreground" = "#CAD3F5";
    "*background" = "#24273A";
    "*cursorColor" = "#F4DBD6";
    
    # Black
    "*color0" = "#494D64";
    "*color8" = "#5B6078";
    
    # Red
    "*color1" = "#ED8796";
    "*color9" = "#ED8796";
    
    # Green
    "*color2" = "#A6DA95";
    "*color10" = "#A6DA95";
    
    # Yellow
    "*color3" = "#EED49F";
    "*color11" = "#EED49F";
    
    # Blue
    "*color4" = "#8AADF4";
    "*color12" = "#8AADF4";
    
    # Magenta
    "*color5" = "#F5BDE6";
    "*color13" = "#F5BDE6";
    
    # Cyan
    "*color6" = "#8BD5CA";
    "*color14" = "#8BD5CA";
    
    # White
    "*color7" = "#B8C0E0";
    "*color15" = "#A5ADCB";
    
    # Additional terminal settings
    "Xft.dpi" = 96;
    "Xft.antialias" = true;
    "Xft.rgba" = "rgb";
    "Xft.hinting" = true;
    "Xft.hintstyle" = "hintslight";
  };

  # Environment variables for theming
  home.sessionVariables = {
    # GTK theming
    GTK_THEME = "catppuccin-macchiato-blue-standard+default";
    
    # Qt theming
    QT_QPA_PLATFORMTHEME = "qt5ct";
    QT_STYLE_OVERRIDE = "kvantum";
    
    # Cursor theming
    XCURSOR_THEME = "catppuccin-macchiato-dark-cursors";
    XCURSOR_SIZE = "24";
    
    # Icon theme
    ICON_THEME = "Papirus-Dark";
  };

  # Additional packages for theming
  home.packages = with pkgs; [
    # Theme packages
    catppuccin-gtk
    catppuccin-kvantum
    catppuccin-cursors
    papirus-icon-theme
    
    # Theme tools
    lxappearance
    qt5ct
    qt6ct
    kvantum
    
    # Font packages
    (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" "Hack" ]; })
    inter
    noto-fonts
    noto-fonts-emoji
    font-awesome
  ];
}
