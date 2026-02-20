# Deluge daemon service with VPN namespace binding and proxy socket
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myServices.deluge;
  ns = cfg.vpn.namespace;
in
{
  config = mkIf cfg.enable {
    # Create deluge user and group
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = cfg.dataDir;
      createHome = true;
      description = "Deluge daemon user";
    };

    users.groups.${cfg.group} = {};

    # Ensure download directory exists with correct permissions
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 ${cfg.user} ${cfg.group} -"
      "d ${cfg.downloadDir} 0750 ${cfg.user} ${cfg.group} -"
    ];

    # Enable Deluge daemon service
    services.deluge = {
      enable = true;
      dataDir = cfg.dataDir;
      user = cfg.user;
      group = cfg.group;
      
      # Bind to all interfaces within namespace
      declarative = true;
      config = {
        download_location = cfg.downloadDir;
        enabled_plugins = [];
        allow_remote = true;
      };
      
      openFilesLimit = 4096;
    };

    # Bind deluged to VPN namespace
    systemd.services.deluged = {
      bindsTo = [ "netns@${ns}.service" ];
      requires = [ "network-online.target" "${ns}-wireguard.service" ];
      after = [ "${ns}-wireguard.service" ];
      
      serviceConfig = {
        NetworkNamespacePath = "/var/run/netns/${ns}";
        # Restart on failure (e.g., VPN disconnect)
        Restart = "on-failure";
        RestartSec = "30s";
      };
    };

    # Socket for proxying daemon connections from root namespace
    systemd.sockets.proxy-to-deluged = {
      enable = true;
      description = "Socket for Proxy to Deluge Daemon";
      listenStreams = [ (toString cfg.daemon.port) ];
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
        ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=5min 127.0.0.1:${toString cfg.daemon.port}";
        PrivateNetwork = true;
      };
    };

    # Firewall rules for daemon (if enabled)
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.daemon.port ];
    };
  };
}
