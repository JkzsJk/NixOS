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

    # Use KWallet as the secrets backend so credentials are shared with KDE Plasma.
    # kwalletd is already present via plasma6; this wires up the libsecret bridge
    # so non-KDE apps (Vivaldi, Warp, etc.) can use it transparently.
    security.pam.services.sddm.kwallet.enable = true;
  };
}
