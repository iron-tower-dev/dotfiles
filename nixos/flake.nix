{
  description = "Derrick's NixOS Configuration with Hyprland and Catppuccin Theming";

  inputs = {
    # NixOS official package source, using the unstable branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # Home Manager for user-space configuration
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland compositor
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland plugins
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    # Catppuccin theme for Nix
    catppuccin.url = "github:catppuccin/nix";

    # SDDM themes
    sddm-sugar-candy-nix = {
      url = "github:Zhaith-Izaliel/sddm-sugar-candy-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Additional flake utilities
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, home-manager, hyprland, catppuccin, ... } @ inputs:
    let
      inherit (self) outputs;
      # Supported systems for flake packages, shells, etc.
      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      # This is a function that generates an attribute by calling a function you
      # pass to it, with each system as an argument
      forAllSystems = nixpkgs.lib.genAttrs systems;
      
      # Custom library functions
      lib = nixpkgs.lib // home-manager.lib;
      
      # Shared configuration between hosts
      commonModules = [
        # Make flake inputs accessible in NixOS modules
        { _module.args = { inherit inputs outputs; }; }
        
        # Import our custom modules
        ./modules
        
        # Enable Home Manager integration
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = { inherit inputs outputs; };
          };
        }
        
        # Catppuccin theming
        catppuccin.nixosModules.catppuccin
      ];
    in
    {
      # Custom packages and modifications
      overlays = import ./overlays { inherit inputs; };
      
      # Custom NixOS modules
      nixosModules = import ./modules/nixos;
      
      # Custom Home Manager modules  
      homeManagerModules = import ./modules/home-manager;

      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'
      nixosConfigurations = {
        # Example desktop configuration
        # Replace with your actual hostname
        desktop = lib.nixosSystem {
          system = "x86_64-linux";
          modules = commonModules ++ [
            ./hosts/desktop
            
            # User configuration
            {
              home-manager.users.derrick = import ./users/derrick;
            }
          ];
        };
        
        # Example laptop configuration
        laptop = lib.nixosSystem {
          system = "x86_64-linux"; 
          modules = commonModules ++ [
            ./hosts/laptop
            
            # User configuration
            {
              home-manager.users.derrick = import ./users/derrick;
            }
          ];
        };
      };

      # Standalone home configuration entrypoint
      # Available through 'home-manager --flake .#your-username@your-hostname'
      homeConfigurations = {
        "derrick@desktop" = lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [
            ./users/derrick
            catppuccin.homeManagerModules.catppuccin
          ];
        };
        
        "derrick@laptop" = lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [
            ./users/derrick
            catppuccin.homeManagerModules.catppuccin
          ];
        };
      };

      # Development shells
      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            name = "nixos-config";
            packages = with pkgs; [
              # Nix development tools
              nixd
              nil
              nixpkgs-fmt
              nix-tree
              nix-diff
              
              # System tools
              git
              vim
              
              # Deployment tools
              nixos-rebuild
              home-manager
            ];
            
            shellHook = ''
              echo "🏠 Welcome to the NixOS configuration development shell!"
              echo "📚 Available commands:"
              echo "  nixos-rebuild test --flake .#hostname"
              echo "  home-manager switch --flake .#user@hostname"
              echo "  nix flake check"
              echo "  nix flake update"
            '';
          };
        });

      # Formatter for nix files
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
    };
}
