# WireGuard VPN setup in isolated namespace
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myServices.deluge;
  ns = cfg.vpn.namespace;
  iface = cfg.vpn.interface;
in
{
  config = mkIf (cfg.enable && cfg.vpn.enable) {
    # Assertions for VPN requirements
    assertions = [
      {
        assertion = cfg.vpn.configFile != null;
        message = "myServices.deluge.vpn.configFile must be set when VPN is enabled";
      }
      {
        assertion = cfg.vpn.ipv4Address != null && cfg.vpn.ipv4Address != "";
        message = "myServices.deluge.vpn.ipv4Address must be set when VPN is enabled";
      }
    ];

    # Add wireguard-tools to system packages
    environment.systemPackages = with pkgs; [
      wireguard-tools
      iproute2
    ];

    # WireGuard interface in network namespace
    systemd.services.wg = {
      description = "WireGuard VPN interface in ${ns} namespace";
      bindsTo = [ "netns@${ns}.service" ];
      requires = [ "network-online.target" ];
      after = [ "netns@${ns}.service" ];
      
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        
        ExecStart = pkgs.writers.writeBash "wg-up" ''
          set -e
          
          # Clean up any existing interface first
          ${pkgs.iproute2}/bin/ip link del ${iface} 2>/dev/null || true
          ${pkgs.iproute2}/bin/ip -n ${ns} link del ${iface} 2>/dev/null || true
          
          # Create WireGuard interface and move to namespace
          ${pkgs.iproute2}/bin/ip link add ${iface} type wireguard
          ${pkgs.iproute2}/bin/ip link set ${iface} netns ${ns}
          
          # Configure IPv4 address
          ${pkgs.iproute2}/bin/ip -n ${ns} address add ${cfg.vpn.ipv4Address} dev ${iface}
          
          # Configure IPv6 if provided
          ${optionalString (cfg.vpn.ipv6Address != null) ''
            ${pkgs.iproute2}/bin/ip -n ${ns} -6 address add ${cfg.vpn.ipv6Address} dev ${iface}
          ''}
          
          # Apply WireGuard configuration
          # Strip out non-wg fields (Address, DNS, MTU, etc.) that wg setconf doesn't understand
          ${pkgs.gnugrep}/bin/grep -vE '^(Address|DNS|MTU|Table|PreUp|PostUp|PreDown|PostDown)\s*=' ${cfg.vpn.configFile} | \
            ${pkgs.iproute2}/bin/ip netns exec ${ns} \
            ${pkgs.wireguard-tools}/bin/wg setconf ${iface} /dev/stdin
          
          # Bring up interface and loopback
          ${pkgs.iproute2}/bin/ip -n ${ns} link set ${iface} up
          ${pkgs.iproute2}/bin/ip -n ${ns} link set lo up
          
          # Set default route through VPN
          ${pkgs.iproute2}/bin/ip -n ${ns} route add default dev ${iface}
          ${optionalString (cfg.vpn.ipv6Address != null) ''
            ${pkgs.iproute2}/bin/ip -n ${ns} -6 route add default dev ${iface}
          ''}
          
          echo "WireGuard VPN active in namespace ${ns}"
        '';
        
        ExecStop = pkgs.writers.writeBash "wg-down" ''
          # Remove routes
          ${pkgs.iproute2}/bin/ip -n ${ns} route del default dev ${iface} || true
          ${optionalString (cfg.vpn.ipv6Address != null) ''
            ${pkgs.iproute2}/bin/ip -n ${ns} -6 route del default dev ${iface} || true
          ''}
          
          # Delete interface
          ${pkgs.iproute2}/bin/ip -n ${ns} link del ${iface} || true
        '';
      };
    };
  };
}
