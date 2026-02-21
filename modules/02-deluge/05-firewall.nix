# Deluge firewall rules
{ config, lib, ... }:

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
    ];
  };
}
