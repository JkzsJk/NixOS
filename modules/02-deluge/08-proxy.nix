# Proxy socket for connecting web UI to daemon in namespace
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.deluge;
in
{
  config = mkIf (cfg.enable && cfg.vpn.enable) {
    # Socket for proxying daemon connections from root namespace
    systemd.sockets.proxy-to-deluged = {
      enable = true;
      description = "Socket for Proxy to Deluge Daemon";
      listenStreams = [ "58846" ];
      wantedBy = [ "sockets.target" ];
    };

    # Proxy service to forward connections into VPN namespace
    systemd.services.proxy-to-deluged = {
      enable = true;
      description = "Proxy to Deluge Daemon in VPN Namespace";
      requires = [ "deluged.service" "proxy-to-deluged.socket" ];
      after = [ "deluged.service" "proxy-to-deluged.socket" ];
      
      unitConfig = {
        JoinsNamespaceOf = "deluged.service";
      };
      
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=5min 127.0.0.1:58846";
        PrivateNetwork = "yes";
      };
    };
  };
}
