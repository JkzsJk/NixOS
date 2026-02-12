# Shared configuration across all hosts
{ config, pkgs, ... }:

{
  imports = [
    ./system.nix
    ./packages.nix
    ./shell.nix
    ./vivaldi.nix
    ./users.nix
  ];
}
