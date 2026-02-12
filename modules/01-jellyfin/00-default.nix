# Jellyfin media server module
{ config, lib, pkgs, ... }:

with lib;

{
  options.myServices.jellyfin = {
    enable = mkEnableOption "Jellyfin media server";
    
    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "Open firewall ports for Jellyfin (TCP 8096, 8920 and UDP 1900, 7359)";
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

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/jellyfin";
      description = "Directory for Jellyfin data storage";
    };
  };

  config = mkIf config.myServices.jellyfin.enable {
    # Enable official Jellyfin service
    services.jellyfin = {
      enable = true;
      openFirewall = config.myServices.jellyfin.openFirewall;
      dataDir = config.myServices.jellyfin.dataDir;
      
      # Configure hardware acceleration if enabled
      hardwareAcceleration = mkIf config.myServices.jellyfin.hardwareAcceleration.enable {
        enable = true;
        type = config.myServices.jellyfin.hardwareAcceleration.type;
        device = config.myServices.jellyfin.hardwareAcceleration.device;
      };
    };

    # Add user to required groups for hardware acceleration
    users.users.jellyfin = mkIf config.myServices.jellyfin.hardwareAcceleration.enable {
      extraGroups = [ "video" "render" ];
    };

    # Optional: Add Jellyfin utilities to system packages
    environment.systemPackages = with pkgs; [
      jellyfin-ffmpeg  # FFmpeg optimized for Jellyfin
    ];
  };
}

