# Deluge module - VPN-isolated deluge service with WireGuard
{ config, pkgs, ... }:

{
  imports = [
    ./00-packages.nix
    ./01-options.nix
    ./02-users.nix
    ./03-service.nix
    ./04-web.nix
    ./05-firewall.nix
    ./06-namespace.nix
    ./07-wireguard.nix
    ./08-proxy.nix
  ];
}
