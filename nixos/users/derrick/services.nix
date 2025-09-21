# Services configuration for Home Manager
{ config, lib, pkgs, ... }:

{
  # User services managed by Home Manager
  services = {
    # GPG agent for SSH and Git signing
    gpg-agent = {
      enable = true;
      defaultCacheTtl = 1800;
      enableSshSupport = true;
      pinentryPackage = pkgs.pinentry-gtk2;
    };

    # SSH agent (alternative to gpg-agent for SSH)
    ssh-agent = {
      enable = false; # Disabled since we're using gpg-agent
    };

    # Desktop services are configured in desktop.nix
    # System services are configured in the NixOS modules
  };

  # Systemd user services for custom functionality
  systemd.user.services = {
    # Wallpaper initialization service
    wallpaper-init = {
      Unit = {
        Description = "Initialize wallpaper system with swww";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
        ConditionPathExists = "${config.home.homeDirectory}/dotfiles/waybar/.config/waybar/scripts/wallpaper-init.sh";
      };
      
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
      
      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${config.home.homeDirectory}/dotfiles/waybar/.config/waybar/scripts/wallpaper-init.sh";
        Environment = [
          "PATH=${lib.makeBinPath (with pkgs; [ swww coreutils findutils ])}"
        ];
      };
    };

    # Mise environment setup (if using mise from dotfiles)
    mise-setup = lib.mkIf (builtins.pathExists ../../../mise) {
      Unit = {
        Description = "Setup mise environment";
        After = [ "default.target" ];
      };
      
      Install = {
        WantedBy = [ "default.target" ];
      };
      
      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.bash}/bin/bash -c 'if command -v mise >/dev/null 2>&1; then mise install; fi'";
        Environment = [
          "PATH=${config.home.sessionVariables.PATH or "/run/current-system/sw/bin"}"
        ];
      };
    };
  };

  # Systemd user timers for periodic tasks
  systemd.user.timers = {
    # Nix store optimization
    nix-gc-user = {
      Unit = {
        Description = "Garbage collect user Nix store";
      };
      
      Timer = {
        OnCalendar = "weekly";
        Persistent = true;
      };
      
      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };

  systemd.user.services.nix-gc-user = {
    Unit = {
      Description = "Garbage collect user Nix store";
    };
    
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.nix}/bin/nix-collect-garbage -d";
    };
  };
}
