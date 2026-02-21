# Deluge module options
{ config, lib, pkgs, ... }:

with lib;

let
  openFilesLimit = 4096;
  listenPortsDefault = [ 6881 6889 ];
in
{
  options = {
    myServices = {
      deluge = {
        enable = mkEnableOption "Deluge daemon";

        openFilesLimit = mkOption {
          default = openFilesLimit;
          type = types.either types.int types.str;
          description = ''
            Number of files to allow deluged to open.
          '';
        };

        config = mkOption {
          type = types.attrs;
          default = { };
          example = literalExpression ''
            {
              download_location = "/srv/torrents/";
              max_upload_speed = "1000.0";
              share_ratio_limit = "2.0";
              allow_remote = true;
              daemon_port = 58846;
              listen_ports = [ ${toString listenPortsDefault} ];
            }
          '';
          description = ''
            Deluge core configuration for the core.conf file. Only has an effect
            when {option}`myServices.deluge.declarative` is set to
            `true`. String values must be quoted, integer and
            boolean values must not. See
            <https://git.deluge-torrent.org/deluge/tree/deluge/core/preferencesmanager.py#n41>
            for the available options.
          '';
        };

        declarative = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Whether to use a declarative deluge configuration.
            Only if set to `true`, the options
            {option}`myServices.deluge.config`,
            {option}`myServices.deluge.openFirewall` and
            {option}`myServices.deluge.authFile` will be
            applied.
          '';
        };

        openFirewall = mkOption {
          default = false;
          type = types.bool;
          description = ''
            Whether to open the firewall for the ports in
            {option}`myServices.deluge.config.listen_ports`. It only takes effect if
            {option}`myServices.deluge.declarative` is set to
            `true`.

            It does NOT apply to the daemon port nor the web UI port. To access those
            ports securely check the documentation
            <https://dev.deluge-torrent.org/wiki/UserGuide/ThinClient#CreateSSHTunnel>
            or use a VPN or configure certificates for deluge.
          '';
        };

        dataDir = mkOption {
          type = types.path;
          default = "/var/lib/deluge";
          description = ''
            The directory where deluge will create files.
          '';
        };

        authFile = mkOption {
          type = types.path;
          example = "/run/keys/deluge-auth";
          description = ''
            The file managing the authentication for deluge, the format of this
            file is straightforward, each line contains a
            username:password:level tuple in plaintext. It only has an effect
            when {option}`myServices.deluge.declarative` is set to
            `true`.
            See <https://dev.deluge-torrent.org/wiki/UserGuide/Authentication> for
            more information.
          '';
        };

        user = mkOption {
          type = types.str;
          default = "deluge";
          description = ''
            User account under which deluge runs.
          '';
        };

        group = mkOption {
          type = types.str;
          default = "deluge";
          description = ''
            Group under which deluge runs.
          '';
        };

        extraPackages = mkOption {
          type = types.listOf types.package;
          default = [ ];
          description = ''
            Extra packages available at runtime to enable Deluge's plugins. For example,
            extraction utilities are required for the built-in "Extractor" plugin.
            This always contains unzip, gnutar, xz and bzip2.
          '';
        };

        package = mkPackageOption pkgs "deluge-2_x" { };

        # VPN namespace configuration
        vpn = {
          enable = mkOption {
            type = types.bool;
            default = true;
            description = ''
              Enable VPN namespace isolation for Deluge.
              Requires WireGuard configuration.
            '';
          };

          namespace = mkOption {
            type = types.str;
            default = "wg";
            description = "Name of the network namespace for VPN isolation";
          };

          interface = mkOption {
            type = types.str;
            default = "wg0";
            description = "Name of the WireGuard interface";
          };

          configFile = mkOption {
            type = types.path;
            example = "/root/wireguard.conf";
            description = ''
              Path to WireGuard configuration file.
              This file should contain the VPN credentials.
              Keep it secure (chmod 600).
            '';
          };

          ipv4Address = mkOption {
            type = types.str;
            example = "10.8.0.2/24";
            description = "IPv4 VPN address with CIDR notation";
          };

          ipv6Address = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "fd00::2/64";
            description = "Optional IPv6 VPN address with CIDR notation";
          };
        };
      };

      deluge.web = {
        enable = mkEnableOption "Deluge Web daemon";

        port = mkOption {
          type = types.port;
          default = 8112;
          description = ''
            Deluge web UI port.
          '';
        };

        openFirewall = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Open ports in the firewall for deluge web daemon
          '';
        };
      };
    };
  };
}
