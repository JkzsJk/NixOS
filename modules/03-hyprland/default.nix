{ config, pkgs, inputs, ... }:
{
  imports = [
    ./00-packages.nix
    ./01-options.nix
    ./02-hyprland.nix
    ./03-xdg.nix
    ./04-config.nix
    ./05-wayvnc.nix
  ];
}
