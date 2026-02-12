# Jellyfin module options
{ config, lib, ... }:

with lib;

{
  options.myServices.jellyfin = {
    enable = mkEnableOption "Jellyfin media server";
    
    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "Open firewall ports for Jellyfin (TCP 8096, 8920 and UDP 1900, 7359)";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/jellyfin";
      description = "Directory for Jellyfin data storage";
    };

    hardwareAcceleration = {
      enable = mkEnableOption "hardware acceleration for video transcoding";
      
      type = mkOption {
        type = types.enum [ "none" "vaapi" "nvenc" "qsv" "amf" "v4l2m2m" "rkmpp" ];
        default = "none";
        description = ''
          Hardware acceleration type:
          - none: No hardware acceleration
          - vaapi: Video Acceleration API (Intel/AMD)
          - nvenc: NVIDIA NVENC
          - qsv: Intel Quick Sync Video
          - amf: AMD Advanced Media Framework
          - v4l2m2m: Video4Linux Memory-to-Memory
          - rkmpp: Rockchip Media Process Platform
        '';
      };
      
      device = mkOption {
        type = types.nullOr types.path;
        default = "/dev/dri/renderD128";
        example = "/dev/dri/renderD128";
        description = "Path to hardware acceleration device";
      };
    };

    mediaLibraries = mkOption {
      type = types.listOf types.path;
      default = [];
      example = [ "/home/jason/Downloads" "/mnt/media" ];
      description = ''
        List of directories containing media files that Jellyfin should have access to.
        The jellyfin user will be granted read permissions to these directories.
        Configure this per-host in your host's configuration.nix, not here.
      '';
    };

    watchDownloadsFolder = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Automatically add the user's Downloads folder to mediaLibraries.
        Uses: /home/{watchUsername}/Downloads
      '';
    };

    watchUsername = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "jason";
      description = ''
        Username whose directories Jellyfin should access.
        The jellyfin user will be added to this user's group for read access.
        Required if watchDownloadsFolder is enabled or if using mediaLibraries.
      '';
    };
  };
}
