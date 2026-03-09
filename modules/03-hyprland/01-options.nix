# Hyprland module options
{ config, lib, ... }:

with lib;

{
  options.myDesktop.hyprland = {
    enable = mkEnableOption "Hyprland Wayland compositor";
  };
}
