# Hyprland module options
{ config, lib, ... }:

with lib;

{
  options.myDesktop.hyprland = {
    enable = mkEnableOption "Hyprland Wayland compositor";

    user = mkOption {
      type        = types.str;
      description = "The user account that Hyprland config files will be written to.";
    };
  };
}
