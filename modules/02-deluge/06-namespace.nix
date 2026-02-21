# Network namespace setup for VPN isolation
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myServices.deluge;
  ns = cfg.vpn.namespace;
in
{
  config = mkIf (cfg.enable && cfg.vpn.enable) {
    # Create network namespace service
    systemd.services."netns@${ns}" = {
      description = "${ns} network namespace";
      before = [ "network.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.iproute2}/bin/ip netns add ${ns}";
        ExecStop = "${pkgs.iproute2}/bin/ip netns del ${ns}";
      };
    };
  };
}
