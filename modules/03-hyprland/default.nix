{ config, pkgs, ... }:
{
  imports = [
    ./00-packages.nix
    ./01-options.nix
    ./02-hyprland.nix
    ./03-xdg.nix
  ];
}
