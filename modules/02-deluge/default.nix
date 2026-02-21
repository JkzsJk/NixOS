# Deluge module - native NixOS deluge service split into modular structure
{ config, pkgs, ... }:

{
  imports = [
    ./00-packages.nix
    ./01-options.nix
    ./02-users.nix
    ./03-service.nix
    ./04-web.nix
    ./05-firewall.nix
  ];
}
