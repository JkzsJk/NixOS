# Deluge packages
{ config, lib, pkgs, ... }:

with lib;

{
  config = mkIf config.myServices.deluge.enable {
    environment.systemPackages = with pkgs; [
      deluge
      deluge-gtk  # Optional: GTK client
      iproute2    # For network namespace management
      wireguard-tools
    ];
  };
}
