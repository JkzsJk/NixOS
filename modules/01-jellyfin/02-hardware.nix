# Jellyfin hardware acceleration configuration
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myServices.jellyfin;
  
  # Hardware acceleration groups
  hwAccelGroups = [ "video" "render" ];
  
  # Hardware acceleration packages based on type
  hwAccelPackages = with pkgs; {
    vaapi = [ intel-media-driver vaapiIntel vaapiVdpau libvdpau-va-gl ];
    qsv = [ intel-media-driver intel-compute-runtime ];
    nvenc = [ ];  # NVIDIA drivers provide this
    amf = [ ];    # AMD drivers provide this
    v4l2m2m = [ ];
    rkmpp = [ ];
    none = [ ];
  };
in
{
  config = mkIf (cfg.enable && cfg.hardwareAcceleration.enable) {
    # Configure hardware acceleration packages based on type
    hardware.graphics.extraPackages = hwAccelPackages.${cfg.hardwareAcceleration.type} or [];

    # Add jellyfin user to required groups for hardware acceleration
    users.users.jellyfin.extraGroups = hwAccelGroups;
  };
}
