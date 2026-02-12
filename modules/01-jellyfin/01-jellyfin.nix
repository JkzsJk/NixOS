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
      type = types.str;
      default = "jason";
      description = ''
        Username whose directories Jellyfin should access.
        The jellyfin user will be added to this user's group for read access.
      '';
    };
  };

  config = mkIf config.myServices.jellyfin.enable (
    let
      cfg = config.myServices.jellyfin;
      userHome = config.users.users.${cfg.watchUsername}.home;
      downloadsFolder = "${userHome}/Downloads";
      allMediaLibraries = cfg.mediaLibraries ++ (optional cfg.watchDownloadsFolder downloadsFolder);
    in
    {
    # Enable official Jellyfin service
    services.jellyfin = {
      enable = true;
      openFirewall = cfg.openFirewall;
      dataDir = cfg.dataDir;
      
      # Configure hardware acceleration if enabled
      hardwareAcceleration = mkIf cfg.hardwareAcceleration.enable {
        enable = true;
        type = cfg.hardwareAcceleration.type;
        device = cfg.hardwareAcceleration.device;
      };
    };

    # Add user to required groups for hardware acceleration
    users.users.jellyfin = mkIf cfg.hardwareAcceleration.enable {
      extraGroups = [ "video" "render" ];
    };

    # Grant Jellyfin access to user's media directories
    users.users.jellyfin = mkIf (allMediaLibraries != []) {
      extraGroups = [ cfg.watchUsername ];
    };

    # Set proper permissions on media directories
    systemd.tmpfiles.rules = 
      map (dir: "d ${dir} 0755 ${cfg.watchUsername} ${cfg.watchUsername} -") 
      allMediaLibraries;

    # Optional: Add Jellyfin utilities to system packages
    environment.systemPackages = with pkgs; [
      jellyfin-ffmpeg  # FFmpeg optimized for Jellyfin
    ];
  });
}
