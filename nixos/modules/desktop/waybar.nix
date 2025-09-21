{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.desktop.waybar;
in
{
  options.desktop.waybar = {
    enable = mkEnableOption "Waybar status bar";
  };

  config = mkIf cfg.enable {
    # Waybar is configured through Home Manager
    # This module just ensures system-level packages are available
    environment.systemPackages = with pkgs; [
      waybar
    ];
  };
}
