{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.shells;
in
{
  options.programs.shells = {
    enable = mkEnableOption "enhanced shell configuration";
    
    defaultShell = mkOption {
      type = types.str;
      default = "fish";
      description = "Default shell to use";
    };
  };

  config = mkIf cfg.enable {
    # Enable shells
    programs.fish.enable = true;
    programs.zsh.enable = true;
    
    # Set default shell
    users.defaultUserShell = 
      if cfg.defaultShell == "fish" then pkgs.fish
      else if cfg.defaultShell == "zsh" then pkgs.zsh
      else pkgs.bash;

    environment.systemPackages = with pkgs; [
      # Shells
      fish
      zsh
      nushell
      
      # Shell enhancements
      starship # Modern prompt
    ];

    # Fish configuration
    programs.fish = {
      enable = true;
      vendor = {
        completions.enable = true;
        config.enable = true;
        functions.enable = true;
      };
    };

    # Starship prompt
    programs.starship = {
      enable = true;
      settings = {
        # Starship will be configured through Home Manager
        # This enables it system-wide
      };
    };
  };
}
