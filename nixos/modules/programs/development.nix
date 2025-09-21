{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.development;
in
{
  options.programs.development = {
    enable = mkEnableOption "development tools and packages";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Version control
      git
      gh # GitHub CLI
      
      # Editors
      neovim
      
      # Development tools will be managed through Home Manager and mise
      # This provides system-level essentials only
      
      # Build tools
      gnumake
      cmake
      
      # Python build dependencies (essential for AUR-like package building)
      python3
      python3Packages.pip
      python3Packages.setuptools
      python3Packages.wheel
      python3Packages.build
      python3Packages.installer
      python3Packages.poetry-core
      python3Packages.poetry
      
      # System tools
      curl
      wget
      unzip
      tree
      fd
      ripgrep
      bat
      eza
      
      # Network tools
      networkmanager
    ];

    # Enable git system-wide
    programs.git = {
      enable = true;
      package = pkgs.gitFull;
    };
    
    # Enable SSH
    programs.ssh.startAgent = true;
  };
}
