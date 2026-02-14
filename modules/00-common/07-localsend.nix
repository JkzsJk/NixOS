# LocalSend configuration
{ config, pkgs, lib, ... }:

let
  localsendPort = 53317;  # Default LocalSend port
in

{
  # Install LocalSend
  environment.systemPackages = with pkgs; [
    localsend
  ];

  # Open firewall ports for LocalSend
  networking.firewall = {
    allowedTCPPorts = [ 
      localsendPort  # LocalSend HTTP server
    ];
    allowedUDPPorts = [ 
      localsendPort  # LocalSend multicast discovery
    ];
  };
}
