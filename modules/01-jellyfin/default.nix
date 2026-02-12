# Jellyfin module - auto-imports all configuration files
{ config, pkgs, ... }:

{
  imports = [
    ./00-options.nix
    ./01-service.nix
    ./02-hardware.nix
    ./03-access.nix
  ];
}
