# WireGuard VPN module options
{ config, lib, ... }:

with lib;

{
  options.myServices.wireguard = {
    enable = mkEnableOption "WireGuard VPN client";

    interfaces = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          privateKeyFile = mkOption {
            type = types.path;
            example = "/root/wireguard-private.key";
            description = ''
              Path to file containing the private key.
              Generate with: wg genkey > /root/wireguard-private.key
              Protect with: chmod 600 /root/wireguard-private.key
            '';
          };

          address = mkOption {
            type = types.listOf types.str;
            example = [ "10.8.0.2/24" ];
            description = "List of IP addresses for this interface";
          };

          dns = mkOption {
            type = types.listOf types.str;
            default = [];
            example = [ "10.8.0.1" "1.1.1.1" ];
            description = "DNS servers to use for this connection";
          };

          peers = mkOption {
            type = types.listOf (types.submodule {
              options = {
                publicKey = mkOption {
                  type = types.str;
                  description = "Public key of the peer (VPN server)";
                };

                endpoint = mkOption {
                  type = types.str;
                  example = "vpn.provider.com:51820";
                  description = "Endpoint address and port of the peer";
                };

                allowedIPs = mkOption {
                  type = types.listOf types.str;
                  default = [ "0.0.0.0/0" "::/0" ];
                  description = "IPs that will be routed through this peer";
                };

                persistentKeepalive = mkOption {
                  type = types.nullOr types.int;
                  default = 25;
                  description = "Send keepalive packets every N seconds";
                };

                presharedKeyFile = mkOption {
                  type = types.nullOr types.path;
                  default = null;
                  description = "Optional preshared key file for additional security";
                };
              };
            });
            description = "List of WireGuard peers (VPN servers)";
          };

          postUp = mkOption {
            type = types.listOf types.str;
            default = [];
            example = [ "iptables -A FORWARD -i %i -j ACCEPT" ];
            description = "Commands to run after interface is up";
          };

          postDown = mkOption {
            type = types.listOf types.str;
            default = [];
            example = [ "iptables -D FORWARD -i %i -j ACCEPT" ];
            description = "Commands to run after interface is down";
          };

          mtu = mkOption {
            type = types.nullOr types.int;
            default = null;
            example = 1420;
            description = "MTU size for the interface";
          };
        };
      });
      default = {};
      example = {
        wg0 = {
          privateKeyFile = "/root/wireguard-private.key";
          address = [ "10.8.0.2/24" ];
          dns = [ "10.8.0.1" ];
          peers = [{
            publicKey = "SERVER_PUBLIC_KEY";
            endpoint = "vpn.example.com:51820";
            allowedIPs = [ "0.0.0.0/0" ];
          }];
        };
      };
      description = "WireGuard interfaces to configure";
    };

    enableKillSwitch = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable kill switch to block all traffic when VPN is down.
        WARNING: This will block internet if VPN disconnects.
      '';
    };
  };
}
