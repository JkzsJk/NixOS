# WireGuard service configuration
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myServices.wireguard;
in
{
  config = mkIf cfg.enable {
    # Enable WireGuard kernel module
    boot.extraModulePackages = [ config.boot.kernelPackages.wireguard ];
    
    # Enable IP forwarding if needed
    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = mkDefault 1;
      "net.ipv6.conf.all.forwarding" = mkDefault 1;
    };

    # Configure WireGuard interfaces
    networking.wireguard.interfaces = mapAttrs (name: interfaceCfg: {
      # Read private key from file
      privateKeyFile = interfaceCfg.privateKeyFile;

      # IP addresses for this interface
      ips = interfaceCfg.address;

      # MTU setting
      mtu = interfaceCfg.mtu;

      # Configure peers (VPN servers)
      peers = map (peer: {
        inherit (peer) publicKey endpoint allowedIPs persistentKeepalive;
        presharedKeyFile = peer.presharedKeyFile;
      }) interfaceCfg.peers;

      # Post-up commands
      postSetup = concatStringsSep "\n" (
        interfaceCfg.postUp ++
        (optional (interfaceCfg.dns != []) 
          "resolvectl dns ${name} ${concatStringsSep " " interfaceCfg.dns}") ++
        (optional (interfaceCfg.dns != [])
          "resolvectl domain ${name} '~.'")
      );

      # Post-down commands
      postShutdown = concatStringsSep "\n" interfaceCfg.postDown;

    }) cfg.interfaces;

    # Kill switch implementation
    networking.firewall = mkIf cfg.enableKillSwitch {
      extraCommands = ''
        # Allow loopback
        iptables -A OUTPUT -o lo -j ACCEPT
        
        # Allow local network
        iptables -A OUTPUT -d 192.168.0.0/16 -j ACCEPT
        iptables -A OUTPUT -d 10.0.0.0/8 -j ACCEPT
        iptables -A OUTPUT -d 172.16.0.0/12 -j ACCEPT
        
        # Allow VPN interfaces
        ${concatStringsSep "\n" (mapAttrsToList (name: _: 
          "iptables -A OUTPUT -o ${name} -j ACCEPT"
        ) cfg.interfaces)}
        
        # Block everything else (kill switch)
        iptables -A OUTPUT -j REJECT
      '';
      
      extraStopCommands = ''
        # Clean up kill switch rules
        iptables -D OUTPUT -j REJECT 2>/dev/null || true
      '';
    };

    # Enable systemd-resolved for DNS management
    services.resolved.enable = true;

    # Assertions for validation
    assertions = flatten (mapAttrsToList (name: interfaceCfg: [
      {
        assertion = interfaceCfg.peers != [];
        message = "WireGuard interface ${name} must have at least one peer configured";
      }
      {
        assertion = interfaceCfg.address != [];
        message = "WireGuard interface ${name} must have at least one IP address";
      }
      {
        assertion = pathExists interfaceCfg.privateKeyFile;
        message = "WireGuard private key file ${interfaceCfg.privateKeyFile} does not exist for interface ${name}";
      }
    ]) cfg.interfaces);
  };
}
