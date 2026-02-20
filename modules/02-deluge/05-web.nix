# Deluge web UI configuration
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myServices.deluge;
in
{
  config = mkIf (cfg.enable && cfg.web.enable) {
    # Enable Deluge web UI
    services.deluge.web = {
      enable = true;
      port = cfg.web.port;
      openFirewall = cfg.web.openFirewall;
    };

    # Web UI runs in root namespace, connects to daemon via proxy socket
    systemd.services.delugeweb = {
      requires = [ "proxy-to-deluged.socket" ];
      after = [ "proxy-to-deluged.socket" ];
    };

    # Additional firewall rule if needed
    networking.firewall = mkIf cfg.web.openFirewall {
      allowedTCPPorts = [ cfg.web.port ];
    };
  };
}
