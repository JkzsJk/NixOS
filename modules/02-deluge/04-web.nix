# Deluge web UI service
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myServices.deluge;
  cfg_web = config.myServices.deluge.web;
  isDeluge1 = versionOlder cfg.package.version "2.0.0";
  configDir = "${cfg.dataDir}/.config/deluge";
in
{
  config = mkIf (cfg.enable && cfg_web.enable) {
    systemd.services.delugeweb = {
      after = [
        "network.target"
        "deluged.service"
      ];
      requires = [ "deluged.service" ];
      description = "Deluge BitTorrent WebUI";
      wantedBy = [ "multi-user.target" ];
      path = [ cfg.package ];
      
      serviceConfig = {
        ExecStart = ''
          ${cfg.package}/bin/deluge-web \
            ${optionalString (!isDeluge1) "--do-not-daemonize"} \
            --config ${configDir} \
            --port ${toString cfg.web.port}
        '';
        User = cfg.user;
        Group = cfg.group;
      };
    };
  };
}
