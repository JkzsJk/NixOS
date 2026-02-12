# Jellyfin module - auto-imports all configuration files
{ config, pkgs, ... }:

{
  imports = [
    ./01-jellyfin.nix
  ];
}
