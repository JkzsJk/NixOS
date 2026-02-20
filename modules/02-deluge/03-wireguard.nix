# WireGuard VPN setup in isolated namespace
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myServices.deluge;
  wgCfg = config.myServices.wireguard;
  ns = cfg.vpn.namespace;
  iface = cfg.vpn.interface;
  
  # Safely get WireGuard config from shared module if enabled
  # Wrapped in conditional to avoid evaluation errors
  sharedWgInterface = 
    if cfg.vpn.useSharedConfig && cfg.vpn.wireguardInterface != null
    then wgCfg.interfaces.${cfg.vpn.wireguardInterface}
    else null;
  
  # Safely get first peer from shared config
  sharedPeer = if sharedWgInterface != null && (length sharedWgInterface.peers) > 0
    then head sharedWgInterface.peers
    else null;
  
  # Determine VPN configuration source with safety checks
  vpnAddress = 
    if cfg.vpn.useSharedConfig && sharedWgInterface != null
    then 
      if (length sharedWgInterface.address) > 0
      then head sharedWgInterface.address
      else throw "deluge: WireGuard interface '${cfg.vpn.wireguardInterface}' has no addresses configured"
    else cfg.vpn.address;
    
  vpnAddressV6 = 
    if cfg.vpn.useSharedConfig && sharedWgInterface != null
    then findFirst (addr: hasInfix ":" addr) null sharedWgInterface.address
    else cfg.vpn.addressV6;
    
  vpnDns = 
    if cfg.vpn.useSharedConfig && sharedWgInterface != null
    then sharedWgInterface.dns
    else cfg.vpn.dns;
in
{
  config = mkIf cfg.enable {
    # Assertions for configuration validation
    assertions = [
      {
        assertion = cfg.vpn.useSharedConfig -> (cfg.vpn.wireguardInterface != null);
        message = "deluge: vpn.wireguardInterface must be set when vpn.useSharedConfig is true";
      }
      {
        assertion = cfg.vpn.useSharedConfig -> (wgCfg.enable);
        message = "deluge: myServices.wireguard must be enabled when vpn.useSharedConfig is true";
      }
      {
        assertion = cfg.vpn.useSharedConfig -> (hasAttr cfg.vpn.wireguardInterface wgCfg.interfaces);
        message = "deluge: WireGuard interface '${cfg.vpn.wireguardInterface}' not found in myServices.wireguard.interfaces";
      }
      {
        assertion = cfg.vpn.useSharedConfig -> (sharedWgInterface != null && (length sharedWgInterface.peers) > 0);
        message = "deluge: WireGuard interface '${cfg.vpn.wireguardInterface}' must have at least one peer configured";
      }
      {
        assertion = cfg.vpn.useSharedConfig -> (sharedWgInterface != null && (length sharedWgInterface.address) > 0);
        message = "deluge: WireGuard interface '${cfg.vpn.wireguardInterface}' must have at least one address configured";
      }
      {
        assertion = !cfg.vpn.useSharedConfig -> (cfg.vpn.configFile != null || cfg.vpn.privateKeyFile != null);
        message = "deluge: Either vpn.configFile or vpn.privateKeyFile must be set when not using shared config";
      }
      {
        assertion = !cfg.vpn.useSharedConfig -> (cfg.vpn.address != null);
        message = "deluge: vpn.address must be set when not using shared config";
      }
      {
        assertion = (cfg.vpn.privateKeyFile != null) -> (cfg.vpn.publicKey != null && cfg.vpn.endpoint != null);
        message = "deluge: vpn.publicKey and vpn.endpoint must be set when using vpn.privateKeyFile";
      }
    ];
    
    # WireGuard interface in network namespace
    systemd.services."${ns}-wireguard" = {
      description = "WireGuard VPN interface for ${ns}";
      bindsTo = [ "netns@${ns}.service" ];
      requires = [ "network-online.target" ];
      after = [ "netns@${ns}.service" ];
      
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        
        ExecStart = pkgs.writeShellScript "${ns}-wg-up" ''
          set -e
          
          # Create temporary WireGuard config with secure permissions
          WG_CONFIG=$(mktemp)
          chmod 600 "$WG_CONFIG"
          trap "rm -f $WG_CONFIG" EXIT
          
          # Build WireGuard configuration
          ${if cfg.vpn.useSharedConfig && sharedPeer != null then ''
            # Using credentials from WireGuard module
            cat > "$WG_CONFIG" << EOF
[Interface]
PrivateKey = $(cat ${sharedWgInterface.privateKeyFile})

[Peer]
PublicKey = ${sharedPeer.publicKey}
Endpoint = ${sharedPeer.endpoint}
AllowedIPs = ${concatStringsSep ", " sharedPeer.allowedIPs}
${optionalString (sharedPeer.persistentKeepalive != null) "PersistentKeepalive = ${toString sharedPeer.persistentKeepalive}"}
${optionalString (sharedPeer.presharedKeyFile != null) "PresharedKey = $(cat ${sharedPeer.presharedKeyFile})"}
EOF
          '' else if cfg.vpn.configFile != null then ''
            # Using standalone config file
            cat ${cfg.vpn.configFile} > "$WG_CONFIG"
          '' else ''
            # Building from individual options
            cat > "$WG_CONFIG" << EOF
[Interface]
PrivateKey = $(cat ${cfg.vpn.privateKeyFile})

[Peer]
PublicKey = ${cfg.vpn.publicKey}
Endpoint = ${cfg.vpn.endpoint}
AllowedIPs = 0.0.0.0/0${optionalString (cfg.vpn.addressV6 != null) ", ::/0"}
PersistentKeepalive = 25
EOF
          ''}
          
          # Create WireGuard interface and move to namespace
          ${pkgs.iproute2}/bin/ip link add ${iface} type wireguard
          ${pkgs.iproute2}/bin/ip link set ${iface} netns ${ns}
          
          # Configure IPv4 address
          ${pkgs.iproute2}/bin/ip -n ${ns} address add ${vpnAddress} dev ${iface}
          
          # Configure IPv6 if provided
          ${optionalString (vpnAddressV6 != null) ''
            ${pkgs.iproute2}/bin/ip -n ${ns} -6 address add ${vpnAddressV6} dev ${iface}
          ''}
          
          # Apply WireGuard configuration
          ${pkgs.iproute2}/bin/ip netns exec ${ns} \
            ${pkgs.wireguard-tools}/bin/wg setconf ${iface} "$WG_CONFIG"
          
          # Bring up interface and loopback
          ${pkgs.iproute2}/bin/ip -n ${ns} link set ${iface} up
          ${pkgs.iproute2}/bin/ip -n ${ns} link set lo up
          
          # Set default route through VPN
          ${pkgs.iproute2}/bin/ip -n ${ns} route add default dev ${iface}
          ${optionalString (vpnAddressV6 != null) ''
            ${pkgs.iproute2}/bin/ip -n ${ns} -6 route add default dev ${iface}
          ''}
          
          echo "WireGuard VPN active in namespace ${ns}"
        '';
        
        ExecStop = pkgs.writeShellScript "${ns}-wg-down" ''
          # Remove routes
          ${pkgs.iproute2}/bin/ip -n ${ns} route del default dev ${iface} || true
          ${optionalString (vpnAddressV6 != null) ''
            ${pkgs.iproute2}/bin/ip -n ${ns} -6 route del default dev ${iface} || true
          ''}
          
          # Delete interface
          ${pkgs.iproute2}/bin/ip -n ${ns} link del ${iface} || true
        '';
      };
    };
  };
}
