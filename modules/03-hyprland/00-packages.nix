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
      cliphist               # Clipboard history daemon (pairs with wl-clipboard + rofi)
      kitty                  # Terminal emulator (Hyprland's default)

      # Status bar (with experimental features enabled for calendar popup etc.)
      (pkgs.waybar.overrideAttrs (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
      }))

      # App launcher
      rofi                   # App launcher (Wayland support merged in)

      # Notifications
      mako                   # Lightweight notification daemon

      # Wallpaper
      swww                   # Wallpaper daemon

      # Screenshot
      grim                   # Screenshot tool
      slurp                  # Region selection
      jq                     # JSON processor (for active window screenshots)

      # Hint / help viewer
      bat                    # Syntax-highlighted file viewer (Super+H hint window)

      # Secrets / keyring — shared with KDE Plasma via KWallet
      kdePackages.kwallet          # KWallet daemon (same store as Plasma)
      kdePackages.kwallet-pam      # PAM integration (auto-unlock on login)
      kdePackages.ksshaskpass      # SSH key agent using KWallet

      # Screen locking
      hyprlock               # Hyprland's lock screen
      hypridle               # Idle management daemon

      # File manager
      networkmanagerapplet   # Network manager tray icon

      eww                    # Widget system (for custom status bars, etc.

      dunst                  # Notification daemon (alternative to mako, can be used if you want more customization options)

      mako                   # Notification daemon (lightweight, designed for Wayland)

      libnotify               # Library for sending notifications (used by some apps to send notifications on Wayland)
    ];
  };
}
