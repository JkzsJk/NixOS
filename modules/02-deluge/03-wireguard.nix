# WireGuard VPN setup in isolated namespace
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myServices.deluge;
  wgCfg = config.myServices.wireguard;
  ns = cfg.vpn.namespace;
  iface = cfg.vpn.interface;
  
  # Get WireGuard config from shared module if enabled
  sharedWgInterface = if cfg.vpn.useSharedConfig 
    then wgCfg.interfaces.${cfg.vpn.wireguardInterface}
    else null;
  
  # Determine VPN configuration source
  vpnAddress = if cfg.vpn.useSharedConfig 
    then head sharedWgInterface.address
    else cfg.vpn.address;
    
  vpnAddressV6 = if cfg.vpn.useSharedConfig
    then (findFirst (addr: hasInfix ":" addr) null sharedWgInterface.address)
    else cfg.vpn.addressV6;
    
  vpnDns = if cfg.vpn.useSharedConfig
    then sharedWgInterface.dns
    else cfg.vpn.dns;
    
  # Build WireGuard config content
  wgConfigContent = if cfg.vpn.useSharedConfig then
    # Use shared WireGuard module config
    let
      peer = head sharedWgInterface.peers;
    in ''
      [Interface]
      PrivateKey = $(cat ${sharedWgInterface.privateKeyFile})
      
      [Peer]
      PublicKey = ${peer.publicKey}
      Endpoint = ${peer.endpoint}
      AllowedIPs = ${concatStringsSep ", " peer.allowedIPs}
      ${optionalString (peer.persistentKeepalive != null) "PersistentKeepalive = ${toString peer.persistentKeepalive}"}
      ${optionalString (peer.presharedKeyFile != null) "PresharedKey = $(cat ${peer.presharedKeyFile})"}
    ''
  else if cfg.vpn.configFile != null then
    # Use standalone config file
    "$(cat ${cfg.vpn.configFile})"
  else
    # Build from individual options
    ''
      [Interface]
      PrivateKey = $(cat ${cfg.vpn.privateKeyFile})
      
      [Peer]
      PublicKey = ${cfg.vpn.publicKey}
      Endpoint = ${cfg.vpn.endpoint}
      AllowedIPs = 0.0.0.0/0${optionalString (cfg.vpn.addressV6 != null) ", ::/0"}
      PersistentKeepalive = 25
    '';
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
          
          # Create temporary WireGuard config
          WG_CONFIG=$(mktemp)
          trap "rm -f $WG_CONFIG" EXIT
          
          cat > $WG_CONFIG << 'EOF'
${wgConfigContent}
EOF
          
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
            ${pkgs.wireguard-tools}/bin/wg setconf ${iface} $WG_CONFIG
          
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
