# Jellyfin media library access and permissions
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myServices.jellyfin;
  
  # Computed values
  hasMediaLibraries = cfg.mediaLibraries != [];
  needsUserAccess = hasMediaLibraries || cfg.watchDownloadsFolder;
  
  # Media directory permissions: owner rwx, group rwx, others none, setgid bit
  # setgid (2770) ensures new files always inherit the 'media' group
  mediaDirPerms = "2770";
  
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

    # Create dedicated media group for secure media access
    users.groups.media = {
      members = [ "jellyfin" cfg.watchUsername ];
    };

    # Set proper permissions on media directories
    # Directories owned by user, group 'media', setgid so new files inherit group
    systemd.tmpfiles.rules = 
      map (dir: "d ${dir} ${mediaDirPerms} ${cfg.watchUsername} media -") 
      allMediaLibraries;

    # Fix ownership of any file copied in by another user.
    # Runs whenever a change is detected in any media directory.
    systemd.services.jellyfin-media-chown = {
      description = "Fix ownership of new media files";
      serviceConfig = {
        Type = "oneshot";
        ExecStart =
          let
            dirs = lib.escapeShellArgs allMediaLibraries;
            script = pkgs.writeShellScript "jellyfin-media-chown" ''
              find ${dirs} -not \( -user jellyfin -a -group media \) \
                -exec chown jellyfin:media {} + \
                -exec chmod g+rw {} +
            '';
          in
            "${script}";
      };
    };

    systemd.paths.jellyfin-media-chown = {
      description = "Watch media directories for new files";
      wantedBy = [ "multi-user.target" ];
      pathConfig.PathChanged = allMediaLibraries;
    };
  };
}
