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
    
    # Only enable IP forwarding if explicitly routing traffic through VPN
    # Most client-only setups don't need this
    # boot.kernel.sysctl = {
    #   "net.ipv4.ip_forward" = mkDefault 1;
    #   "net.ipv6.conf.all.forwarding" = mkDefault 1;
    # };

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
        # Configure DNS if specified
        (optional (interfaceCfg.dns != []) 
          "resolvectl dns ${name} ${concatStringsSep " " interfaceCfg.dns}") ++
        # Set this interface as DNS route for all domains only if DNS is configured
        # This makes it the default DNS resolver
        (optional (interfaceCfg.dns != [])
          "resolvectl domain ${name} '~.'") ++
        # Add kill switch rules per interface if enabled
        (optionals interfaceCfg.enableKillSwitch [
          # Mark packets from this interface
          "wg set ${name} fwmark 51820"
          # Allow VPN interface
          "iptables -A OUTPUT -o ${name} -j ACCEPT"
          # Allow marked packets (from VPN)
          "iptables -A OUTPUT -m mark --mark 51820 -j ACCEPT"
          # Block all other traffic (kill switch for this interface)
          "iptables -A OUTPUT -j REJECT --reject-with icmp-net-unreachable"
        ])
      );

      # Post-down commands
      postShutdown = concatStringsSep "\n" (
        interfaceCfg.postDown ++
        # Clean up kill switch rules if enabled
        (optionals interfaceCfg.enableKillSwitch [
          "iptables -D OUTPUT -o ${name} -j ACCEPT 2>/dev/null || true"
          "iptables -D OUTPUT -m mark --mark 51820 -j ACCEPT 2>/dev/null || true"
          "iptables -D OUTPUT -j REJECT --reject-with icmp-net-unreachable 2>/dev/null || true"
        ])
      );

    }) cfg.interfaces;

    # Kill switch implementation (deprecated - use per-interface enableKillSwitch instead)
    # networking.firewall = mkIf cfg.enableKillSwitch {
    # Kill switch implementation (deprecated - use per-interface enableKillSwitch instead)
    # networking.firewall = mkIf cfg.enableKillSwitch {
    #   extraCommands = ''
    #     # Allow loopback
    #     iptables -A OUTPUT -o lo -j ACCEPT
    #     
    #     # Allow local network
    #     iptables -A OUTPUT -d 192.168.0.0/16 -j ACCEPT
    #     iptables -A OUTPUT -d 10.0.0.0/8 -j ACCEPT
    #     iptables -A OUTPUT -d 172.16.0.0/12 -j ACCEPT
    #     
    #     # Allow VPN interfaces
    #     ${concatStringsSep "\n" (mapAttrsToList (name: _: 
    #       "iptables -A OUTPUT -o ${name} -j ACCEPT"
    #     ) cfg.interfaces)}
    #     
    #     # Block everything else (kill switch)
    #     iptables -A OUTPUT -j REJECT
    #   '';
    #   
    #   extraStopCommands = ''
    #     # Clean up kill switch rules
    #     iptables -D OUTPUT -j REJECT 2>/dev/null || true
    #   '';
    # };

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
      # Note: Cannot validate privateKeyFile existence at build time in Nix sandbox
      # systemd will fail at runtime if file is missing or unreadable
    ]) cfg.interfaces);
  };
}
