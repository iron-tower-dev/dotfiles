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
      # oh-my-posh # Modern prompt (installed via AUR/pacman, not available in nixpkgs)
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

    # Oh My Posh prompt (replaces Starship)
    # Oh My Posh is not available in nixpkgs, so it's installed via AUR/pacman
    # Configuration is managed through dotfiles with the unified config file:
    # ~/.config/catppuccin-macchiato.omp.toml
  };
}
