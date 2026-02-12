{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";  # Stable channel
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";  # Use unstable if preferred
    
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      dellXps15-9530 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/dellXps15-9530/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
      };
    };
  };
}
