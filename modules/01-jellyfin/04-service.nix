# Jellyfin service and packages
{ config, lib, pkgs, ... }:

with lib;

{
  config = mkIf config.myServices.jellyfin.enable {
    # Enable official Jellyfin service
    services.jellyfin = {
      enable = true;
      openFirewall = config.myServices.jellyfin.openFirewall;
      dataDir = config.myServices.jellyfin.dataDir;
    };

    # Add Jellyfin utilities to system packages
    environment.systemPackages = with pkgs; [
      jellyfin-ffmpeg
    ];
  };
}
