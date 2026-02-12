# Jellyfin media library access and permissions
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myServices.jellyfin;
  
  # Computed values
  hasMediaLibraries = cfg.mediaLibraries != [];
  needsUserAccess = hasMediaLibraries || cfg.watchDownloadsFolder;
  
  # Media directory permissions
  mediaDirPerms = "0755";
  
  # Only evaluate user details when actually needed
  userConfig = optionalAttrs needsUserAccess {
    inherit (config.users.users.${cfg.watchUsername}) home;
  };
  
  downloadsFolder = "${userConfig.home or ""}/Downloads";
  
  allMediaLibraries = cfg.mediaLibraries 
    ++ (optional cfg.watchDownloadsFolder downloadsFolder);
in
{
  config = mkIf (cfg.enable && needsUserAccess) {
    # Assertions to catch configuration errors early
    assertions = [
      {
        assertion = cfg.watchUsername != null;
        message = "myServices.jellyfin.watchUsername must be set when using mediaLibraries or watchDownloadsFolder";
      }
      {
        assertion = cfg.watchUsername != null -> hasAttr cfg.watchUsername config.users.users;
        message = "myServices.jellyfin.watchUsername '${cfg.watchUsername}' does not exist in system users";
      }
    ];

    # Add jellyfin user to the watch user's group for media access
    users.users.jellyfin.extraGroups = [ cfg.watchUsername ];

    # Set proper permissions on media directories
    systemd.tmpfiles.rules = 
      map (dir: "d ${dir} ${mediaDirPerms} ${cfg.watchUsername} ${cfg.watchUsername} -") 
      allMediaLibraries;
  };
}
