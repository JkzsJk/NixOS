{
  description = "NixOS configuration";

  # Enable flakes for evaluation of this flake itself
  nixConfig.experimental-features = [ "nix-command" "flakes" ];

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";  # Stable channel
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";  # Use unstable if preferred
    
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
  let
    # Shared across all machines in this repo
    sharedModules = [
      { nix.settings.experimental-features = [ "nix-command" "flakes" ]; }
      ./modules/00-common
    ];
  in {
    nixosConfigurations.dellXps15-9530 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      extraSpecialArgs = { inherit inputs; };
      modules = sharedModules ++ [
        ./hosts/dellXps15-9530/configuration.nix
        ./modules/01-jellyfin
        ./modules/02-deluge
        ./modules/03-hyprland

        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.jason = import ./home/jason.nix;
        }
      ];
    };
  };
}