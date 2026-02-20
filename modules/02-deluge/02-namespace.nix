# Network namespace setup for VPN isolation
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myServices.deluge;
in
{
  config = mkIf cfg.enable {
    # Create network namespace service
    systemd.services."netns@${cfg.vpn.namespace}" = {
      description = "${cfg.vpn.namespace} network namespace";
      before = [ "network.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.iproute2}/bin/ip netns add ${cfg.vpn.namespace}";
        ExecStop = "${pkgs.iproute2}/bin/ip netns del ${cfg.vpn.namespace}";
      };
    };
  };
}
