# Default browser configuration
{ config, pkgs, inputs, ... }:

{
  # Install Vivaldi with kwallet6 baked in via package override (NixOS wiki approach).
  # commandLineArgs is the correct way to pass flags on NixOS — vivaldi-flags.conf
  # is not reliably read from /etc on NixOS.
  environment.systemPackages = [
    (pkgs.vivaldi.override {
      commandLineArgs = [
        "--ozone-platform=wayland"
        "--enable-features=WaylandWindowDecorations"
        "--enable-wayland-ime"
        "--password-store=kwallet6"
      ];
    })
  ];

  # Set Vivaldi as default browser
  environment.sessionVariables.BROWSER = "vivaldi";

  xdg.mime.defaultApplications = {
    "text/html" = "vivaldi-stable.desktop";
    "x-scheme-handler/http" = "vivaldi-stable.desktop";
    "x-scheme-handler/https" = "vivaldi-stable.desktop";
    "x-scheme-handler/about" = "vivaldi-stable.desktop";
    "x-scheme-handler/unknown" = "vivaldi-stable.desktop";
  };
}
