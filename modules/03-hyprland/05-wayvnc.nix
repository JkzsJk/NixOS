# wayvnc — VNC server for wlr-based Wayland compositors (Hyprland).
# Allows full desktop remote access over VNC.
#
# Usage (local network):
#   Connect any VNC client to <machine-ip>:5900
#
# Usage (over internet via Tailscale):
#   ssh -L 5900:localhost:5900 jason@<tailscale-ip>
#   Then connect VNC client to localhost:5900
#
# wayvnc is started by start.sh on Hyprland launch.
# Listens only on localhost (127.0.0.1) by default — never exposed directly.
# Remote access requires tunnelling through SSH or Tailscale.
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myDesktop.hyprland;
in
{
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      wayvnc   # VNC server for wlroots/Hyprland
      tigervnc # VNC client (for connecting to other machines from this one)
    ];

    # wayvnc itself needs no firewall port — it listens on localhost only.
    # VNC access is tunnelled through SSH or Tailscale.
  };
}
