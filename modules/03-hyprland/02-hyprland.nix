# Hyprland compositor configuration
{ config, lib, ... }:

with lib;

let
  cfg = config.myDesktop.hyprland;
in
{
  config = mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    environment.sessionVariables = {
      # If cursor becomes invisible on Intel/NVIDIA hybrid setups
      WLR_NO_HARDWARE_CURSORS = "1";
      # Hint Electron apps to use Wayland
      NIXOS_OZONE_WL = "1";
    };

    hardware = {
      # Required for Wayland compositors
      graphics.enable = true;
    };
  };
}
