# Deluge module options
{ config, lib, ... }:

with lib;

{
  options.myServices.deluge = {
    enable = mkEnableOption "Deluge BitTorrent client with VPN namespace isolation";
    
    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open firewall for incoming connections (torrenting ports)";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/deluge";
      description = "Directory for Deluge data storage";
    };

    downloadDir = mkOption {
      type = types.path;
      default = "/var/lib/deluge/downloads";
      description = "Default download directory";
    };

    web = {
      enable = mkEnableOption "Deluge web UI" // { default = true; };
      
      port = mkOption {
        type = types.port;
        default = 8112;
        description = "Port for Deluge web UI";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = true;
        description = "Open firewall for web UI access";
      };
    };

    daemon = {
      port = mkOption {
        type = types.port;
        default = 58846;
        description = "Port for Deluge daemon (used by web UI and clients)";
      };
    };

    vpn = {
      namespace = mkOption {
        type = types.str;
        default = "delugevpn";
        description = "Name of the network namespace for VPN isolation";
      };

      interface = mkOption {
        type = types.str;
        default = "wg-deluge";
        description = "Name of the WireGuard interface";
      };

      configFile = mkOption {
        type = types.path;
        example = "/root/wireguard-deluge.conf";
        description = ''
          Path to WireGuard configuration file.
          Must contain PrivateKey, PublicKey, Endpoint, etc.
          Keep this file secure (root-only readable).
        '';
      };

      address = mkOption {
        type = types.str;
        example = "10.8.0.2/24";
        description = "VPN interface IPv4 address with CIDR notation";
      };

      addressV6 = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "fd00::2/64";
        description = "Optional VPN interface IPv6 address with CIDR notation";
      };

      endpoint = mkOption {
        type = types.str;
        example = "vpn.provider.com:51820";
        description = "WireGuard endpoint (server:port)";
      };

      dns = mkOption {
        type = types.listOf types.str;
        default = [];
        example = [ "10.8.0.1" "1.1.1.1" ];
        description = "DNS servers to use within VPN namespace";
      };
    };

    user = mkOption {
      type = types.str;
      default = "deluge";
      description = "User account for Deluge daemon";
    };

    group = mkOption {
      type = types.str;
      default = "deluge";
      description = "Group for Deluge daemon";
    };
  };
}
