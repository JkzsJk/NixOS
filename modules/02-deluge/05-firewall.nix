# Deluge firewall rules
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myServices.deluge;
  cfg_web = config.myServices.deluge.web;
  
  listenPortsDefault = [ 6881 6889 ];
  
  listToRange = x: {
    from = elemAt x 0;
    to = elemAt x 1;
  };
in
{
  config = mkIf cfg.enable {
    networking.firewall = mkMerge [
      # Open torrent listen ports if declarative mode and openFirewall enabled
      (mkIf (cfg.declarative && cfg.openFirewall && !(cfg.config.random_port or true)) {
        allowedTCPPortRanges = singleton (listToRange (cfg.config.listen_ports or listenPortsDefault));
        allowedUDPPortRanges = singleton (listToRange (cfg.config.listen_ports or listenPortsDefault));
      })
      
      # Open web UI port if enabled
      (mkIf cfg_web.openFirewall {
        allowedTCPPorts = [ cfg_web.port ];
      })
      
      # VPN killswitch: block BitTorrent traffic outside VPN namespace
      (mkIf cfg.vpn.enable {
        extraCommands = ''
          # Block all non-VPN BitTorrent traffic (killswitch)
          # This prevents deluge-gtk or other torrent clients from bypassing the VPN
          
          # Get the deluge user's UID for filtering
          DELUGE_UID=$(id -u ${cfg.user} 2>/dev/null || echo "")
          
          if [ -n "$DELUGE_UID" ]; then
            # Allow BitTorrent traffic only from processes in VPN namespace
            # Block common BitTorrent ports for deluge user in root namespace
            ${pkgs.iptables}/bin/iptables -A OUTPUT -m owner --uid-owner $DELUGE_UID -p tcp --dport 6881:6889 -j DROP || true
            ${pkgs.iptables}/bin/iptables -A OUTPUT -m owner --uid-owner $DELUGE_UID -p udp --dport 6881:6889 -j DROP || true
            # Block DHT
            ${pkgs.iptables}/bin/iptables -A OUTPUT -m owner --uid-owner $DELUGE_UID -p udp --dport 6881 -j DROP || true
            # Block common high ports used by BitTorrent (like the 61300 we saw)
            ${pkgs.iptables}/bin/iptables -A OUTPUT -m owner --uid-owner $DELUGE_UID -p tcp --dport 49152:65535 -j DROP || true
            ${pkgs.iptables}/bin/iptables -A OUTPUT -m owner --uid-owner $DELUGE_UID -p udp --dport 49152:65535 -j DROP || true
          fi
        '';
        
        extraStopCommands = ''
          # Clean up killswitch rules
          DELUGE_UID=$(id -u ${cfg.user} 2>/dev/null || echo "")
          
          if [ -n "$DELUGE_UID" ]; then
            ${pkgs.iptables}/bin/iptables -D OUTPUT -m owner --uid-owner $DELUGE_UID -p tcp --dport 6881:6889 -j DROP 2>/dev/null || true
            ${pkgs.iptables}/bin/iptables -D OUTPUT -m owner --uid-owner $DELUGE_UID -p udp --dport 6881:6889 -j DROP 2>/dev/null || true
            ${pkgs.iptables}/bin/iptables -D OUTPUT -m owner --uid-owner $DELUGE_UID -p udp --dport 6881 -j DROP 2>/dev/null || true
            ${pkgs.iptables}/bin/iptables -D OUTPUT -m owner --uid-owner $DELUGE_UID -p tcp --dport 49152:65535 -j DROP 2>/dev/null || true
            ${pkgs.iptables}/bin/iptables -D OUTPUT -m owner --uid-owner $DELUGE_UID -p udp --dport 49152:65535 -j DROP 2>/dev/null || true
          fi
        '';
      })
    ];
  };
}
