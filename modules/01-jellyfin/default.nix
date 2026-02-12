# Jellyfin module - auto-imports all configuration files
{ config, pkgs, ... }:

{
  imports = [
    ./00-packages.nix
    ./01-options.nix
    ./02-hardware.nix
    ./03-access.nix
    ./04-service.nix
  ];
}
