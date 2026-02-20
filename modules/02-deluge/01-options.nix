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

      # Option 1: Use shared WireGuard module configuration
      useSharedConfig = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Reuse VPN credentials from myServices.wireguard module.
          
          IMPORTANT: This creates a SEPARATE VPN connection in an isolated namespace.
          - Deluge traffic: Goes through VPN (in isolated namespace)
          - System traffic: Uses normal internet (or WireGuard module if enabled separately)
          
          This option only shares the CREDENTIALS (keys, server details), not the connection itself.
          When enabled, wireguardInterface must be set to reference the WireGuard module config.
        '';
      };

      wireguardInterface = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "wg0";
        description = ''
          Name of the WireGuard interface from myServices.wireguard module to copy credentials from.
          Only used when useSharedConfig = true.
          
          Note: This does NOT use the actual wg0 interface. It copies the credentials
          to create a separate isolated VPN connection (wg-deluge) for Deluge only.
        '';
      };

      # Option 2: Standalone configuration (legacy)
      configFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        example = "/root/wireguard-deluge.conf";
        description = ''
          Path to WireGuard configuration file.
          Must contain PrivateKey, PublicKey, Endpoint, etc.
          Keep this file secure (root-only readable).
          Only used when useSharedConfig = false.
        '';
      };

      privateKeyFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        example = "/root/wireguard-private.key";
        description = ''
          Path to WireGuard private key file (alternative to configFile).
          Use with address, endpoint, and publicKey options.
          Only used when useSharedConfig = false and configFile = null.
        '';
      };

      publicKey = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "SERVER_PUBLIC_KEY_HERE";
        description = ''
          WireGuard server public key.
          Required when using privateKeyFile.
          Only used when useSharedConfig = false.
        '';
      };

      address = mkOption {
        type = types.nullOr types.str;
        default = null;
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
        type = types.nullOr types.str;
        default = null;
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
