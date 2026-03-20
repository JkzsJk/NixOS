# Default browser configuration
{ config, pkgs, inputs, ... }:

{
  # Set Vivaldi as default browser
  environment.sessionVariables.BROWSER = "vivaldi";

  # Force Vivaldi to run natively on Wayland (instead of XWayland).
  # --ozone-platform=wayland  — use the Wayland backend
  # --enable-features=WaylandWindowDecorations — use server-side decorations
  # --enable-wayland-ime  — fix input method (e.g. emoji, special chars) on Wayland
  environment.etc."vivaldi-flags.conf".text = ''
    --ozone-platform=wayland
    --enable-features=WaylandWindowDecorations
    --enable-wayland-ime
  '';

  xdg.mime.defaultApplications = {
    "text/html" = "vivaldi-stable.desktop";
    "x-scheme-handler/http" = "vivaldi-stable.desktop";
    "x-scheme-handler/https" = "vivaldi-stable.desktop";
    "x-scheme-handler/about" = "vivaldi-stable.desktop";
    "x-scheme-handler/unknown" = "vivaldi-stable.desktop";
  };
}
