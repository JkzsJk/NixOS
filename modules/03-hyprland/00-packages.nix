# Hyprland companion packages
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myDesktop.hyprland;
in
{
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Wayland essentials
      wl-clipboard           # Clipboard (wl-copy / wl-paste)
      kitty                  # Terminal emulator (Hyprland default)

      # Status bar
      waybar

      # App launcher
      rofi                   # App launcher (Wayland support merged in)

      # Notifications
      mako                   # Lightweight notification daemon

      # Wallpaper
      swww                   # Wallpaper daemon

      # Screenshot
      grim                   # Screenshot tool
      slurp                  # Region selection

      # Screen locking
      hyprlock               # Hyprland's lock screen
      hypridle               # Idle management daemon

      # File manager
      networkmanagerapplet   # Network manager tray icon
    ];
  };
}
