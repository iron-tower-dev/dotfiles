# Programs configuration for Home Manager
{ config, lib, pkgs, ... }:

{
  # Shell configuration
  programs = {
    # Fish shell
    fish = {
      enable = true;
      catppuccin.enable = true;
      
      # Link existing fish configuration
      interactiveShellInit = ''
        # Source additional fish configuration from dotfiles if it exists
        if test -f ${config.home.homeDirectory}/dotfiles/fish/.config/fish/config.fish
          source ${config.home.homeDirectory}/dotfiles/fish/.config/fish/config.fish
        end
      '';
      
      shellAliases = {
        # System commands
        ll = "eza -la --icons";
        ls = "eza --icons";
        tree = "eza --tree --icons";
        cat = "bat";
        grep = "rg";
        find = "fd";
        
        # Git aliases (basic set - more in git config)
        g = "git";
        gs = "git status";
        ga = "git add";
        gc = "git commit";
        gp = "git push";
        gl = "git log --oneline";
        
        # System management
        rebuild = "sudo nixos-rebuild switch --flake ~/dotfiles/nixos";
        home-rebuild = "home-manager switch --flake ~/dotfiles/nixos";
        
        # Development
        v = "nvim";
        vim = "nvim";
        
        # Navigation
        ".." = "cd ..";
        "..." = "cd ../..";
        "~" = "cd ~";
      };
    };

    # Zsh shell (backup)
    zsh = {
      enable = true;
      catppuccin.enable = true;
      
      # Link existing zsh configuration if available
      initExtra = ''
        # Source additional zsh configuration from dotfiles if it exists
        if [[ -f "${config.home.homeDirectory}/dotfiles/zsh/.zshrc" ]]; then
          source "${config.home.homeDirectory}/dotfiles/zsh/.zshrc"
        fi
      '';
    };

    # Starship prompt
    starship = {
      enable = true;
      catppuccin.enable = true;
      
      # Use existing starship configuration from dotfiles if available
      # Otherwise use default Catppuccin configuration
    };

    # Git configuration (extended)
    git = {
      enable = true;
      userName = "Derrick";
      userEmail = "derrick@example.com"; # Update with your email
      
      # Use the enhanced git configuration from dotfiles
      includes = [
        { path = "${config.home.homeDirectory}/dotfiles/git/.gitconfig"; }
      ];
      
      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = true;
        rebase.autoStash = true;
        push.default = "simple";
        push.autoSetupRemote = true;
        
        # Delta (better git diff)
        core.pager = "delta";
        interactive.diffFilter = "delta --color-only";
        delta = {
          navigate = true;
          light = false;
          line-numbers = true;
          syntax-theme = "Catppuccin-macchiato";
        };
        
        merge.conflictstyle = "diff3";
        diff.colorMoved = "default";
      };
    };

    # GitHub CLI
    gh = {
      enable = true;
      
      settings = {
        git_protocol = "ssh";
        editor = "nvim";
        prompt = "enabled";
        pager = "delta";
      };
    };

    # Neovim
    neovim = {
      enable = true;
      catppuccin.enable = true;
      
      # Use system package but link existing configuration
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      
      # Additional plugins can be managed here if needed
      # But we'll primarily use the existing lazy.nvim setup
    };

    # Development tools
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # Modern command line tools
    bat = {
      enable = true;
      catppuccin.enable = true;
    };

    eza = {
      enable = true;
    };

    ripgrep = {
      enable = true;
    };

    fd = {
      enable = true;
    };

    fzf = {
      enable = true;
      catppuccin.enable = true;
    };

    # Terminal multiplexer
    tmux = {
      enable = true;
      catppuccin.enable = true;
      
      # Basic configuration - can be extended with dotfiles config
      terminal = "screen-256color";
      mouse = true;
      keyMode = "vi";
      
      extraConfig = ''
        # Additional tmux configuration
        set -g status-position top
        set -g renumber-windows on
        
        # Key bindings
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R
      '';
    };

    # Browser
    firefox = {
      enable = true;
      
      # Basic profile - can be extended with existing Firefox setup
      profiles.default = {
        isDefault = true;
        
        settings = {
          # Privacy settings
          "privacy.trackingprotection.enabled" = true;
          "privacy.donottrackheader.enabled" = true;
          
          # Performance settings
          "gfx.webrender.all" = true;
          "media.ffmpeg.vaapi.enabled" = true;
          
          # Theme
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        };
      };
    };
  };

  # Link existing configuration files from dotfiles
  home.file = {
    # Fish configuration
    ".config/fish" = lib.mkIf (builtins.pathExists ../../../fish) {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/fish/.config/fish";
      recursive = true;
    };

    # Starship configuration
    ".config/starship.toml" = lib.mkIf (builtins.pathExists ../../../starship) {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/starship/.config/starship.toml";
    };

    # Neovim configuration
    ".config/nvim" = lib.mkIf (builtins.pathExists ../../../neovim) {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/neovim/.config/nvim";
      recursive = true;
    };

    # Git configuration files
    ".gitconfig.local" = lib.mkIf (builtins.pathExists ../../../git) {
      text = ''
        # Local git configuration
        # This file is managed by Home Manager and sources the dotfiles git config
        [include]
          path = ${config.home.homeDirectory}/dotfiles/git/.gitconfig
      '';
    };
  };

  # Development packages
  home.packages = with pkgs; [
    # Version control
    git-lfs
    delta # Better git diff

    # Development tools
    direnv
    nix-direnv
    
    # Language servers and tools (managed via Home Manager for global availability)
    # Individual project tools should still use mise/dev shells
    
    # System tools
    tree
    wget
    curl
    jq
    yq
    
    # Archive tools
    unzip
    zip
    p7zip
    
    # Network tools
    dig
    nmap
    tcpdump
    wireshark
    
    # System monitoring
    htop
    btop
    iotop
    nethogs
    
    # Performance tools
    hyperfine
    
    # File tools
    file
    which
    
    # Text processing
    sed
    awk
    grep
    
    # Modern replacements
    bat        # cat replacement
    eza        # ls replacement
    ripgrep    # grep replacement
    fd         # find replacement
    dust       # du replacement
    duf        # df replacement
    procs      # ps replacement
  ];
}
