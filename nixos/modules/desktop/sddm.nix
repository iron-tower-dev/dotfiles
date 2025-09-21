{ config, lib, pkgs, inputs, ... }:

with lib;

let
  cfg = config.desktop.sddm;
  
  # Catppuccin SDDM theme configuration
  catppuccinTheme = pkgs.stdenv.mkDerivation {
    name = "sddm-catppuccin-theme";
    src = pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "sddm";
      rev = "v1.1.2";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Update this
    };
    
    installPhase = ''
      mkdir -p $out/share/sddm/themes/catppuccin-macchiato
      cp -r src/catppuccin-macchiato/* $out/share/sddm/themes/catppuccin-macchiato/
    '';
  };
in
{
  options.desktop.sddm = {
    enable = mkEnableOption "SDDM display manager with Catppuccin theme";
    
    theme = mkOption {
      type = types.str;
      default = "catppuccin-macchiato";
      description = "SDDM theme to use";
    };
    
    autoLogin = {
      enable = mkEnableOption "automatic login";
      user = mkOption {
        type = types.str;
        default = "derrick";
        description = "User to auto-login";
      };
    };
  };

  config = mkIf cfg.enable {
    # Enable SDDM
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      theme = cfg.theme;
      
      # Auto-login configuration
      autoLogin = mkIf cfg.autoLogin.enable {
        enable = true;
        user = cfg.autoLogin.user;
      };
      
      # SDDM settings
      settings = {
        Theme = {
          Current = cfg.theme;
          CursorTheme = "catppuccin-macchiato-dark-cursors";
          EnableAvatars = true;
          DisableAvatarsThreshold = 7;
          FacesDir = "/usr/share/sddm/faces";
          ThemeDir = "/run/current-system/sw/share/sddm/themes";
        };
        
        General = {
          HaltCommand = "/run/current-system/sw/bin/systemctl poweroff";
          RebootCommand = "/run/current-system/sw/bin/systemctl reboot";
          Numlock = "none";
        };
        
        Users = {
          MaximumUid = 60000;
          MinimumUid = 1000;
          HideUsers = "";
          HideShells = "";
          RememberLastUser = true;
          RememberLastSession = true;
        };
        
        Wayland = {
          EnableHiDPI = true;
          SessionCommand = "/run/current-system/sw/share/sddm/scripts/wayland-session";
          SessionDir = "/run/current-system/sw/share/wayland-sessions";
          SessionLogFile = ".local/share/sddm/wayland-session.log";
        };
        
        X11 = {
          EnableHiDPI = true;
          MinimumVT = 1;
          ServerPath = "/run/current-system/sw/bin/X";
          SessionCommand = "/run/current-system/sw/share/sddm/scripts/xorg-session";
          SessionDir = "/run/current-system/sw/share/xsessions";
          SessionLogFile = ".local/share/sddm/xorg-session.log";
          UserAuthFile = ".Xauthority";
          XauthPath = "/run/current-system/sw/bin/xauth";
        };
      };
    };

    # Install Catppuccin SDDM theme
    environment.systemPackages = with pkgs; [
      # SDDM and dependencies
      libsForQt5.qt5.qtquickcontrols2
      libsForQt5.qt5.qtgraphicaleffects
      
      # Catppuccin theme (we'll use a simpler approach for now)
      (pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "sddm";
        rev = "v1.1.2";
        sha256 = "sha256-Y7c2YN8tU8eUdJLvdZo/fPzdOQGRaXWb1W4Gk1nIBdE=";
        name = "catppuccin-sddm-source";
      })
    ];

    # Create symlink for the theme
    system.activationScripts.sddmTheme = ''
      mkdir -p /var/lib/sddm/.config
      
      # Create SDDM theme directories
      mkdir -p /usr/share/sddm/themes
      
      # Link Catppuccin theme variants
      for variant in macchiato mocha frappe latte; do
        for accent in rosewater flamingo pink mauve red maroon peach yellow green teal sky sapphire blue lavender; do
          theme_name="catppuccin-$variant-$accent"
          if [ ! -e "/usr/share/sddm/themes/$theme_name" ]; then
            ln -sf ${catppuccinTheme}/share/sddm/themes/catppuccin-macchiato "/usr/share/sddm/themes/$theme_name" || true
          fi
        done
      done
    '';

    # Configure SDDM user Qt settings
    environment.etc."sddm/qt5ct.conf".text = ''
      [Appearance]
      color_scheme_path=/run/current-system/sw/share/qt5ct/colors/catppuccin-macchiato.conf
      custom_palette=false
      icon_theme=Papirus-Dark
      standard_dialogs=default
      style=kvantum-dark

      [Fonts]
      fixed="JetBrainsMono Nerd Font,10,-1,5,50,0,0,0,0,0"
      general="Inter,10,-1,5,50,0,0,0,0,0"

      [Interface]
      activate_item_on_single_click=1
      buttonbox_layout=0
      cursor_flash_time=1000
      dialog_buttons_have_icons=1
      double_click_interval=400
      gui_effects=@Invalid()
      keyboard_scheme=2
      menus_have_icons=true
      show_shortcuts_in_context_menus=true
      stylesheets=@Invalid()
      toolbutton_style=4
      underline_shortcut=1
      wheel_scroll_lines=3
    '';
  };
}
