# Deluge module - auto-imports all configuration files
{ config, pkgs, ... }:

{
  imports = [
    ./00-packages.nix
    ./01-options.nix
    ./02-namespace.nix
    ./03-wireguard.nix
    ./04-service.nix
    ./05-web.nix
  ];
}
