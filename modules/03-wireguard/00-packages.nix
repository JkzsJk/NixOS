# WireGuard packages
{ config, lib, pkgs, ... }:

with lib;

{
  config = mkIf config.myServices.wireguard.enable {
    environment.systemPackages = with pkgs; [
      wireguard-tools  # wg, wg-quick commands
    ];
  };
}
