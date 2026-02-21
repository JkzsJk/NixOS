# Deluge user and group management
{ config, lib, ... }:

with lib;

let
  cfg = config.services.deluge;
in
{
  config = mkIf cfg.enable {
    # Create deluge user if using default user
    users.users = mkIf (cfg.user == "deluge") {
      deluge = {
        group = cfg.group;
        uid = config.ids.uids.deluge;
        home = cfg.dataDir;
        description = "Deluge Daemon user";
      };
    };

    # Create deluge group if using default group
    users.groups = mkIf (cfg.group == "deluge") {
      deluge = {
        gid = config.ids.gids.deluge;
      };
    };

    # Create necessary directories with correct permissions
    systemd.tmpfiles.settings."10-deluged" =
      let
        defaultConfig = {
          inherit (cfg) user group;
          mode = "0770";
        };
      in
      {
        "${cfg.dataDir}".d = defaultConfig;
        "${cfg.dataDir}/.config".d = defaultConfig;
        "${cfg.dataDir}/.config/deluge".d = defaultConfig;
      }
      // optionalAttrs (cfg.config ? download_location) {
        ${cfg.config.download_location}.d = defaultConfig;
      }
      // optionalAttrs (cfg.config ? torrentfiles_location) {
        ${cfg.config.torrentfiles_location}.d = defaultConfig;
      }
      // optionalAttrs (cfg.config ? move_completed_path) {
        ${cfg.config.move_completed_path}.d = defaultConfig;
      };
  };
}
