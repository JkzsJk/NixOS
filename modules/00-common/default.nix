# Shared configuration across all hosts
{ config, pkgs, ... }:

{
  imports = [
    ./01-packages.nix
    ./02-shell.nix
    ./03-system.nix
    ./04-users.nix
    ./05-vivaldi.nix
  ];
}
