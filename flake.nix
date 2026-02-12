{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";  # Stable channel
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";  # Use unstable if preferred
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      dellXps15-9530 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/dellXps15-9530/configuration.nix
        ];
      };
    };
  };
}
